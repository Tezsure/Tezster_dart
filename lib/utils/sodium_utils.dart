import 'dart:typed_data';

import 'package:flutter_sodium/flutter_sodium.dart';

class SodiumUtils {
  static Uint8List rand(length) {
    return Sodium.randombytesBuf(length);
  }

  static Uint8List salt() {
    return Uint8List.fromList(rand(Sodium.cryptoPwhashSaltbytes).toList());
  }

  static Uint8List pwhash(String passphrase, Uint8List salt) {
    return Sodium.cryptoPwhash(
        Sodium.cryptoBoxSeedbytes,
        Uint8List.fromList(passphrase.codeUnits),
        salt,
        4,
        33554432,
        Sodium.cryptoPwhashAlgArgon2i13);
  }

  static Uint8List nonce() {
    return rand(Sodium.cryptoBoxNoncebytes);
  }

  static Uint8List close(
      Uint8List message, Uint8List nonce, Uint8List keyBytes) {
    return Sodium.cryptoSecretboxEasy(message, nonce, keyBytes);
  }

  static Uint8List open(Uint8List nonceAndCiphertext, Uint8List key) {
    var nonce = nonceAndCiphertext.sublist(0, Sodium.cryptoSecretboxNoncebytes);
    var ciphertext =
        nonceAndCiphertext.sublist(Sodium.cryptoSecretboxNoncebytes);

    return Sodium.cryptoSecretboxOpenEasy(ciphertext, nonce, key);
  }

  static Uint8List sign(Uint8List simpleHash, Uint8List key) {
    return Sodium.cryptoSignDetached(simpleHash, key);
  }

  static KeyPair publicKey(Uint8List sk) {
    var seed = Sodium.cryptoSignEd25519SkToSeed(sk);
    return Sodium.cryptoSignSeedKeypair(seed);
  }
}
