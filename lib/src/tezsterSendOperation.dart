import 'dart:convert';
import 'dart:typed_data';

import 'package:blake2b/blake2b_hash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

import '../tezster_dart.dart';
// import 'package:blake2b/blake2b_hash.dart';
// import 'package:flutter/material.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
// import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:tezster_dart/tezster_dart.dart';

class TezsterSendOperation {
  static performPostRequest({
    String server,
    String command,
    Object payload,
  }) async {
    assert(server != null);
    assert(command != null);
    String url = '$server/$command';
    try {
      String payloadString = jsonEncode(payload);
      http.Response data = await http.post(
        url,
        body: payloadString,
        headers: {
          'content-type': 'application/json',
        },
      );
      return data;
    } catch (e) {
      return {"message": "Something went wrong"};
    }
  }

  static String _writeBranch(String branch) {
    Uint8List branchUint8List = bs58check.decode(branch).sublist(2);
    String branchHexString = hex.encode(branchUint8List);
    return branchHexString;
  }

  static forgeOperations({
    String branch,
    dynamic operation,
  }) {
    String encoded = _writeBranch(branch);
    print("encoded ===> $encoded");
    encoded += encodeOperationValue(operation);
    // print("encoded ===> $newEncode");
    return encoded;
  }

  static String twoByteHex(int n) {
    if (n < 128) {
      String hexString = "0" + n.toRadixString(16);
      return hexString.substring(hexString.length - 2);
    }

    String h = '';

    if (n > 2147483648) {
      BigInt r = BigInt.from(n);
      while (r > BigInt.zero) {
        //Review
        String data = ('0' + r.toRadixString(16) + 127.toRadixString(16));
        h = data.substring(data.length - 2) + h;
        r = r >> 7;
      }
    } else {
      int r = n;
      while (r > 0) {
        // Review
        String data = ('0' + (r & 127).toRadixString(16));
        h = data.substring(data.length - 2) + h;
        r = r >> 7;
      }
    }
    return h;
  }

  static String writeInt(int value) {
    if (value < 0) {
      return "Use writeSignedInt to encode negative numbers";
    }

    String twoByteHexString = twoByteHex(value);
    print("twoByteHexString ==> $twoByteHexString");

    List<int> hexStringToList = hex.decode(twoByteHexString);
    print("hexStringToList ===> $hexStringToList");

    Uint8List twoByteUint8List = Uint8List.fromList(hexStringToList);
    print("twoByteUint8List ===> $twoByteUint8List");

    Map mapData = twoByteUint8List.asMap();
    print("mapData ===> $mapData");

    List<int> hexList = [];

    mapData.forEach((key, value) {
      var hexValue = key == 0 ? value : value ^ 0x80;
      print(key.toString() + " " + value.toString());
      print(hexValue);
      hexList.add(hexValue);
    });
    print("hexList ===> $hexList");

    List reversedList = (hexList.reversed).toList();

    Uint8List conversion = Uint8List.fromList((hexList.reversed).toList());
    print("conversion $conversion");

    String reversedIntListDataToHex = hex.encode(reversedList);
    print("reversedIntListDataToHex ===> $reversedIntListDataToHex");

    return reversedIntListDataToHex;
  }

  static Map<String, int> sepyTnoitarepo = {
    'endorsement': 0,
    'seedNonceRevelation': 1,
    'doubleEndorsementEvidence': 2,
    'doubleBakingEvidence': 3,
    'accountActivation': 4,
    'proposal': 5,
    'ballot': 6,
    'reveal': 7,
    'transaction': 8,
    'origination': 9,
    'delegation': 10,
    'Newreveal': 107,
    'Newtransaction': 108,
    'Neworigination': 109,
    'Newdelegation': 110
  };

  static String writeAddress(String address) {
    Uint8List uintBsList = bs58check.decode(address).sublist(3);
    // List<int> bsList = List.from(uintBsList);
    String hexString = hex.encode(uintBsList);
    // print("hexString ===> $hexString");

    if (address.startsWith("tz1")) {
      return "0000" + hexString;
    } else if (address.startsWith("tz2")) {
      return "0001" + hexString;
    } else if (address.startsWith("tz3")) {
      return "0002" + hexString;
    } else if (address.startsWith("KT1")) {
      return "01" + hexString + "00";
    } else {
      throw new ErrorDescription("Unrecognized address prefix: ");
    }
  }

