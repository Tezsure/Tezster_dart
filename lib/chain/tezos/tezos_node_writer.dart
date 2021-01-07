import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:tezster_dart/chain/tezos/tezos_message_codec.dart';
import 'package:tezster_dart/chain/tezos/tezos_message_utils.dart';
import 'package:tezster_dart/chain/tezos/tezos_node_reader.dart';
import 'package:tezster_dart/helper/constants.dart';
import 'package:tezster_dart/helper/http_helper.dart';
import 'package:tezster_dart/models/key_store_model.dart';
import 'package:tezster_dart/models/operation_model.dart';
import 'package:tezster_dart/src/soft-signer/soft_signer.dart';

class TezosNodeWriter {
  static Future<Map<String, Object>> sendTransactionOperation(String server,
      SoftSigner signer, KeyStoreModel keyStore, String to, int amount, int fee,
      {int offset = 54}) async {
    var counter = await TezosNodeReader.getCounterForAccount(
            server, keyStore.publicKeyHash) +
        1;

    OperationModel transaction = new OperationModel(
      destination: to,
      amount: amount.toString(),
      counter: counter,
      fee: fee.toString(),
      source: keyStore.publicKeyHash,
    );

    var operations = await appendRevealOperation(server, keyStore.publicKey,
        keyStore.publicKeyHash, counter - 1, <OperationModel>[transaction]);
    return sendOperation(server, operations, signer, offset);
  }

  static sendDelegationOperation(String server, SoftSigner signer,
      KeyStoreModel keyStore, String delegate, int fee, offset) async {
    var counter = await TezosNodeReader.getCounterForAccount(
            server, keyStore.publicKeyHash) +
        1;
    OperationModel delegation = new OperationModel(
      counter: counter,
      kind: 'delegation',
      fee: fee.toString(),
      source: keyStore.publicKeyHash,
      delegate: delegate,
    );

    var operations = await appendRevealOperation(server, keyStore.publicKey,
        keyStore.publicKeyHash, counter - 1, [delegation]);
    return sendOperation(server, operations, signer, offset);
  }

  static Future<List<OperationModel>> appendRevealOperation(
      String server,
      String publicKey,
      String publicKeyHash,
      int accountOperationIndex,
      List<OperationModel> operations) async {
    bool isKeyRevealed = await TezosNodeReader.isManagerKeyRevealedForAccount(
        server, publicKeyHash);
    var counter = accountOperationIndex + 1;
    if (!isKeyRevealed) {
      var revealOp = OperationModel(
        counter: counter,
        fee: '0',
        source: publicKeyHash,
        kind: 'reveal',
        gasLimit: 10600,
        storageLimit: 0,
        publicKey: publicKey,
      );
      for (var index = 0; index < operations.length; index++) {
        var c = accountOperationIndex + 2 + index;
        operations[index].counter = c;
      }
      return <OperationModel>[revealOp, ...operations];
    }
    return operations;
  }

  static Future<Map<String, Object>> sendOperation(String server,
      List<OperationModel> operations, SoftSigner signer, int offset) async {
    var blockHead = await TezosNodeReader.getBlockAtOffset(server, offset);
    var blockHash = blockHead['hash'].toString().substring(0, 51);
    var forgedOperationGroup = forgeOperations(blockHash, operations);
    var opSignature = signer.signOperation(Uint8List.fromList(hex.decode(
        TezosConstants.OperationGroupWatermark + forgedOperationGroup)));
    var signedOpGroup = Uint8List.fromList(
        hex.decode(forgedOperationGroup) + opSignature.toList());
    var base58signature = TezosMessageUtils.readSignatureWithHint(
        opSignature, signer.getSignerCurve());
    var opPair = {'bytes': signedOpGroup, 'signature': base58signature};
    var appliedOp = await preapplyOperation(
        server, blockHash, blockHead['protocol'], operations, opPair);
    var injectedOperation = await injectOperation(server, opPair);

    return {'results': appliedOp[0], 'operationGroupID': injectedOperation};
  }

  static String forgeOperations(
      String branch, List<OperationModel> operations) {
    var encoded = TezosMessageUtils.writeBranch(branch);
    operations.forEach((element) {
      encoded += TezosMessageCodec.encodeOperation(element);
    });
    return encoded;
  }

  static preapplyOperation(String server, String branch, protocol,
      List<OperationModel> operations, Map<String, Object> signedOpGroup,
      {String chainid = 'main'}) async {
    var payload = [
      {
        'protocol': protocol,
        'branch': branch,
        'contents': operations,
        'signature': signedOpGroup['signature']
      }
    ];
    print("signedOpGroup['signature'] ===> ${signedOpGroup['signature']}");
    print("parameters ===> ${jsonEncode(payload)}");
    var response = await HttpHelper.performPostRequest(server,
        'chains/$chainid/blocks/head/helpers/preapply/operations', payload);
    var json;
    try {
      json = jsonDecode(response);
    } catch (err) {
      throw new Exception(
          'Could not parse JSON from response of chains/$chainid/blocks/head/helpers/preapply/operation: $response for $payload');
    }
    parseRPCError(jsonDecode(response));
    return json;
  }

  static void parseRPCError(json) {
    var errors = '';
    try {
      var arr = json is List ? json : [json];
      if (json[0]['kind'] != null) {
        errors = arr.fold(
            '',
            (previousValue, element) =>
                '$previousValue${element['kind']} : ${element['id']}, ');
      } else if (arr.length == 1 &&
          arr[0]['contents'].length == 1 &&
          arr[0]['contents'][0]['kind'].toString() == "activate_account") {
      } else {
        // errors = arr.map((r) => r['contents']).map((o) {
        //   o
        //       .map((c) => c['metadata']['operation_result'])
        //       .addAll(o.expand((c) =>
        //               c['metadata']['internal_operation_results'] != null
        //                   ? c['metadata']['internal_operation_results']
        //                   : null)
        //             ..toList()
        //           // ..filter((c) => !!c)
        //           // ..map((c) => c['result']).toList(),
        //           )
        //       .map((r) => parseRPCOperationResult(r))
        //       .toList()
        //       // .where((i) => i.length > 0)
        //       .join(', ');
        // }).join(', ');
      }
    } catch (err) {
      if (json.toString().startsWith('Failed to parse the request body: ')) {
        errors = json.toString().toString().substring(34);
      } else {
        var hash = json
            .toString()
            .replaceFirst('/\"/g', "'")
            .replaceFirst('/\n/', "'");
        if (hash.length == 51 && hash[0] == 'o') {
        } else {
          print(
              "failed to parse errors: '$err' from '${json.toString()}'\n, PLEASE report this to the maintainers");
        }
      }
    }

    if (errors.length > 0) {
      print('errors found in response:\n$json');
      throw Exception(
          "Status code ==> 200\nResponse ==> $json \n Error ==> $errors");
    }
  }

  static String parseRPCOperationResult(result) {
    if (result.status == 'failed') {
      return "${result.status}: ${result.errors.map((e) => '(${e.kind}: ${e.id})').join(', ')}";
    } else if (result.status == 'applied') {
      return '';
    } else {
      return result.status;
    }
  }

  static injectOperation(String server, Map<String, Object> opPair,
      {chainid = 'main'}) async {
    var response = await HttpHelper.performPostRequest(server,
        'injection/operation?chain=$chainid', hex.encode(opPair['bytes']));
    response = response.toString().replaceAll('"', '');
    // parseRPCError(response);
    return response;
  }
}
