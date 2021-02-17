// All the functions are called in initState(){}
// For reference please check Debug console for outputs.
// Just run the project you must see the print statement outputs in debug console. It may take few seconds to reflect the output.

// NOTE: please get the tezster_dart package under pubspec.yaml before running the project

import 'package:flutter/material.dart';
import 'package:tezster_dart/tezster_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  tezosWalletUtil() async {
    // //Generate mnemonic
    // String mnemonic = TezsterDart
    //     .generateMnemonic(); // strength is optional, by default it's 256 ==> Generates 24 words.
    // print("mnemonic ===> $mnemonic");
    // //mnemonic ===> 24 random words, [If strength parameter is changed the words length differs.]

    // //Generate keys from mnemonic
    // List<String> keys = await TezsterDart.getKeysFromMnemonic(
    //   mnemonic:
    //       "luxury bulb roast timber sense stove sugar sketch goddess host meadow decorate gather salmon funny person canoe daring machine network camp moment wrong dice",
    // );
    // print("keys ===> $keys");
    // //keys ===> [privateKey, publicKey, publicKeyHash]
    // //Accessing: private key ===> keys[0] | public key ===> keys[1] | public Key Hash ===> identity[2] all of type string

    // //Create / Unlock identity from mnemonic and passphrase.
    // List<String> identity = await TezsterDart.getKeysFromMnemonicAndPassphrase(
    //   mnemonic:
    //       "cannon rabbit obvious drama slogan net acoustic donor core acoustic clinic poem travel plunge winter",
    //   passphrase: "5tjpU0cimq",
    // );
    // print("identity ===> $identity");
    // // identityWithMnemonic ===> [privateKey, publicKey, publicKeyHash]
    // // Accessing: private key ===> identity[0] | public key ===> identity[1] | public Key Hash ===> identity[2] all of type string.

    // //Sign operation with public-Key and forged operation
    // List<String> signOpGrp = await TezsterDart.signOperationGroup(
    //   privateKey:
    //       "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC",
    //   forgedOperation:
    //       "713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb8146aa9b7f631e52f877a1d363474404da8130b0b940ee",
    // );
    // print("signOperationGroup ===> $signOpGrp");
    // //signOperationGroup ===> [hexSignature, signedOpBytes]
    // //Accessing: hex signature ===> signOpGrp[0] | signed Operation bytes ===> signOpGrp[1] all of type string

    // //Unlock fundraiser identity.
    // List<String> identityFundraiser =
    //     await TezsterDart.unlockFundraiserIdentity(
    //   mnemonic:
    //       "cannon rabbit obvious drama slogan net acoustic donor core acoustic clinic poem travel plunge winter",
    //   email: "lkbpoife.tobqgidu@tezos.example.org",
    //   passphrase: "5tjpU0cimq",
    // );
    // print("identityFundraiser ===> $identityFundraiser");
    // //identityFundraiser ===> [privateKey, publicKey, publicKeyHash]
    // //Accessing: private key ===> identityFundraiser[0] | public key ===> identityFundraiser[1] | public Key Hash ===> identityFundraiser[2] all of type string.

    var keyStore = KeyStoreModel(
      publicKey: 'edpkuh9tUmMMVKJVqG4bJxNLsCob6y8wXycshi6Pn11SQ5hx7SAVjf',
      secretKey:
          'edskRs9KBdoU675PBVyHdM3fqixemkykm7hgHeXAYKUjdoVn3Aev8dP11p47zc4iuWJsefSP4t2vdHPoQisQC3DjZY3ZbbSP9Y',
      publicKeyHash: 'tz1LRibbLEEWpaXb4aKrXXgWPvx9ue9haAAV',
    );

    var contract = """parameter string;
    storage string;
    code { DUP;
        DIP { CDR ; NIL string ; SWAP ; CONS } ;
        CAR ; CONS ;
        CONCAT;
        NIL operation; PAIR}""";

    var storage = '"Sample"';
    var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

    print(signer);

    var server = 'https://testnet.tezster.tech';

    var result = await TezsterDart.sendContractOriginationOperation(
      server,
      signer,
      keyStore,
      0,
      null,
      100000,
      1000,
      100000,
      contract,
      storage,
      codeFormat: TezosParameterFormat.Michelson,
    );
    var groupId = result['operationGroupID'];
    print("Injected operation group id ${result['operationGroupID']}");

    var network = 'delphinet';
    var serverInfo = {
      'url': 'https://conseil-dev.cryptonomic-infra.tech:443',
      'apiKey': 'f420a571-d526-4252-89e4-d7a2eb7f26b4',
      'network': network
    };

    var conseilResult = await TezsterDart.awaitOperationConfirmation(
        serverInfo, network, groupId, 5);
    print('Originated contract at ${conseilResult['originated_contracts']}');

    var contractAddress = conseilResult['originated_contracts'];

    var resultInvoke = await TezsterDart.sendContractInvocationOperation(
        server,
        signer,
        keyStore,
        contractAddress,
        10000,
        100000,
        1000,
        100000,
        '',
        '"Cryptonomicon"',
        codeFormat: TezosParameterFormat.Michelson);

    print('Injected operation group id ${resultInvoke['operationGroupID']}');
  }

  @override
  void initState() {
    super.initState();
    tezosWalletUtil();
    // runNewTestingDemo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              "Welcome to Tezster_dart package.\n Please check the debug console for the outputs",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
