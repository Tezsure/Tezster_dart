import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tezster_dart/chain/tezos/tezos_language_util.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();

  String testPrivateKey =
      "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC";
  String testForgedOperation =
      "713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb8146aa9b7f631e52f877a1d363474404da8130b0b940ee";
  String testMnemonics =
      "luxury bulb roast timber sense stove sugar sketch goddess host meadow decorate gather salmon funny person canoe daring machine network camp moment wrong dice";

  test('Get Keys From Mnemonics and PassPhrase', () async {
    List<String> keys =
        await TezsterDart.getKeysFromMnemonic(mnemonic: testMnemonics);
    expect(keys[0],
        "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC");
    expect(keys[1], "edpkuLog552hecagkykJ3fTvop6grTMhfZY4TWbvchDWdYyxCHcrQL");
    expect(keys[2], "tz1g85oYHLFKDpNfDHPeBUbi3S7pUsgCB28q");
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
    var keyStore = KeyStoreModel(
      publicKey: 'edpkuh9tUmMMVKJVqG4bJxNLsCob6y8wXycshi6Pn11SQ5hx7SAVjf',
      secretKey:
          'edskRs9KBdoU675PBVyHdM3fqixemkykm7hgHeXAYKUjdoVn3Aev8dP11p47zc4iuWJsefSP4t2vdHPoQisQC3DjZY3ZbbSP9Y',
      publicKeyHash: 'tz1LRibbLEEWpaXb4aKrXXgWPvx9ue9haAAV',
    );

    await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
  });

  test('send-Transaction-Operation', () async {
    var keyStore = KeyStoreModel(
      publicKey: 'edpkuK9UBHsuC6sECF6Zmqedt4Gx8jQJyEuXiG7CaJo4BBZRd6LvP2',
      secretKey:
          'edskRdnByVjgf2wVJo2VTFVu9GV23pwdEhaeywV7h6ZM4geepV3hmCTr97oEdYHbPNmK8PZVQ59oW1unoTm89RjCZu4oriGFg7',
      publicKeyHash: 'tz1iUgGzt7gukNEqiJz78zvoFJEKeBZRCdLQ',
    );

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    print(signer);
    const server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendTransactionOperation(
      server,
      signer,
      keyStore,
      'KT1VCczKAoRQJKco7NiSaB93PMkYCbL2z1K7',
      500000,
      1500,
    );
    print(result['operationGroupID']);
    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  test('send-Delegation-Operation', () async {
    var keyStore = KeyStoreModel(
      publicKey: 'edpkuK9UBHsuC6sECF6Zmqedt4Gx8jQJyEuXiG7CaJo4BBZRd6LvP2',
      secretKey:
          'edskRdnByVjgf2wVJo2VTFVu9GV23pwdEhaeywV7h6ZM4geepV3hmCTr97oEdYHbPNmK8PZVQ59oW1unoTm89RjCZu4oriGFg7',
      publicKeyHash: 'tz1iUgGzt7gukNEqiJz78zvoFJEKeBZRCdLQ',
    );

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    print(signer);
    const server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendDelegationOperation(
      server,
      signer,
      keyStore,
      'KT1VCczKAoRQJKco7NiSaB93PMkYCbL2z1K7',
      10000,
    );

    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  test('getContractStorage', () async {
    var result = await TezsterDart.getContractStorage(
        'https://mainnet.tezster.tech', 'KT1GRSvLoikDsXujKgZPsGLX8k8VvR2Tq95b');
    print(result);
    expect(result != null, true);
  });

  test('getValueForBigMapKey', () async {
    var accountHex =
        '0x${TezsterDart.writeAddress("KT1VYsVfmobT7rsMVivvZ4J8i3bPiqz12NaH")}';
    print(accountHex);
    var packedKey = TezsterDart.encodeBigMapKey(TezsterDart.writePackedData(
        '$accountHex', '',
        format: TezosParameterFormat.Michelson));
    print(packedKey);
    var storage = await TezsterDart.getValueForBigMapKey(
        "https://mainnet.tezster.tech", "1453", packedKey);
    print(storage);
  });

  // var packedKey = TezsterDart.encodeBigMapKey(TezsterDart.writePackedData(
  //       '0x${TezsterDart.writeAddress("KT1GRSvLoikDsXujKgZPsGLX8k8VvR2Tq95b")}',
  //       '',
  //       format: TezosParameterFormat.Michelson));
  //   print(packedKey);

  test('send token', () async {
    var keyStore = KeyStoreModel(
      publicKeyHash: 'tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C',
      publicKey: 'edpktjBAyr2Zyns59K6VGuCkPY32PQdAGbe5fR3YvBML6gifZQkv1e',
      secretKey:
          'edskS86RQn9HM3KMAzFhvXnDPDy9Tfv4ao8peZcqMB2KnLEHnaGLbvNueWGysKamE3NkbZEmcdQvG1KxvQgXeFJjb313o28Urc',
    );
    var rpc = "https://testnet.tezster.tech";
    // tezsureApi,
    var receiver = "tz1RWLHsfDcXzU2Y3BkWYwxvG2oeeqgH6p8y";
    var contractAddress = "KT1JCq5sWnE8EivqhY7RuNSHgC5injKYLUCT";
    var amount = 20;
    var decimals = 18;
    var _amount = (amount *
            double.parse(1.toStringAsFixed(decimals ?? 0).replaceAll('.', '')))
        .toInt();
    var transactionSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

    var result = await TezsterDart.sendContractInvocationOperation(
      rpc,
      transactionSigner,
      keyStore,
      contractAddress,
      0,
      100000,
      1000,
      100000,
      'transfer',
      // FA1.2
      """(Pair "${keyStore.publicKeyHash}" (Pair "$receiver" $_amount))""",
      // FA2
      // """{Pair "${keyStore.publicKeyHash}" {Pair "$receiver" (Pair 0 $_amount)}}""",
      // """(Right (Right (Left (Right (Pair "" (Pair "" $_amount))))))""",
      codeFormat: TezosParameterFormat.Michelson,
    );

    print(result);
    expect(result != null, true);
  });

  test('Test Michelin to Hex', () {
    var micheline = TezosLanguageUtil.translateMichelsonToMicheline(
        """{Pair "tz1USmQMoNCUUyk4BfeEGUyZRK2Bcc9zoK8C" {Pair "tz1XPAqaxaentpo8e295W7hjr696sq9XHzHj" (Pair 0 500000000000000000)}}""");
    print(micheline);
    var data = TezosLanguageUtil.translateMichelineToHex(micheline);
    print(data);
    print("it's working..");
  });
}