  static String encodeTransaction(Transaction transaction) {
    String hexString = writeInt(sepyTnoitarepo['transaction']);
    hexString += writeAddress(transaction.source).substring(2);
    hexString += writeInt(int.parse(transaction.fee));
    hexString += writeInt(int.parse(transaction.counter));
    hexString += writeInt(int.parse(transaction.gasLimit));
    hexString += writeInt(int.parse(transaction.storageLimit));
    hexString += writeInt(int.parse(transaction.amount));
    hexString += writeAddress(transaction.destination);

    if (transaction.contractParameters != null) {
      ContractParameters composite = transaction.contractParameters;

      // TODO : TranslateMichelineToHex to be done
      // String code = normalizeMichelineWhiteSpace(jsonEncode(composite.value));
      // String result = translateMichelineToHex(code);
      String result = "";

      if ((composite.entrypoint == 'default' || composite.entrypoint == '') &&
          result == '030b') {
        hexString += '00';
      } else {
        hexString += 'ff';

        if (composite.entrypoint == 'default' || composite.entrypoint == '') {
          hexString += '00';
        } else if (composite.entrypoint == 'root') {
          hexString += '01';
        } else if (composite.entrypoint == 'do') {
          hexString += '02';
        } else if (composite.entrypoint == 'set_delegate') {
          hexString += '03';
        } else if (composite.entrypoint == 'remove_delegate') {
          hexString += '04';
        } else {
          hexString += 'ff' +
              ('0' + composite.entrypoint.length.toRadixString(16))
                  .substring(2) +
              composite.entrypoint
                  .split('')
                  .map((c) => c.codeUnitAt(0).toRadixString(16))
                  .join();
        }

        if (result == '030b') {
          hexString += '00';
        } else {
          int resultLengthDiv2 = int.parse((result.length / 2).toString());
          String data = ('0000000' + resultLengthDiv2.toRadixString(16));
          hexString += data.substring(data.length - 8) + result;
        }
      }
    } else {
      hexString += '00';
    }

    return hexString;
  }

  static encodeOperationValue(operation) {
    return encodeTransaction(Transaction(
      amount: operation.amount,
      counter: operation.counter,
      destination: operation.destination,
      contractParameters: operation.contractParameters,
      fee: operation.fee,
      gasLimit: operation.gasLimit,
      source: operation.source,
      storageLimit: operation.storageLimit,
    ));
  }

  static sendTransactionOperation({
    String server,
    KeyStore keyStore,
    String to,
    int amount,
    int fee,
    String derivationPath = '',
  }) async {
    dynamic counter = await TezsterNodeReader.getCounterForAccount(
            server: server, accountHash: keyStore.publicKeyHash) +
        1;

    Transaction transaction = Transaction(
      destination: to,
      amount: amount.toString(),
      storageLimit: 496.toString(),
      gasLimit: 10600.toString(),
      counter: counter.toString(),
      fee: fee.toString(),
      source: keyStore.publicKeyHash,
    );

    /// [appendRevealOperation]
    dynamic transactionOperation = await appendRevealOperation(
      server: server,
      keyStore: keyStore,
      accountHash: keyStore.publicKeyHash,
      accountOperationIndex: counter - 1,
      transactions: transaction,
    );
    print("transactionOperation ===> ${transactionOperation.source}");

    return sendOperation(
        server, transactionOperation, keyStore, derivationPath);
  }

  static sendOperation(String server, Transaction operations, KeyStore keyStore,
      String derivationPath) async {
    var blockHead = await TezsterNodeReader.getBlockHead(server: server);
    print("blockHead ===> ${blockHead['hash']}");
    var forgedOperationGroup =
        forgeOperations(branch: blockHead['hash'], operation: operations);
    SignedOperationGroup signedOpGroup = await signOperationGroup(
      forgedOperation: forgedOperationGroup,
      privateKey: keyStore.privateKey,
      derivationPath: derivationPath,
    );
    print("signedOpGroup ===> ${signedOpGroup.signature}");

    var appliedOp = await preapplyOperation(
      server: server,
      branch: blockHead['hash'],
      protocol: blockHead['protocol'],
      transaction: operations,
      signedOpGroup: signedOpGroup,
    );
    print("appliedOp ===> ${appliedOp.body.toString()}");

    var injectedOperation =
        await injectOperation(server: server, signedOpGroup: signedOpGroup);
    print("injectedOperation ===> $injectedOperation");

    /// TODO : Pending Task
    /// "results": appliedOp[0],
    return {"operationGroupID": injectedOperation};
  }

