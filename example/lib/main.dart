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
    //Generate mnemonic
    String mnemonic = TezsterDart
        .generateMnemonic(); // strength is optional, by default it's 256 ==> Generates 24 words.
    print("mnemonic ===> $mnemonic");
    //mnemonic ===> 24 random words, [If strength parameter is changed the words length differs.]

    //Generate keys from mnemonic
    List<String> keys = await TezsterDart.getKeysFromMnemonic(
      mnemonic:
          "luxury bulb roast timber sense stove sugar sketch goddess host meadow decorate gather salmon funny person canoe daring machine network camp moment wrong dice",
    );
    print("keys ===> $keys");
    //keys ===> [privateKey, publicKey, publicKeyHash]
    //Accessing: private key ===> keys[0] | public key ===> keys[1] | public Key Hash ===> identity[2] all of type string

    //Create / Unlock identity from mnemonic and passphrase.
    List<String> identity = await TezsterDart.getKeysFromMnemonicAndPassphrase(
      mnemonic:
          "cannon rabbit obvious drama slogan net acoustic donor core acoustic clinic poem travel plunge winter",
      passphrase: "5tjpU0cimq",
    );
    print("identity ===> $identity");
    // identityWithMnemonic ===> [privateKey, publicKey, publicKeyHash]
    // Accessing: private key ===> identity[0] | public key ===> identity[1] | public Key Hash ===> identity[2] all of type string.

    //Restore account from secret key
    List<String> restoredKeys = TezsterDart.getKeysFromSecretKey(
        "edskRrDH2TF4DwKU1ETsUjyhxPC8aCTD6ko5YDguNkJjRb3PiBm8Upe4FGFmCrQqzSVMDLfFN22XrQXATcA3v41hWnAhymgQwc");
    print("Restored account keys ===> $restoredKeys");
    // restoredKeys ===> [privateKey, publicKey, publicKeyHash]
    // Accessing: private key ===> restoredKeys[0] | public key ===> restoredKeys[1] | public Key Hash ===> restoredKeys[2] all of type string.

    //Sign operation with public-Key and forged operation
    List<String> signOpGrp = await TezsterDart.signOperationGroup(
      privateKey:
          "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC",
      forgedOperation:
          "713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb8146aa9b7f631e52f877a1d363474404da8130b0b940ee",
    );
    print("signOperationGroup ===> $signOpGrp");
    //signOperationGroup ===> [hexSignature, signedOpBytes]
    //Accessing: hex signature ===> signOpGrp[0] | signed Operation bytes ===> signOpGrp[1] all of type string

    //Unlock fundraiser identity.
    List<String> identityFundraiser =
        await TezsterDart.unlockFundraiserIdentity(
      mnemonic:
          "cannon rabbit obvious drama slogan net acoustic donor core acoustic clinic poem travel plunge winter",
      email: "lkbpoife.tobqgidu@tezos.example.org",
      passphrase: "5tjpU0cimq",
    );
    print("identityFundraiser ===> $identityFundraiser");
    //identityFundraiser ===> [privateKey, publicKey, publicKeyHash]
    //Accessing: private key ===> identityFundraiser[0] | public key ===> identityFundraiser[1] | public Key Hash ===> identityFundraiser[2] all of type string.

    // Get Balance
    String balance =
        await TezsterDart.getBalance('tz1c....ozGGs', 'your rpc server');
    print("Accoutn Balance ===> $balance");

    var server = '';

    var keyStore = KeyStoreModel(
      publicKey: 'edpkvQtuhdZQmjdjVfaY9Kf4hHfrRJYugaJErkCGvV3ER1S7XWsrrj',
      secretKey:
          'edskRgu8wHxjwayvnmpLDDijzD3VZDoAH7ZLqJWuG4zg7LbxmSWZWhtkSyM5Uby41rGfsBGk4iPKWHSDniFyCRv3j7YFCknyHH',
      publicKeyHash: 'tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy',
    );

    //Send transaction
    var transactionSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    var transactionResult = await TezsterDart.sendTransactionOperation(
      server,
      transactionSigner,
      keyStore,
      'tz1RVcUP9nUurgEJMDou8eW3bVDs6qmP5Lnc',
      500000,
      1500,
    );
    print("Applied operation ===> ${transactionResult['appliedOp']}");
    print("Operation groupID ===> ${transactionResult['operationGroupID']}");

    //Send delegation
    var delegationSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    var delegationResult = await TezsterDart.sendDelegationOperation(
      server,
      delegationSigner,
      keyStore,
      'tz1RVcUP9nUurgEJMDou8eW3bVDs6qmP5Lnc',
      10000,
    );
    print("Applied operation ===> ${delegationResult['appliedOp']}");
    print("Operation groupID ===> ${delegationResult['operationGroupID']}");

    // restore identity from derivation path and mnemonic
    List<String> revoceredKeys =
        await TezsterDart.restoreIdentityFromDerivationPath("m/44'/1729'/0'/0'",
            "curious roof motor parade analyst riot chronic actor pony random ring slot");
    print("revoceredKeys ===> $revoceredKeys");
    //revoceredKeys ===> [privateKey, publicKey, publicKeyHash]
    //Accessing: private key ===> revoceredKeys[0] | public key ===> revoceredKeys[1] | public Key Hash ===> revoceredKeys[2] all of type string.

    //Deploy a contract
    var contract = """parameter string;
    storage string;
    code { DUP;
        DIP { CDR ; NIL string ; SWAP ; CONS } ;
        CAR ; CONS ;
        CONCAT;
        NIL operation; PAIR}""";

    var storage = '"Sample"';
    var contractOriginationSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

    var resultContractOrigination =
        await TezsterDart.sendContractOriginationOperation(
      server,
      contractOriginationSigner,
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

    print(
        "Operation groupID ===> ${resultContractOrigination['operationGroupID']}");

    //Call a contract
    var contractInvocationSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

    var contractAddress = 'KT1KA7DqFjShLC4CPtChPX8QtRYECUb99xMY';

    var resultInvoke = await TezsterDart.sendContractInvocationOperation(
        server,
        contractInvocationSigner,
        keyStore,
        contractAddress,
        10000,
        100000,
        1000,
        100000,
        '',
        '"Cryptonomicon"',
        codeFormat: TezosParameterFormat.Michelson);

    print("Operation groupID ===> ${resultInvoke['operationGroupID']}");

    //Await opration Confirmation
    var network = 'carthagenet';

    var serverInfo = {'url': '', 'apiKey': '', 'network': network};

    var operationConfirmationSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

    var resultoperationConfirmation =
        await TezsterDart.sendContractOriginationOperation(
      server,
      operationConfirmationSigner,
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

    print(
        "Operation groupID ===> ${resultoperationConfirmation['operationGroupID']}");

    var groupId = resultoperationConfirmation['operationGroupID'];

    var conseilResult = await TezsterDart.awaitOperationConfirmation(
        serverInfo, network, groupId, 5);

    print('Originated contract at ${conseilResult['originated_contracts']}');

    //Activating a fundraiser account
    var faucetKeyStore = KeyStoreModel(
      publicKeyHash: '',
      seed: [
        "wife",
        "filter",
        "wage",
        "thunder",
        "forget",
        "scale",
        "punch",
        "mammal",
        "offer",
        "car",
        "cash",
        "defy",
        "vehicle",
        "romance",
        "green"
      ],
      secret: '',
      email: '',
      password: '',
    );

    var faucetKeys = await TezsterDart.unlockFundraiserIdentity(
        email: faucetKeyStore.email,
        passphrase: faucetKeyStore.password,
        mnemonic: faucetKeyStore.seed.join(' '));
    faucetKeyStore
      ..publicKey = faucetKeys[1]
      ..secretKey = faucetKeys[0]
      ..publicKeyHash = faucetKeys[2];
    var activationOperationSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(faucetKeyStore.secretKey, 'edsk'));
    var activationOperationResult =
        await TezsterDart.sendIdentityActivationOperation(server,
            activationOperationSigner, faucetKeyStore, faucetKeyStore.secret);
    print('${activationOperationResult['operationGroupID']}');

    //Reveal an account
    var keyRevealKeyStore = KeyStoreModel(
      publicKeyHash: 'tz1Uey......FDPWW5MHgi',
      secretKey: 'edskRpg......EjHx8ebL2B6g',
      publicKey: 'edpktt......gYJu2',
    );

    var keyRevealSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyRevealKeyStore.secretKey, 'edsk'));

    var keyRevealResult = await TezsterDart.sendKeyRevealOperation(
        server, keyRevealSigner, keyRevealKeyStore);

    print('${keyRevealResult['operationGroupID']}');
  }

  @override
  void initState() {
    super.initState();
    tezosWalletUtil();
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
