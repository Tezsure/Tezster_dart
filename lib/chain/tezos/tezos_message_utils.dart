import 'dart:typed_data';

import 'package:blake2b/blake2b_hash.dart';
import 'package:bs58check/bs58check.dart';
import 'package:convert/convert.dart';
import 'package:tezster_dart/helper/generateKeys.dart';
import 'package:tezster_dart/src/soft-signer/soft_signer.dart';

class TezosMessageUtils {
  static String writeBranch(String branch) {
    return hex.encode(base58
        .decode(branch)
        .sublist(2, base58.decode(branch).length - 4)
        .toList());
    // return hex.encode(base58.decode(branch).sublist(2).toList());
  }

  static String writeInt(int value) {
    if (value < 0) {
      throw new Exception('Use writeSignedInt to encode negative numbers');
    }
    var byteHexList = Uint8List.fromList(hex.decode(twoByteHex(value)));
    for (var i = 0; i < byteHexList.length; i++) {
      if (i != 0) byteHexList[i] ^= 0x80;
    }
    var result = hex.encode(byteHexList.reversed.toList());
    return result;
  }

  static String twoByteHex(int n) {
    if (n < 128) {
      var s = ('0' + n.toRadixString(16));
      return s.substring(s.length - 2);
    }
    String h = '';
    if (n > 2147483648) {
      var r = BigInt.from(n);
      while (r.compareTo(BigInt.zero) != -1) {
        var _h = ('0' + (r & BigInt.from(127)).toRadixString(16));
        h = _h.substring(_h.length - 2) + h;
        r = r >> 7;
      }
    } else {
      var r = n;
      while (r > 0) {
        var _h = ('0' + (r & 127).toRadixString(16));
        h = _h.substring(_h.length - 2) + h;
        r = r >> 7;
      }
    }
    return h;
  }

  static String writeAddress(String address) {
    var base58data = base58.decode(address).sublist(3);
    base58data = base58data.sublist(0, base58data.length - 4);
    var _hex = hex.encode(base58data);
    if (address.startsWith("tz1")) {
      return "0000" + _hex;
    } else if (address.startsWith("tz2")) {
      return "0001" + _hex;
    } else if (address.startsWith("tz3")) {
      return "0002" + _hex;
    } else if (address.startsWith("KT1")) {
      return "01" + _hex + "00";
    } else {
      throw new Exception(
          'Unrecognized address prefix: ${address.substring(0, 3)}');
    }
  }

  static String writePublicKey(String publicKey) {
    if (publicKey.startsWith("edpk")) {
      return "00" + hex.encode(base58.decode(publicKey).sublist(4));
    } else if (publicKey.startsWith("sppk")) {
      return "01" + hex.encode(base58.decode(publicKey).sublist(4));
    } else if (publicKey.startsWith("p2pk")) {
      return "02" + hex.encode(base58.decode(publicKey).sublist(4));
    } else {
      throw new Exception('Unrecognized key type');
    }
  }

  static Uint8List simpleHash(Uint8List message, int size) {
    return Uint8List.fromList(Blake2bHash.hashWithDigestSize(256, message));
  }

  static String readSignatureWithHint(Uint8List opSignature, SignerCurve hint) {
    opSignature = Uint8List.fromList(opSignature);
    if (hint == SignerCurve.ED25519) {
      return GenerateKeys.readKeysWithHint(opSignature, '09f5cd8612');
    } else if (hint == SignerCurve.SECP256K1) {
      return GenerateKeys.readKeysWithHint(opSignature, '0d7365133f');
    } else if (hint == SignerCurve.SECP256R1) {
      return GenerateKeys.readKeysWithHint(opSignature, '36f02c34');
    } else {
      throw Exception('Unrecognized signature hint, "$hint"');
    }
  }

  static String writeBoolean(bool b) {
    return b ? "ff" : "00";
  }
}
