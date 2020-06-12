library tezster_dart;

import 'dart:convert';
import 'dart:typed_data';
import 'package:blake2b/blake2b_hash.dart';
import 'package:crypto/crypto.dart';
import 'package:password_hash/password_hash.dart';
import 'helper/generateKeys.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bs58check/bs58check.dart' as bs58check;
import "package:unorm_dart/unorm_dart.dart" as unorm;
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

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

  static dynamic performGetRequest({
    String server,
    String command = "",
  }) async {
    assert(server != null);
    String url = "$server/$command";
    http.Response response = await http.get(url);
    if (response.statusCode != 200) {
      return "Invalid url";
    }
    dynamic data = jsonDecode(response.body);
    return data;
  }

  static dynamic getBlock({
    String server,
    String hash = "head",
    String chainid = "main",
  }) async {
    assert(server != null);
    dynamic response = await performGetRequest(
      server: server,
      command: "chains/$chainid/blocks/$hash",
    );
    return response;
  }

  static dynamic getBlockHead({
    String server,
  }) async {
    assert(server != null);
    dynamic response = await getBlock(server: server);
    return response;
  }

  static dynamic getAccountForBlock({
    String server,
    String blockHash,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic response = await performGetRequest(
      server: server,
      command:
          "chains/$chainid/blocks/$blockHash/context/contracts/$accountHash}",
    );
    return response;
  }

  static dynamic getCounterForAccount({
    String server,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic counter = await performGetRequest(
      server: server,
      command:
          "chains/$chainid/blocks/head/context/contracts/$accountHash/counter",
    );
    return int.parse(counter, radix: 10);
  }

  static dynamic getSpendableBalanceForAccount({
    String server,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic account = await performGetRequest(
        server: server,
        command: "chains/$chainid/blocks/head/context/contracts/$accountHash");
    return int.parse(account.toString(), radix: 10);
  }

  static dynamic getAccountManagerForBlock({
    String server,
    String block,
    String accountHash,
    String chainid = "main",
  }) async {
    try {
      dynamic result = await performGetRequest(
        server: server,
        command:
            "chains/$chainid/blocks/$block/context/contracts/$accountHash/manager_key",
      );
      if (result.toString() == null) {
        return "";
      }
      return result.toString();
    } catch (e) {
      throw (e);
    }
  }

  static dynamic isImplicitAndEmpty({
    String server,
    String accountHash,
  }) async {
    dynamic account = await getAccountForBlock(
      server: server,
      blockHash: "head",
      accountHash: accountHash,
    );
    bool isImplicit = accountHash.toLowerCase().startsWith("tz");
    bool isEmpty = account.balance == 0;
    return (isImplicit && isEmpty) ? true : false;
  }

  static dynamic isManagerKeyRevealedForAccount({
    String server,
    String accountHash,
  }) async {
    dynamic managerKey = await getAccountManagerForBlock(
      server: server,
      block: "head",
      accountHash: accountHash,
    );
    return managerKey.toString().length > 0 ? true : false;
  }

  static dynamic getContractStorage({
    String server,
    String accountHash,
    String chainid = "main",
    String block = "head",
  }) async {
    dynamic response = performGetRequest(
      server: server,
      command:
          "chains/$chainid/blocks/$block/context/contracts/$accountHash/storage",
    );
    return response;
  }

  static dynamic getValueForBigMapKey({
    String server,
    num index,
    String key,
    String block = "main",
    String chainid = "head",
  }) async {
    dynamic response = performGetRequest(
      server: server,
      command: "chains/$chainid/blocks/$block/context/big_maps/$index/$key",
    );
    return response;
  }

  static dynamic getMempoolOperation({
    String server,
    String operationGroupId,
    String chainid = "main",
  }) async {
    dynamic mempoolContent = performGetRequest(
      server: server,
      command: "chains/$chainid/mempool/pending_operations",
    );
    //TODO: mempoolContent
    return mempoolContent;
  }

  static dynamic getMempoolOperationsForAccount({
    String server,
    String accountHash,
    String chainid = "main",
  }) async {
    dynamic mempoolContent = await performGetRequest(
      server: server,
      command: "chains/$chainid/mempool/pending_operations",
    );
    //TODO : Modification to be done.
    return mempoolContent;
  }
}
