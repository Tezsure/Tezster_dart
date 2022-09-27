import 'dart:io';
import 'dart:typed_data';

import 'package:blake2b/blake2b.dart';
import 'package:blake2b/blake2b_hash.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezster_dart/chain/tezos/tezos_language_util.dart';
import 'package:tezster_dart/chain/tezos/tezos_message_utils.dart';
import 'package:tezster_dart/michelson_parser/michelson_parser.dart';
import 'package:tezster_dart/src/soft-signer/soft_signer.dart';
import 'package:tezster_dart/tezster_dart.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();

  String testPrivateKey =
      "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC";
  String testForgedOperation =
      "713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb8146aa9b7f631e52f877a1d363474404da8130b0b940ee";
  String testMnemonics =
      "luxury bulb roast timber sense stove sugar sketch goddess host meadow decorate gather salmon funny person canoe daring machine network camp moment wrong dice";

  KeyStoreModel _keyStoreModel = KeyStoreModel(
    secretKey:
        "edskRrDH2TF4DwKU1ETsUjyhxPC8aCTD6ko5YDguNkJjRb3PiBm8Upe4FGFmCrQqzSVMDLfFN22XrQXATcA3v41hWnAhymgQwc",
    publicKey: "edpku4ZfXDzF7CjPkX5LS8JFg1Znab3UKdhp18maKq2MrR82Gm9BTc",
    publicKeyHash: "tz1aPUfTyjtUcSnCfSvyykT67atDtVu7FePX",
  );

  test('Get Keys From Mnemonics and PassPhrase', () async {
    List<String> keys =
        await TezsterDart.getKeysFromMnemonic(mnemonic: testMnemonics);
    expect(keys[0],
        "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC");
    expect(keys[1], "edpkuLog552hecagkykJ3fTvop6grTMhfZY4TWbvchDWdYyxCHcrQL");
    expect(keys[2], "tz1g85oYHLFKDpNfDHPeBUbi3S7pUsgCB28q");
  });

  test('Restore account from secret key', () {
    List<String> keys = TezsterDart.getKeysFromSecretKey(
        "edskRnzCiMnMiVWa3nK86kpFA639feEtYU8PCwXuG1t9kpPuNpnKECphv6yDT22Y23P1WQPe2Ng6ubXA9gYNhJJA2YUY43beFi");
    print(keys);
    expect(keys[0], _keyStoreModel.secretKey);
    expect(keys[1], _keyStoreModel.publicKey);
    expect(keys[2], _keyStoreModel.publicKeyHash);
  });

  test('Sign Operation Group', () async {
    List<String> keys = await TezsterDart.signOperationGroup(
      forgedOperation: testForgedOperation,
      privateKey: testPrivateKey,
    );
    expect(keys[0],
        "edsigtrBnsjSngfP6LULUDeo84eJVks4LWReYrZBUjKQNJjhVsG7bksqZ7CKnRePMceMe3vgRHHbyd2CqRdC8iEAK5NcyNn4iEB");
    expect(keys[1],
        "713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb8146aa9b7f631e52f877a1d363474404da8130b0b940ee8c7ce5bf2968c1204c1c4b2ba98bcbd08fc4ad3cad706d39ac55e4dd61fde5a8496840ce2d377389a4ca7842bf613d3f096fda819c26e43adfb0cad1336a430d");
  });

  test('Unlock Fundraiser Identity', () async {
    List<String> keys = await TezsterDart.unlockFundraiserIdentity(
      mnemonic:
          "cannon rabbit obvious drama slogan net acoustic donor core acoustic clinic poem travel plunge winter",
      email: "lkbpoife.tobqgidu@tezos.example.org",
      passphrase: "5tjpU0cimq",
    );
    expect(keys[0],
        "edskRzNDm2dpqe2yd5zYAw1vmjr8sAwMubfcXajxdCNNr4Ud39BoppeqMAzoCPmb14mzfXRhjtydQjCbqU2VzWrsq6JP4D9GVb");
    expect(keys[1], "edpkvASxrq16v5Awxpz4XPTA2d6QFaCL8expPrPNcVgVbWxT84Kdw2");
    expect(keys[2], "tz1hhkSbaocSWm3wawZUuUdX57L3maSH16Pv");
  });

  test('Create Soft Signer', () async {
    await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(_keyStoreModel.secretKey, 'edsk'));
  });

  test('send-Transaction-Operation', () async {
    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(_keyStoreModel.secretKey, 'edsk'));
    const server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendTransactionOperation(
      server,
      signer,
      _keyStoreModel,
      'tz1dTkCS1NQwapmafZwCoqBq1QhXmopKDLcj',
      500000,
      1500,
    );
    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  test('send-Delegation-Operation', () async {
    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(_keyStoreModel.secretKey, 'edsk'));
    const server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendDelegationOperation(
      server,
      signer,
      _keyStoreModel,
      'tz1dTkCS1NQwapmafZwCoqBq1QhXmopKDLcj',
      10000,
    );

    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  test('restore identity from mnemonic', () async {
    List<String> keys = await TezsterDart.restoreIdentityFromDerivationPath(
        "m/44'/1729'/0'/0'",
        "curious roof motor parade analyst riot chronic actor pony random ring slot");
    expect(keys[0],
        'edskRzZLyGkhw9fmibXfqyMuEtEaa8Lxfqz9VBAq7LZbb4AfNQrgbtwW7Tv8qRyr44M89KrTTdLoxML29wEXc2864QuG1xWijP');
    expect(keys[1], 'edpkvPPibVYfQd7uohshcoS7Q2XXTD6vgsJWBrYHmDypkVabWh8czs');
    expect(keys[2], 'tz1Kx6NQZ2M4a9FssBswKyT25USCXWHcTbw7');
  });

  test('Sign Payload', () async {
    var keys = TezsterDart.getKeysFromSecretKey('');
    // [skKey, pkKey, pkKeyHash]
    SoftSigner signer =
        TezsterDart.createSigner(TezsterDart.writeKeyWithHint(keys[0], 'edsk'));
    print(TezsterDart.signPayload(
        signer: signer,
        payload:
            '05010000007d54657a6f73205369676e6564204d6573736167653a20436f6e6669726d696e67206d79206964656e7469747920617320747a3158504171617861656e74706f38653239355737686a7236393673713958487a486a206f6e206f626a6b742e636f6d20617420323032312d31322d30395430363a33323a33382e3331355a'));
  });

  /// Without code optimized
  /// [1] -> 7712
  /// [2] -> 8572
  /// [3] -> 11292
  /// [4] -> 9412
  /// [5] -> 9057
  /// (7712 + 8572 + 11292 + 9412 + 9057) / 5 = [9209]

  /// With code optimized

  test('Test_Txs_time', () async {
    HttpOverrides.global = new MyHttpOverrides();
    KeyStoreModel keyStore = KeyStoreModel(
        secretKey:
            "edskRnzCiMnMiVWa3nK86kpFA639feEtYU8PCwXuG1t9kpPuNpnKECphv6yDT22Y23P1WQPe2Ng6ubXA9gYNhJJA2YUY43beFi",
        publicKey: "edpkuAE2nMQBWvFCPBdWgnzP8LgEigLcm6yCxZ5F9H6b5WGMHEJpcs",
        publicKeyHash: "tz1XPAqaxaentpo8e295W7hjr696sq9XHzHj");

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    const server = 'https://tezos-prod.cryptonomic-infra.tech';

    var result = await TezsterDart.sendTransactionOperation(
      server,
      signer,
      keyStore,
      'tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C',
      10,
      1500,
    );
    print(result['operationGroupID']);
    var opHash = result['operationGroupID'].toString().replaceAll('\n', '');
    var status = await TezsterDart.getOperationStatus(server, opHash);
    print(status);
    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  // [, edpktjBAyr2Zyns59K6VGuCkPY32PQdAGbe5fR3YvBML6gifZQkv1e, ]

  test('GasFeeCalTest', () async {
    KeyStoreModel keyStore = KeyStoreModel(
      publicKeyHash: 'tz1U....9zoK8C',
      secretKey: 'edskS8......rc',
      publicKey: 'edp...Qkv1e',
    );

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

    var server = '';

    var result = await TezsterDart.sendTransactionOperation(
      server,
      signer,
      keyStore,
      'tz1X....Hj',
      10,
      1500,
    );

    print(result['operationGroupID']);
    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  test('Michelson', () {
    // var code1 = """{"prim":"Pair","args":[[{"prim":"Elt","args":[{"int":"0"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"KT1Ji4hVDeQ5Ru7GW1Tna9buYSs3AppHLwj9"},{"int":"493449875825"}]},{"prim":"Pair","args":[{"string":"KT1XRPEPXbZK25r3Htzp2o1x7xdMMmfocKNW"},{"int":"0"}]}]}]},{"prim":"Elt","args":[{"int":"1"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"KT1TnrLFrdemNZ1AnnWNfi21rXg7eknS484C"},{"int":"809642331951"}]},{"prim":"Pair","args":[{"string":"KT1Xobej4mc6XgEjDoJoHtTKgbD1ELMvcQuL"},{"int":"0"}]}]}]},{"prim":"Elt","args":[{"int":"2"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"KT1EM6NjJdJXmz3Pj13pfu3MWVDwXEQnoH3N"},{"int":"18584958424417145000"}]},{"prim":"Pair","args":[{"string":"KT1GRSvLoikDsXujKgZPsGLX8k8VvR2Tq95b"},{"int":"0"}]}]}]}],{"prim":"Pair","args":[{"int":"500000"},{"string":"tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C"}]}]}""";
    // var code2 = """[{"prim":"Pair","args":[{"string":"tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C"},[{"prim":"Pair","args":[{"string":"KT1MEVCrGRCsoERXf6ahNLC4ik6J2vRH7Mm6"},{"prim":"Pair","args":[{"int":"2"},{"int":"500000"}]}]}]]}]""";

    // var michelin1 = MichelsonParser.translateMichelineToHex(code1);
    // print(michelin1);

    print(TezosMessageUtils.writeSignedInt('18584958424417145000'));
  });
}


/**
 "{"prim":"Pair","args":[[{"prim":"Elt","args":[{"int":"0"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"KT1Ji4hVDeQ5Ru7GW1Tna9buYSs3AppHLwj9"},{"int":"493449875825"}]},{"prim":"Pair","args":[{"string":"KT1XRPEPXbZK25r3Htzp2o1x7xdMMmfocKNW"},{"int":"0"}]}]}]},{"prim":"Elt","args":[{"int":"1"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"KT1TnrLFrdemNZ1AnnWNfi21rXg7eknS484C"},{"int":"809642331951"}]},{"prim":"Pair","args":[{"string":"KT1Xobej4mc6XgEjDoJoHtTKgbD1ELMvcQuL"},{"int":"0"}]}]}]},{"prim":"Elt","args":[{"int":"2"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"KT1EM6NjJdJXmz3Pj13pfu3MWVDwXEQnoH3N"},{"int":"18584958424417145000"}]},{"prim":"Pair","args":[{"string":"KT1GRSvLoikDsXujKgZPsGLX8k8VvR2Tq95b"},{"int":"0"}]}]}]}],{"prim":"Pair","args":[{"int":"500000"},{"string":"tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C"}]}]}"
 */

/**
 "[{"prim":"Pair","args":[{"string":"tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C"},[{"prim":"Pair","args":[{"string":"KT1MEVCrGRCsoERXf6ahNLC4ik6J2vRH7Mm6"},{"prim":"Pair","args":[{"int":"2"},{"int":"500000"}]}]}]]}]"
 */