library tezster_dart;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:core';
import 'package:convert/convert.dart';
import 'package:blake2b/blake2b_hash.dart';
import 'package:crypto/crypto.dart';
import 'package:password_hash/password_hash.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bs58check/bs58check.dart' as bs58check;
import "package:unorm_dart/unorm_dart.dart" as unorm;
import 'package:flutter_sodium/flutter_sodium.dart';

import 'package:tezster_dart/helper/generateKeys.dart';

class TezsterDart {
  static String generateMnemonic({int strength = 256}) {
    return bip39.generateMnemonic(strength: strength);
  }

  static Future<List<String>> getKeysFromMnemonic({
    String mnemonic,
  }) async {
    assert(mnemonic != null);
    Uint8List seed = bip39.mnemonicToSeed(mnemonic);
    Uint8List seedLength32 = seed.sublist(0, 32);
    Map<dynamic, dynamic> keys =
        await Sodium.cryptoSignSeedKeypair(seedLength32);
    Uint8List sk = keys['sk'];
    Uint8List pk = keys['pk'];
    String skKey = GenerateKeys.readKeysWithHint(sk, '2bf64e07');
    String pkKey = GenerateKeys.readKeysWithHint(pk, '0d0f25d9');
    String pkKeyHash = GenerateKeys.computeKeyHash(pk);
    return [skKey, pkKey, pkKeyHash];
  }

  static Future<List<String>> getKeysFromMnemonicAndPassphrase({
    String mnemonic,
    String passphrase,
  }) async {
    assert(mnemonic != null);
    assert(passphrase != null);
    return await _unlockKeys(
      passphrase: passphrase,
      mnemonic: mnemonic,
    );
  }

  static Future<List<String>> unlockFundraiserIdentity({
    String mnemonic,
    String email,
    String passphrase = "",
  }) async {
    assert(mnemonic != null);
    assert(email != null);
    return await _unlockKeys(
      email: email,
      passphrase: passphrase,
      mnemonic: mnemonic,
    );
  }

  static Future<List<String>> signOperationGroup({
    String privateKey,
    String forgedOperation,
  }) async {
    assert(privateKey != null);
    assert(forgedOperation != null);
    String watermarkedForgedOperationBytesHex = '03' + forgedOperation;
    List<int> hexStringToListOfInt =
        hex.decode(watermarkedForgedOperationBytesHex);
    Uint8List hashedWatermarkedOpBytes =
        Blake2bHash.hashWithDigestSize(256, hexStringToListOfInt);
    Uint8List privateKeyBytes = bs58check.decode(privateKey);
    List<int> pkB = List.from(privateKeyBytes);
    pkB.removeRange(0, 4);
    Uint8List finalPKb = Uint8List.fromList(pkB);
    Uint8List value = await Sodium.cryptoSignDetached(
      hashedWatermarkedOpBytes,
      finalPKb,
      useBackgroundThread: false,
    );
    String opSignatureHex = hex.encode(value);
    String hexStringToEncode = '09f5cd8612' + opSignatureHex;
    Uint8List hexDeco = hex.decode(hexStringToEncode);
    String hexSignature = bs58check.encode(hexDeco);
    String signedOpBytes = forgedOperation + opSignatureHex;
    return [hexSignature, signedOpBytes];
  }

  static Future<List<String>> _unlockKeys({
    String mnemonic,
    String passphrase = "",
    String email = "",
  }) async {
    assert(mnemonic != null);
    assert(passphrase != null);

    List<int> stringNormalize(String stringToNormalize) {
      String normalizedString = unorm.nfkd(stringToNormalize);
      List<int> stringToBuffer = utf8.encode(normalizedString);
      return stringToBuffer;
    }

    List<int> mnemonicsBuffer = stringNormalize(mnemonic);
    String m = String.fromCharCodes(mnemonicsBuffer);
    List<int> normalizedPassphrase = stringNormalize("$email" + "$passphrase");
    String normString = String.fromCharCodes(normalizedPassphrase);
    String p = "mnemonic" + normString;
    Uint8List seed = PBKDF2(hashAlgorithm: sha512).generateKey(m, p, 2048, 32);
    Map<dynamic, dynamic> keys = await Sodium.cryptoSignSeedKeypair(seed);
    Uint8List sk = keys['sk'];
    Uint8List pk = keys['pk'];
    String skKey = GenerateKeys.readKeysWithHint(sk, '2bf64e07');
    String pkKey = GenerateKeys.readKeysWithHint(pk, '0d0f25d9');
    String pkKeyHash = GenerateKeys.computeKeyHash(pk);
    return [skKey, pkKey, pkKeyHash];
  }
}
