import 'dart:typed_data';
import 'package:tezster_dart/utils/sodium_utils.dart';

class CryptoUtils {
  static Uint8List generateSaltForPwHash() {
    return SodiumUtils.salt();
  }

  static Uint8List encryptMessage(
      Uint8List message, String passphrase, Uint8List salt) {
    var keyBytes = SodiumUtils.pwhash(passphrase, salt);
    var nonce = SodiumUtils.nonce();
    var s = SodiumUtils.close(message, nonce, keyBytes);

    return new Uint8List.fromList(nonce.toList() + s.toList());
  }

  static Uint8List decryptMessage(message, passphrase, salt) {
    var keyBytes = SodiumUtils.pwhash(passphrase, salt);
    return SodiumUtils.open(message, keyBytes);
  }

  static Uint8List signDetached(Uint8List simpleHash, Uint8List key) {
    return SodiumUtils.sign(simpleHash, key);
  }
}