  static Future<SignedOperationGroup> signOperationGroup({
    String forgedOperation,
    String derivationPath,
    String privateKey,
  }) async {
    assert(forgedOperation != null);
    assert(privateKey != null);

    String watermarkedForgedOperationBytesHex = '03' + forgedOperation;

    /// converting String to HexString [waterMarkHexIntList]
    List<int> waterMarkHexIntList =
        hex.decode(watermarkedForgedOperationBytesHex);

    /// converting List [waterMarkHexIntList] to Uint8List [waterMarkHexUint8List]
    Uint8List waterMarkHexUint8List = Uint8List.fromList(waterMarkHexIntList);

    Uint8List hashedWatermarkedOpBytes =
        await _simpleHash(waterMarkHexUint8List, 32);
    Uint8List privateKeyBytes = _writeKeyWithHint(privateKey, "edsk");
    print("bs58List ===> $privateKeyBytes");
    Uint8List opSignature = await Sodium.cryptoSignDetached(
        hashedWatermarkedOpBytes, privateKeyBytes);
    print("opSignature ===> $opSignature");

    String hexSignature = _readSignatureWithHint(opSignature, 'edsig');
    print("hexString ===> $hexSignature");

    List<int> forgedOperationListInt = hex.decode(forgedOperation);
    Uint8List forgedOperationUint8List =
        Uint8List.fromList(forgedOperationListInt);

    List<int> signedOpBytes = forgedOperationUint8List + opSignature;

    return SignedOperationGroup(bytes: signedOpBytes, signature: hexSignature);

// Trial 2
    // List<int> hexStringToListOfInt =
    //     hex.decode(watermarkedForgedOperationBytesHex);
    // Uint8List hashedWatermarkedOpBytes =
    //     Blake2bHash.hashWithDigestSize(256, hexStringToListOfInt);
    // Uint8List privateKeyBytes = bs58check.decode(privateKey);
    // List<int> pkB = List.from(privateKeyBytes);
    // pkB.removeRange(0, 4);
    // Uint8List finalPKb = Uint8List.fromList(pkB);
    // Uint8List value = await Sodium.cryptoSignDetached(
    //   hashedWatermarkedOpBytes,
    //   finalPKb,
    //   useBackgroundThread: false,
    // );
    // String opSignatureHex = hex.encode(value);
    // String hexStringToEncode = '09f5cd8612' + opSignatureHex;
    // Uint8List hexDeco = hex.decode(hexStringToEncode);
    // String hexSignature = bs58check.encode(hexDeco);
    // String signedOpBytes = forgedOperation + opSignatureHex;
    // List signedOpBytestoList = hex.decode(signedOpBytes);
    // return SignedOperationGroup(
    //     bytes: signedOpBytestoList, signature: hexSignature);

    /// Trial 1
    // String watermarkedForgedOperationBytesHex = "03" + forgedOperation;
    // String stringToHexString =
    //     hex.encode(watermarkedForgedOperationBytesHex.codeUnits);
    // // print(stringToHexString);
    // List<int> hexStringToListOfInt = hex.decode(stringToHexString);
    // // print(hexStringToListOfInt);
    // Uint8List hashedWatermarkedOpBytes = _simpleHash(hexStringToListOfInt, 256);
    // print("hashedWatermarkedOpBytes ===> $hashedWatermarkedOpBytes");
    // print("hashedWatermarkedOpBytes ===> ${hashedWatermarkedOpBytes.length}");
    // Uint8List privateKeyBytes = _writeKeyWithHint(privateKey, "edsk");
    // print("bs58List ===> $privateKeyBytes");

    // Uint8List opSignature =
    //     await _signDetach(hashedWatermarkedOpBytes, privateKeyBytes);
    // print("opSignature ===> $opSignature");

    // String hexString = _readSignatureWithHint(opSignature, 'edsig');
    // print("hexString ===> $hexString");

    // List listforgedOperation = hex.decode(forgedOperation);
    // Uint8List uint8ListforgedOperation =
    //     Uint8List.fromList(listforgedOperation);
    // List signedOpBytes = uint8ListforgedOperation + opSignature;
    // print("signedOpBytes ===> $signedOpBytes");

    // return SignedOperationGroup(bytes: signedOpBytes, signature: hexString);
  }

