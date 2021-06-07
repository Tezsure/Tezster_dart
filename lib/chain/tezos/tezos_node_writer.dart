import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:tezster_dart/chain/tezos/tezos_language_util.dart';
import 'package:tezster_dart/chain/tezos/tezos_message_codec.dart';
import 'package:tezster_dart/chain/tezos/tezos_message_utils.dart';
import 'package:tezster_dart/chain/tezos/tezos_node_reader.dart';
import 'package:tezster_dart/helper/constants.dart';
import 'package:tezster_dart/helper/http_helper.dart';
import 'package:tezster_dart/models/key_store_model.dart';
import 'package:tezster_dart/models/operation_model.dart';
import 'package:tezster_dart/src/soft-signer/soft_signer.dart';
import 'package:tezster_dart/types/tezos/tezos_chain_types.dart';
import 'package:tezster_dart/utils/gas_fee_calculator.dart';

class TezosNodeWriter {
  static Future<Map<String, Object>> sendTransactionOperation(String server,
      SoftSigner signer, KeyStoreModel keyStore, String to, int amount, int fee,
      {int offset = 54}) async {
    var counter = await TezosNodeReader.getCounterForAccount(
            server, keyStore.publicKeyHash) +
        1;

    var estimate = Estimate(TezosConstants.DefaultTransactionGasLimit * 1000,
        TezosConstants.DefaultTransactionStorageLimit, 162, 250, fee);

    OperationModel transaction = new OperationModel(
      destination: to,
      amount: amount.toString(),
      counter: counter,
      fee: estimate.suggestedFeeMutez.toString(), 
      source: keyStore.publicKeyHash,
      gasLimit: estimate.gasLimit,
      storageLimit: estimate.storageLimit,
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

    var estimate = Estimate(TezosConstants.DefaultDelegationGasLimit * 1000,
        TezosConstants.DefaultDelegationStorageLimit, 162, 250, fee);

    OperationModel delegation = new OperationModel(
      counter: counter,
      kind: 'delegation',
      fee: estimate.suggestedFeeMutez.toString(),
      source: keyStore.publicKeyHash,
      delegate: delegate,
      gasLimit: estimate.gasLimit,
      storageLimit: estimate.storageLimit,
    );

    var operations = await appendRevealOperation(server, keyStore.publicKey,
        keyStore.publicKeyHash, counter - 1, [delegation]);
    return sendOperation(server, operations, signer, offset);
  }

  static sendContractOriginationOperation(
      String server,
      SoftSigner signer,
      KeyStoreModel keyStore,
      int amount,
      String delegate,
      int fee,
      int storageLimit,
      int gasLimit,
      String code,
      String storage,
      TezosParameterFormat codeFormat,
      int offset) async {
    var counter = await TezosNodeReader.getCounterForAccount(
            server, keyStore.publicKeyHash) +
        1;
    var operation = constructContractOriginationOperation(
        keyStore,
        amount,
        delegate,
        fee,
        storageLimit,
        gasLimit,
        code,
        storage,
        codeFormat,
        counter);
    var operations = await appendRevealOperation(server, keyStore.publicKey,
        keyStore.publicKeyHash, counter - 1, [operation]);
    return sendOperation(server, operations, signer, offset);
  }

  static sendContractInvocationOperation(
      String server,
      SoftSigner signer,
      KeyStoreModel keyStore,
      String contract,
      int amount,
      int fee,
      int storageLimit,
      int gasLimit,
      entrypoint,
      String parameters,
      {TezosParameterFormat parameterFormat = TezosParameterFormat.Micheline,
      offset = 54}) async {
    var counter = await TezosNodeReader.getCounterForAccount(
            server, keyStore.publicKeyHash) +
        1;
    var transaction = constructContractInvocationOperation(
        keyStore.publicKeyHash,
        counter,
        contract,
        amount,
        fee,
        storageLimit,
        gasLimit,
        entrypoint,
        parameters,
        parameterFormat);
    var operations = await appendRevealOperation(server, keyStore.publicKey,
        keyStore.publicKeyHash, counter - 1, [transaction]);
    return sendOperation(server, operations, signer, offset);
  }

  static sendIdentityActivationOperation(String server, SoftSigner signer,
      KeyStoreModel keyStore, String activationCode) async {
    var activation = OperationModel(
      kind: 'activate_account',
      pkh: keyStore.publicKeyHash,
      secret: activationCode,
    );
    return await sendOperation(server, [activation], signer, 54);
  }

  static sendKeyRevealOperation(
      String server, signer, KeyStoreModel keyStore, fee, offset) async {
    var counter = (await TezosNodeReader.getCounterForAccount(
            server, keyStore.publicKeyHash)) +
        1;
    var estimate = Estimate(10000 * 1000, 0, 162, 250, fee);

    var revealOp = OperationModel(
      kind: 'reveal',
      source: keyStore.publicKeyHash,
      fee: estimate.suggestedFeeMutez.toString(),
      counter: counter,
      gasLimit: estimate.gasLimit,
      storageLimit: estimate.storageLimit,
      publicKey: keyStore.publicKey,
    );

    var operations = [revealOp];
    return sendOperation(server, operations, signer, offset);
  }

  static constructContractInvocationOperation(
      String publicKeyHash,
      int counter,
      String contract,
      int amount,
      int fee,
      int storageLimit,
      int gasLimit,
      entrypoint,
      String parameters,
      TezosParameterFormat parameterFormat) {
    var estimate = Estimate(gasLimit * 1000, storageLimit, 162, 250, fee);

    OperationModel transaction = new OperationModel(
      destination: contract,
      amount: amount.toString(),
      counter: counter,
      fee: estimate.suggestedFeeMutez.toString(),
      source: publicKeyHash,
      gasLimit: estimate.gasLimit,
      storageLimit: estimate.storageLimit,
    );

    if (parameters != null) {
      if (parameterFormat == TezosParameterFormat.Michelson) {
        var michelineParams =
            TezosLanguageUtil.translateMichelsonToMicheline(parameters);
        transaction.parameters = {
          'entrypoint': entrypoint.isEmpty ? 'default' : entrypoint,
          'value': jsonDecode(michelineParams)
        };
      } else if (parameterFormat == TezosParameterFormat.Micheline) {
        transaction.parameters = {
          'entrypoint': entrypoint.isEmpty ? 'default' : entrypoint,
          'value': jsonDecode(parameters)
        };
      } else if (parameterFormat == TezosParameterFormat.MichelsonLambda) {
        var michelineLambda =
            TezosLanguageUtil.translateMichelsonToMicheline('code $parameters');
        transaction.parameters = {
          'entrypoint': entrypoint.isEmpty ? 'default' : entrypoint,
          'value': jsonDecode(michelineLambda)
        };
      }
      
    } else if (entrypoint != null) {
      transaction.parameters = {'entrypoint': entrypoint, 'value': []};
    }
    return transaction;
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
        fee: '0', // Reveal Fee will be covered by the appended operation
        source: publicKeyHash,
        kind: 'reveal',
        gasLimit: TezosConstants.DefaultKeyRevealGasLimit,
        storageLimit: TezosConstants.DefaultKeyRevealStorageLimit,
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

    return {'appliedOp': appliedOp[0], 'operationGroupID': injectedOperation};
  }

  static String forgeOperations(
      String branch, List<OperationModel> operations) {
    String encoded = TezosMessageUtils.writeBranch(branch);
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
      } else {}
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
    return response;
  }

  static OperationModel constructContractOriginationOperation(
      KeyStoreModel keyStore,
      int amount,
      String delegate,
      int fee,
      int storageLimit,
      int gasLimit,
      String code,
      String storage,
      TezosParameterFormat codeFormat,
      int counter) {
    var parsedCode;
    var parsedStorage;
    if (codeFormat == TezosParameterFormat.Michelson) {
      parsedCode =
          jsonDecode(TezosLanguageUtil.translateMichelsonToMicheline(code));
      parsedStorage =
          jsonDecode(TezosLanguageUtil.translateMichelsonToMicheline(storage));
    } else if (codeFormat == TezosParameterFormat.Micheline) {
      parsedCode = jsonDecode(code);
      parsedStorage = jsonDecode(storage);
    }
    var estimate = Estimate(gasLimit * 1000, storageLimit, 162, 250, fee);

    return OperationModel(
      kind: 'origination',
      source: keyStore.publicKeyHash,
      fee: estimate.suggestedFeeMutez.toString(),
      counter: counter,
      gasLimit: estimate.gasLimit,
      storageLimit: estimate.storageLimit,
      amount: amount.toString(),
      delegate: delegate,
      script: {
        'code': parsedCode,
        'storage': parsedStorage,
      },
    );
  }
}
