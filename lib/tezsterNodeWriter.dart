part of tezster_dart;

class TezsterNodeWriter {
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
      return bs58check.decode(key).sublist(0, 4);
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

  static signOperationGroup({
    String forgedOperation,
    String derivationPath,
    String privateKey,
  }) {
    String watermarkedForgedOperationBytesHex = "03" + forgedOperation;
    String stringToHexString =
        hex.encode(watermarkedForgedOperationBytesHex.codeUnits);
    // print(stringToHexString);
    List<int> hexStringToListOfInt = hex.decode(stringToHexString);
    // print(hexStringToListOfInt);
    Uint8List hashedWatermarkedOpBytes = _simpleHash(hexStringToListOfInt, 256);
    print("hashedWatermarkedOpBytes ===> $hashedWatermarkedOpBytes");
    print("hashedWatermarkedOpBytes ===> ${hashedWatermarkedOpBytes.length}");
    Uint8List bs58List = _writeKeyWithHint(privateKey, "edsk");
    print("bs58List ===> $bs58List");
  }

  



}