  static preapplyOperation({
    String server,
    String branch,
    String protocol,
    Transaction transaction,
    SignedOperationGroup signedOpGroup,
    String chainid = 'main',
  }) async {
    List payload = [
      {
        "protocol": protocol,
        "branch": branch,
        "contents": [
          {
            "kind": "transaction",
            "source": transaction.source,
            "fee": transaction.fee,
            "counter": transaction.counter,
            "gas_limit": transaction.gasLimit,
            "storage_limit": transaction.storageLimit,
            "amount": transaction.amount,
            "destination": transaction.destination,
          }
        ],
        "signature": signedOpGroup.signature
      }
    ];
    print(json.encode(payload).toString());
    var response = await performPostRequest(
      server: server,
      command: "chains/$chainid/blocks/head/helpers/preapply/operations",
      payload: payload,
    );

    return response;
  }

  /// TODO: pending
  static Future<dynamic> injectOperation({
    String server,
    SignedOperationGroup signedOpGroup,
    String chainid = 'main',
  }) {
    String signedOpByteHex = hex.encode(signedOpGroup.bytes);
    print("signedOpByteHex ===> $signedOpByteHex");
    var response = performPostRequest(
      server: server,
      command: "injection/operation?chain=$chainid",
      payload: signedOpByteHex,
    );
    print("response ===> $response");
    return response;
  }

  static appendRevealOperation({
    String server,
    dynamic keyStore,
    String accountHash,
    int accountOperationIndex,
    dynamic transactions,
  }) async {
    bool isKeyRevealed = await TezsterNodeReader.isManagerKeyRevealedForAccount(
        server: server, accountHash: accountHash);
    int counter = accountOperationIndex + 1;

    if (!isKeyRevealed) {
      Reveal revealOp = Reveal(
        source: accountHash,
        fee: '0',
        counter: counter.toString(),
        gasLimit: '10600',
        storageLimit: '0',
        publicKey: keyStore.publicKey,
      );

      transactions.forEach((transaction, i) {
        var c = accountOperationIndex + 2 + i;
        transaction.counter = c.toString();
      });

      return [revealOp, ...transactions];
    }
    return transactions;
  }
}

Future<Uint8List> _simpleHash(Uint8List payload, int digestSize) async {
  return await Sodium.cryptoGenerichash(digestSize, payload, null);
  // return Blake2bHash.hashWithDigestSize(digestSize, payload);
}

Uint8List _writeKeyWithHint(String key, String hint) {
  if (hint == "edsk" || hint == "edpk") {
    return bs58check.decode(key).sublist(4);
  } else {
    throw {"message": "Unrecognized key hint, '$hint'"};
  }
}

// static Future<Uint8List> _signDetach(Uint8List message, Uint8List sk) async {
//   return Sodium.cryptoSignDetached(message, sk);
// }

String _readSignatureWithHint(Uint8List payload, String hint) {
  // String encodedPayoadToHexString =
  //     hex.encode(concatEncodedPayload.codeUnits);
  // Uint8List finlaListForBS58CHECK = hex.decode(concatEncodedPayload);
  // Uint8List finlaListForBS58CHECK = hex.decode(encodedPayoadToHexString);

  // print(finlaListForBS58CHECK);
  if (hint == 'edsig') {
    List<int> intConversionPayload = List.from(payload);
    String encodedPayoad = hex.encode(intConversionPayload);
    // String concatEncodedPayload = '09f5cd8612' + encodedPayoad;
    String concatEncodedPayload = '09f5cd8612' + encodedPayoad;

    List<int> hexPayloadListInt = hex.decode(concatEncodedPayload);
    Uint8List finalHexPayloadUint8ListInt =
        Uint8List.fromList(hexPayloadListInt);

    return bs58check.encode(finalHexPayloadUint8ListInt);
  } else {
    throw {"message": "Unrecognized key hint, '$hint'"};
  }
}
