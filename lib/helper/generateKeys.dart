import 'dart:typed_data';
import 'package:blake2b/blake2b_hash.dart';
import 'package:convert/convert.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

class GenerateKeys {
  static String computeKeyHash(
    Uint8List publicKey,
  ) {
    Uint8List blake2bHash = Blake2bHash.hashWithDigestSize(160, publicKey);
    String uintToString = String.fromCharCodes(blake2bHash);
    String stringToHexString = hex.encode(uintToString.codeUnits);
    String finalStringToDecode = "06a19f" + stringToHexString;
    List<int> listOfHexDecodedInt = hex.decode(finalStringToDecode);
    String publicKeyHash = bs58check.encode(listOfHexDecodedInt);
    return publicKeyHash;
  }

  static String readKeysWithHint(
    Uint8List key,
    String hint,
  ) {
    String uint8ListToString = String.fromCharCodes(key);
    String stringToHexString = hex.encode(uint8ListToString.codeUnits);
    String concatinatingHexStringWithHint = hint + stringToHexString;
    List<int> convertingHexStringToListOfInt =
        hex.decode(concatinatingHexStringWithHint);
    String base58String = bs58check.encode(convertingHexStringToListOfInt);
    return base58String;
  }

  static Uint8List writeKeyWithHint(
    String key,
    String hint,
  ) {
    if (hint == 'edsk' ||
        hint == 'edpk' ||
        hint == 'sppk' ||
        hint == 'p2pk' ||
        hint == '2bf64e07' ||
        hint == '0d0f25d9') {
      return bs58check.decode(key).sublist(4);
    } else
      throw Exception("Unrecognized key hint, '$hint'");
  }
}
