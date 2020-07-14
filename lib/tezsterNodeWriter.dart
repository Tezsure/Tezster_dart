part of tezster_dart;

class TezsterNodeWriter with TezosMessageUtil {
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

  static Uint8List _simpleHash(Uint8List payload, int digestSize) {
    return Blake2bHash.hashWithDigestSize(digestSize, payload);
  }

  static Uint8List _writeKeyWithHint(String key, String hint) {
    if (hint == "edsk" || hint == "edpk") {
      return bs58check.decode(key).sublist(0, 64);
    } else {
      throw {"message": "Unrecognized key hint, '$hint'"};
    }
  }

  static String _readSignatureWithHint(Uint8List payload, String hint) {
    String encodedPayoad = hex.encode(payload);
    String concatEncodedPayload = '09f5cd8612' + encodedPayoad;
    String encodedPayoadToHexString =
        hex.encode(concatEncodedPayload.codeUnits);
    Uint8List finlaListForBS58CHECK = hex.decode(encodedPayoadToHexString);
    if (hint == 'edsig') {
      return bs58check.encode(finlaListForBS58CHECK);
    } else {
      throw {"message": "Unrecognized key hint, '$hint'"};
    }
  }

  static Future<Uint8List> _signDetach(Uint8List message, Uint8List sk) async {
    return Sodium.cryptoSignDetached(message, sk);
  }

  static signOperationGroup({
    String forgedOperation,
    String derivationPath,
    String privateKey,
  }) async {
    assert(forgedOperation != null);
    assert(privateKey != null);
    String watermarkedForgedOperationBytesHex = "03" + forgedOperation;
    String stringToHexString =
        hex.encode(watermarkedForgedOperationBytesHex.codeUnits);
    // print(stringToHexString);
    List<int> hexStringToListOfInt = hex.decode(stringToHexString);
    // print(hexStringToListOfInt);
    Uint8List hashedWatermarkedOpBytes = _simpleHash(hexStringToListOfInt, 256);
    // print("hashedWatermarkedOpBytes ===> $hashedWatermarkedOpBytes");
    // print("hashedWatermarkedOpBytes ===> ${hashedWatermarkedOpBytes.length}");
    Uint8List privateKeyBytes = _writeKeyWithHint(privateKey, "edsk");
    // print("bs58List ===> $privateKeyBytes");
    Uint8List opSignature =
        await _signDetach(hashedWatermarkedOpBytes, privateKeyBytes);
    // print("opSignature ===> $opSignature");

    String hexString = _readSignatureWithHint(opSignature, 'edsig');
    // print("hexString ===> $hexString");

    List listforgedOperation = hex.decode(forgedOperation);
    Uint8List uint8ListforgedOperation =
        Uint8List.fromList(listforgedOperation);
    List signedOpBytes = uint8ListforgedOperation + opSignature;
    // print("signedOpBytes ===> $signedOpBytes");

    return [signedOpBytes, hexString];
  }

  // FORGED OPERATION GROUP
  static encodeOpertion(k, v) {
    if (k.containsKey('pkh') && k.containsKey('secret')) {
      return encodeActivation(k as Activation);
    }

    if (k.containsKey('Kind')) {
      if (k.kind == 'reveal') return 'reveal';
      if (k.kind == 'transaction') return 'transaction';
      if (k.kind == 'origination') return 'origination';
      if (k.kind == 'delegation') return 'delegation';
    }

    if (k.containsKey('vote')) {
      return "encodeBallot";
    }
    throw new ErrorDescription("Unsupported message type");
  }

  static String twoByteHex(int n) {
    if (n < 128) {
      return "0" + n.toRadixString(16).substring(0, 2);
    }

    String h = '';
    if (n > 2147483648) {
      BigInt r = BigInt.from(n);
      while (!r.isNegative) {
        //Review
        h = ('0' + r.toRadixString(16) + 127.toRadixString(16))
                .substring(0, 2) +
            h;
        r = r >> 7;
      }
    } else {
      int r = n;
      while (r > 0) {
        // Review
        h = ('0' + (r & 127).toRadixString(16)).substring(0,2) + h;
        r = r >>7;
      }
    }
    return h;
  }


  static String writeInt(int value) {
    if (value < 0) {
      throw new ErrorDescription(
          "Use writeSignedInt to encode negative numbers");
    }

    List<int> twoByteListOfIntvalue = hex.decode(twoByteHex(value));
    Uint8List twoByteUint8Listvalue = Uint8List.fromList(twoByteListOfIntvalue);
    //pending
    Map<int, int> data = twoByteUint8Listvalue.asMap();
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

  static String encodeActivation(Activation k) {
    String writeIntHex = writeInt(sepyTnoitarepo['accountActivation']);
    print("writeIntHex ===> $writeIntHex");
    String hexCode = writeAddress(k.pkh);
    writeIntHex += hexCode.substring(4);
    writeIntHex += k.secret;
    return writeIntHex;
  }

  static String writeAddress(String address) {
    Uint8List uintBsList = bs58check.decode(address).sublist(3);
    List<int> bsList = List.from(uintBsList);
    String hexString = hex.encode(bsList);
    print("hexString ===> $hexString");

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

  static forgeOperations({
    String branch,
    Map operation,
  }) {
    String encoded = _writeBranch(branch);
    print("encoded ===> $encoded");
    operation.forEach((k, v) => encoded += encodeOpertion(k, v));
    return encoded;
  }

  static String _writeBranch(String branch) {
    Uint8List branchUint8List = bs58check.decode(branch).sublist(2);
    String branchHexString = hex.encode(branchUint8List);
    return branchHexString;
  }
}

class Activation {
  String kind; // activate_account
  String pkh;
  String secret;
}
