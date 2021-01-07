import 'package:flutter_test/flutter_test.dart';
import 'package:tezster_dart/tezster_dart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    print(signer);
  });

  test('send-Transaction-Operation', () async {
    var keyStore = KeyStoreModel(
      publicKey: 'edpkuh9tUmMMVKJVqG4bJxNLsCob6y8wXycshi6Pn11SQ5hx7SAVjf',
      secretKey:
          'edskRs9KBdoU675PBVyHdM3fqixemkykm7hgHeXAYKUjdoVn3Aev8dP11p47zc4iuWJsefSP4t2vdHPoQisQC3DjZY3ZbbSP9Y',
      publicKeyHash: 'tz1LRibbLEEWpaXb4aKrXXgWPvx9ue9haAAV',
    );

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    print(signer);
    const server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendTransactionOperation(
      server,
      signer,
      keyStore,
      'tz1LRibbLEEWpaXb4aKrXXgWPvx9ue9haAAV',
      500000,
      1500,
    );
    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });

  test('send-Delegation-Operation', () async {
    var keyStore = KeyStoreModel(
      publicKey: 'edpkunM8fmwNb8NqcKZ1WiBrZQqvuN1NRY3FrSRer9HEySaPAkqgqt',
      secretKey:
          'edskRjFXdYtHUrkLh7cs6b8EQigNi5uFGYxSsC3CgpvaA86Xcvo4TxrcmK155jY3c9hyxaQK8s8cfFXscEUFwdTjhFLf3P5LVX',
      publicKeyHash: 'tz1csxCjsefVvKzWWAvhkoVn3M67wxaozGGs',
    );

    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    print(signer);
    const server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendDelegationOperation(server, signer,
        keyStore, 'tz1RUGhq8sQpfGu1W2kf7MixqWX7oxThBFLr', 10000);

    expect(true,
        result['operationGroupID'] != null && result['operationGroupID'] != '');
  });
}
