import 'dart:io';
import 'dart:typed_data';

import 'package:blake2b/blake2b.dart';
import 'package:blake2b/blake2b_hash.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tezster_dart/chain/tezos/tezos_language_util.dart';
import 'package:tezster_dart/chain/tezos/tezos_message_utils.dart';
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

  // edsigtbeRGAZwMZnsAp5FkknxND1UoFdPzwJmChNue6qZnErNEeph1j5zRYAq1ohkW61qtP8hKWCpcovxYpXTm1Y4RM4hqkRtMe

  test('demo', () {
    var signGroup = [
      4,
      174,
      109,
      236,
      158,
      61,
      200,
      2,
      213,
      175,
      248,
      21,
      174,
      170,
      167,
      232,
      232,
      56,
      64,
      158,
      182,
      236,
      210,
      118,
      153,
      247,
      28,
      9,
      104,
      217,
      195,
      54,
      108,
      0,
      128,
      210,
      17,
      229,
      59,
      129,
      53,
      99,
      45,
      83,
      145,
      98,
      25,
      207,
      201,
      186,
      115,
      90,
      34,
      107,
      252,
      11,
      207,
      209,
      245,
      7,
      204,
      83,
      240,
      3,
      10,
      0,
      0,
      96,
      151,
      203,
      60,
      129,
      111,
      33,
      66,
      148,
      12,
      65,
      36,
      10,
      245,
      194,
      196,
      132,
      76,
      211,
      146,
      0,
      187,
      190,
      212,
      24,
      68,
      57,
      112,
      235,
      242,
      161,
      81,
      68,
      35,
      56,
      80,
      106,
      160,
      191,
      81,
      26,
      240,
      100,
      200,
      22,
      98,
      144,
      247,
      166,
      191,
      90,
      135,
      197,
      118,
      123,
      252,
      208,
      56,
      150,
      210,
      204,
      30,
      24,
      135,
      67,
      210,
      126,
      169,
      41,
      49,
      163,
      81,
      9,
      76,
      34,
      91,
      29,
      202,
      120,
      34,
      233,
      83,
      251,
      120,
      13
    ];

    print(signGroup.sublist(0, 32));
    Uint8List blake2bHash =
        Blake2bHash.hashWithDigestSize(256, Uint8List.fromList(signGroup));

    String uintToString = String.fromCharCodes(blake2bHash);
    String stringToHexString = hex.encode(uintToString.codeUnits);
    String finalStringToDecode = stringToHexString;
    List<int> listOfHexDecodedInt = hex.decode(finalStringToDecode);
    String publicKeyHash = bs58check.encode(listOfHexDecodedInt);
    print(publicKeyHash);
    // print(Blake2bHash.hashWithDigestSize(256, Uint8List.fromList(signGroup))
    //     .toList());
    // print(
    //   base58.encode(
    //     Uint8List.fromList(
    //       Blake2bHash.hashWithDigestSize(
    //         256,
    //         Uint8List.fromList(
    //           base58
    //                   .encode(
    //                     Uint8List.fromList(
    //                       "0x0574".codeUnits,
    //                     ),
    //                   )
    //                   .codeUnits +
    //               signGroup,
    //         ),
    //       ).toList(),
    //     ),
    //   ),
    // );
    // print("0x0574".codeUnits);
    // print(base58.encode(Uint8List.fromList("0x0574".codeUnits)).codeUnits);
    // var data = base58.decode(
    //     "edsigtbeRGAZwMZnsAp5FkknxND1UoFdPzwJmChNue6qZnErNEeph1j5zRYAq1ohkW61qtP8hKWCpcovxYpXTm1Y4RM4hqkRtMe");
    // var dd = hex.encode(String.fromCharCodes(
    //   Blake2bHash.hashWithDigestSize(
    //     256,
    //     Uint8List.fromList(
    //       "edsigtbeRGAZwMZnsAp5FkknxND1UoFdPzwJmChNue6qZnErNEeph1j5zRYAq1ohkW61qtP8hKWCpcovxYpXTm1Y4RM4hqkRtMe"
    //           .codeUnits,
    //     ),
    //   ),
    // ).codeUnits);
    // print(dd);
    // dd = "0x0574" + dd.substring(0, 32);
    // print(dd);
    // print(base58.encode(Uint8List.fromList(dd.codeUnits)));
  });
}
// op4vK32Fv2GjA4oHf3ke7TEBoSULshAeJFE49c7cEFzsheUSS8U
// 52GCuaMLRkmMwH1HtjvZBMkmNhM5zfosLgfujfQPQeXA
// 55x4FTLxR9CjUW6jb9TG9jnXRN72q7TraKuExAQPE6ATh2eaPWEuBvh
// Gp6FaZuPbnwXTbPgVNr2iwpkZcXNBVkWKkQXVQRbq2wE
// 63piaifwbtbJS5q1yr6QMBVTNMtCmPTWhkFm3Kd5emoX1evnKEnfwh1GaLvN9EmQZq
// 8Aru1KduKD7RbJHhCZBkMVzEvAtRkGKoZiRVxksYwyomh7Vc6sH3
