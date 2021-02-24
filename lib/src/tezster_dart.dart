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
import 'package:tezster_dart/chain/tezos/tezos_node_writer.dart';
import 'package:tezster_dart/helper/constants.dart';
import 'package:tezster_dart/helper/http_helper.dart';
import 'package:tezster_dart/reporting/tezos/tezos_conseil_client.dart';
import 'package:tezster_dart/src/soft-signer/soft_signer.dart';
import 'package:tezster_dart/tezster_dart.dart';
import 'package:tezster_dart/types/tezos/tezos_chain_types.dart';
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
    KeyPair keyPair = Sodium.cryptoSignSeedKeypair(seedLength32);
    String skKey = GenerateKeys.readKeysWithHint(keyPair.sk, '2bf64e07');
    String pkKey = GenerateKeys.readKeysWithHint(keyPair.pk, '0d0f25d9');
    String pkKeyHash = GenerateKeys.computeKeyHash(keyPair.pk);
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
    Uint8List value = Sodium.cryptoSignDetached(
      hashedWatermarkedOpBytes,
      finalPKb,
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
    KeyPair keyPair = Sodium.cryptoSignSeedKeypair(seed);
    String skKey = GenerateKeys.readKeysWithHint(keyPair.sk, '2bf64e07');
    String pkKey = GenerateKeys.readKeysWithHint(keyPair.pk, '0d0f25d9');
    String pkKeyHash = GenerateKeys.computeKeyHash(keyPair.pk);
    return [skKey, pkKey, pkKeyHash];
  }

  static Future<String> getBalance(String publicKeyHash, String rpc) async {
    assert(publicKeyHash != null);
    assert(rpc != null);
    var response = await HttpHelper.performGetRequest(rpc,
        'chains/main/blocks/head/context/contracts/$publicKeyHash/balance');
    return response.toString();
  }

  static Uint8List writeKeyWithHint(key, hint) {
    assert(key != null);
    assert(hint != null);
    return GenerateKeys.writeKeyWithHint(key, hint);
  }

  static createSigner(Uint8List secretKey, {int validity = 60}) {
    assert(secretKey != null);
    return SoftSigner.createSigner(secretKey, validity);
  }

  static sendTransactionOperation(String server, SoftSigner signer,
      KeyStoreModel keyStore, String to, int amount, int fee,
      {int offset = 54}) async {
    assert(server != null);
    assert(signer != null);
    assert(keyStore != null);
    assert(keyStore.publicKeyHash != null);
    assert(keyStore.publicKey != null);
    assert(keyStore.secretKey != null);
    assert(to != null);
    assert(amount != null);
    assert(fee != null);
    assert(offset != null);

    return await TezosNodeWriter.sendTransactionOperation(
        server, signer, keyStore, to, amount, fee);
  }

  static sendDelegationOperation(String server, SoftSigner signer,
      KeyStoreModel keyStore, String delegate, int fee,
      {offset = 54}) async {
    assert(server != null);
    assert(signer != null);
    assert(keyStore != null);
    assert(keyStore.publicKeyHash != null);
    assert(keyStore.publicKey != null);
    assert(keyStore.secretKey != null);
    assert(offset != null);
    if (fee == null || fee == 0) fee = TezosConstants.DefaultDelegationFee;
    return await TezosNodeWriter.sendDelegationOperation(
        server, signer, keyStore, delegate, fee, offset);
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
    String storage, {
    TezosParameterFormat codeFormat = TezosParameterFormat.Micheline,
    int offset = 54,
  }) async {
    assert(server != null);
    assert(signer != null);
    assert(keyStore != null);
    assert(keyStore.publicKeyHash != null);
    assert(keyStore.publicKey != null);
    assert(keyStore.secretKey != null);
    assert(amount != null);
    assert(fee != null);
    assert(storageLimit != null);
    assert(gasLimit != null);
    assert(code != null);
    assert(storage != null);
    assert(codeFormat != null);
    assert(offset != null);
    return await TezosNodeWriter.sendContractOriginationOperation(
      server,
      signer,
      keyStore,
      amount,
      delegate,
      fee,
      storageLimit,
      gasLimit,
      code,
      storage,
      codeFormat,
      offset,
    );
  }

  static awaitOperationConfirmation(serverInfo, network, hash, duration,
      {blocktime}) async {
    assert(serverInfo != null);
    assert(network != null);
    assert(hash != null);
    assert(duration != null);
    return await TezosConseilClient.awaitOperationConfirmation(
        serverInfo, network, hash, duration,
        blocktime: blocktime);
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
      {TezosParameterFormat codeFormat = TezosParameterFormat.Micheline,
      offset = 54}) async {
    assert(server != null);
    assert(signer != null);
    assert(keyStore != null);
    assert(contract != null);
    assert(keyStore.publicKeyHash != null);
    assert(keyStore.publicKey != null);
    assert(keyStore.secretKey != null);
    assert(amount != null);
    assert(entrypoint != null);
    assert(parameters != null);
    assert(fee != null);
    assert(storageLimit != null);
    assert(gasLimit != null);
    return await TezosNodeWriter.sendContractInvocationOperation(
        server,
        signer,
        keyStore,
        contract,
        amount,
        fee,
        storageLimit,
        gasLimit,
        entrypoint,
        parameters,
        parameterFormat: codeFormat ?? TezosParameterFormat.Micheline,
        offset: offset ?? 54);
  }

  static sendIdentityActivationOperation(String server, SoftSigner signer,
      KeyStoreModel keyStore, String activationCode) async {
    assert(server != null);
    assert(signer != null);
    assert(keyStore != null);
    assert(activationCode != null);
    return await TezosNodeWriter.sendIdentityActivationOperation(
        server, signer, keyStore, activationCode);
  }

  static sendKeyRevealOperation(String server, signer, KeyStoreModel keyStore,
      {fee = TezosConstants.DefaultKeyRevealFee,
      offset = TezosConstants.HeadBranchOffset}) async {
    assert(server != null);
    assert(signer != null);
    assert(keyStore != null);
    assert(fee != null);
    assert(offset != null);
    return await TezosNodeWriter.sendKeyRevealOperation(
        server, signer, keyStore, fee, offset);
  }
}
