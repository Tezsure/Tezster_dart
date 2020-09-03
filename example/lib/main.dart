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
  }

  tezosNodeWriter() async {
    String testNetServer = "https://testnet.tezster.tech";

    //Working functions
    dynamic response = await TezsterNodeReader.performGetRequest(
      server: testNetServer,
      command: "chains/main/blocks",
    );
    print("Response ===> $response");

    dynamic getBlock = await TezsterNodeReader.getBlock(
      server: testNetServer,
      hash: "head",
      chainid: "NetXjD3HPJJjmcd",
    );
    print("GET-Block ===> $getBlock");

    dynamic blockhead = await TezsterNodeReader.getBlockHead(
      server: testNetServer,
    );
    print("Block-Head ===> $blockhead");

    dynamic getCounterForAccount = await TezsterNodeReader.getCounterForAccount(
      server: testNetServer,
      accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
      chainid: "NetXjD3HPJJjmcd",
    );
    print("GET-Counter-ForAccount ===> $getCounterForAccount");

    dynamic getMempoolOperation = await TezsterNodeReader.getMempoolOperation(
      server: testNetServer,
      chainid: "NetXjD3HPJJjmcd",
      operationGroupId: "opAPztkmYpEG754JGjkKi4snUTaa879fvgWfGFeDrdmTAbaoLNp",
    );
    print("GET-MempoolOperation ===> $getMempoolOperation");

    dynamic getSpendableBalanceForAccount =
        await TezsterNodeReader.getSpendableBalanceForAccount(
      server: testNetServer,
      accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
      chainid: "NetXjD3HPJJjmcd",
    );
    print(
        "GET-SpendableBalance-ForAccount ===> $getSpendableBalanceForAccount");

    dynamic getBalance = await TezsterNodeReader.getBalance(
      accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
      server: testNetServer,
    );
    print("Get-Balance ===> $getBalance");

    dynamic getMempoolOperationsForAccount =
        await TezsterNodeReader.getMempoolOperationsForAccount(
      server: testNetServer,
      chainid: "NetXjD3HPJJjmcd",
      accountHash: "tz1Y8zdtVe2wWe7QdNTnAdwBceqYBCdA3Jj8",
    );
    print(
        "GET-MempoolOperations-ForAccount ===> $getMempoolOperationsForAccount");

    bool isRevealed = await TezsterNodeReader.isManagerKeyRevealedForAccount(
      server: "https://testnet.tezster.tech/",
      accountHash: 'tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx',
    );
    print("isRevealed ===> $isRevealed");

//Yet to be tested
    // dynamic getAccForBlock = await TezsterNodeReader.getAccountForBlock(
    //   server: testNetServer,
    //   accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
    //   blockHash: "",
    //   chainid: "NetXjD3HPJJjmcd",
    // );
    // print("GET-Acc-ForBlock ===> $getAccForBlock");

    // dynamic getAccountManagerForBlock =
    //     await TezsterNodeReader.getAccountManagerForBlock(
    //   server: testNetServer,
    //   chainid: "NetXjD3HPJJjmcd",
    //   accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
    //   block: "",
    // );
    // print("GET-Account-Manager-ForBlock ===> $getAccountManagerForBlock");

    // dynamic isImplicitAndEmpty = await TezsterNodeReader.isImplicitAndEmpty(
    //   server: testNetServer,
    //   accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
    // );
    // print("Is-ImplicitAndEmpty ===> $isImplicitAndEmpty");

    // dynamic getContractStorage = await TezsterNodeReader.getContractStorage(
    //   server: testNetServer,
    //   accountHash: "tz1ZfFASQvmmz47ru5nn9GhX5oswCRVX5z1r",
    //   block: "",
    //   chainid: "NetXjD3HPJJjmcd",
    // );
    // print("GET-Contract-Storage ===> $getContractStorage");

    // dynamic getValueForBigMapKey = await TezsterNodeReader.getValueForBigMapKey(
    //   server: testNetServer,
    //   key: "",
    //   block: "",
    //   chainid: "NetXjD3HPJJjmcd",
    //   index: 1,
    // );
    // print("GET-Value-ForBigMapKey ===> $getValueForBigMapKey");
  }

  nodeWriter() async {
    Activation activation = Activation(
      pkh: "tz1hhkSbaocSWm3wawZUuUdX57L3maSH16Pv",
      secret: "9802d2dcc227576700acf963979792d0abf53340",
    );

    Reveal reveal = Reveal(
      gasLimit: "129",
      storageLimit: "10",
      counter: "213",
      fee: "100",
      publicKey: "edpkuLog552hecagkykJ3fTvop6grTMhfZY4TWbvchDWdYyxCHcrQL",
      source: "tz1VwWdetdADCEMySCumYXWtvf9pZQV3CmE5",
    );

    Transaction transaction = Transaction(
      contractParameters: ContractParameters(
        entrypoint: "",
        value: "",
      ),
      amount: "",
      counter: "",
      destination: "",
      fee: "",
      gasLimit: "",
      source: "",
      storageLimit: "",
    );

    Ballot ballot = Ballot(
      period: 1,
      proposal: "",
      source: "",
      vote: 0,
    );

    var sendOP = TezsterSendOperation.sendTransactionOperation(
      server: 'https://testnet.tezster.tech/',
      amount: 10,
      fee: 2,
      to: 'tz1PrMATKhpXz81CnEZL2sudhVmhbz8W7Lm5',
      derivationPath: "",
      keyStore: KeyStore(
        publicKey: 'edpkuBknW28nW72KG6RoHtYW7p12T6GKc7nAbwYX5m8Wd9sDVC9yav',
        privateKey:
            'edskRuR1azSfboG86YPTyxrQgosh5zChf5bVDmptqLTb5EuXAm9rsnDYfTKhq7rDQujdn5WWzwUMeV3agaZ6J2vPQT58jJAJPi',
        publicKeyHash: 'tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx',
        seed: '',
        storeType: StoreType.mnemonic,
      ),
    );
    print("sendOP ===> $sendOP");

    //Sign operation with public-Key and forged operation
    // List<String> signOpGrp = await TezsterDart.signOperationGroup(
    //   privateKey:
    //       "edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC",
    //   forgedOperation:
    //       "713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb8146aa9b7f631e52f877a1d363474404da8130b0b940ee",
    // );
    // print("signOpGrp ==> $signOpGrp");

    // dynamic getBlock = await TezsterNodeReader.getBlock(
    //   server: 'https://testnet.tezster.tech/',
    //   hash: "head",
    //   chainid: "NetXjD3HPJJjmcd",
    // );
    // print("GET-Block ===> $getBlock");

    // String activationData = TezsterNodeWriter.forgeOperations(
    //   branch: "BLjxPLCWUuFBewguqrojaHhgAcc8jLZneFkpnrVVcYn2zQz4pmW",
    //   operation: activation,
    // );
    // print("activationData => $activationData");

    // String revealData = TezsterNodeWriter.forgeOperations(
    //   branch: "BLjxPLCWUuFBewguqrojaHhgAcc8jLZneFkpnrVVcYn2zQz4pmW",
    //   operation: reveal,
    // );
    // // print("revealData => $revealData");

    // String transactionData = TezsterNodeWriter.forgeOperations(
    //   branch: "BLjxPLCWUuFBewguqrojaHhgAcc8jLZneFkpnrVVcYn2zQz4pmW",
    //   operation: transaction,
    // );
    // // print("transactionData ===> $transactionData");

    // String ballotData = TezsterNodeWriter.forgeOperations(
    //   branch: "BLjxPLCWUuFBewguqrojaHhgAcc8jLZneFkpnrVVcYn2zQz4pmW",
    //   operation: ballot,
    // );
    // print("ballotData ===> $ballotData");

    // String jsonDecod = jsonDecode(
    //     '{"name":{"first":"foo","last":"bar"}, "age":31, "city":"New York"}');
    // print(jsonDecod);

    // String jsonData = TezsterNodeWriter.normalizeMichelineWhiteSpace(jsonDecod);
    // print("JSONDATA ===> $jsonData");

    // var jsonData =
    //     '{"accounting":[{"firstName":"John","lastName":"Doe","age":23},{"firstName":"Mary","lastName":"Smith","age":32}],"sales":[{"firstName":"Sally","lastName":"Green","age":27},{"firstName":"Jim","lastName":"Galley","age":41}]}';

    // String newJsonData =
    //     TezsterNodeWriter.normalizeMichelineWhiteSpace(jsonData);
    // print("newJsonData ==> $newJsonData");
    // // String prettyJson(Map<String, dynamic> json, {int indent = 4}) {
    // //   var spaces = ' ' * indent;
    // //   var encoder = JsonEncoder.withIndent(spaces);
    // //   return encoder.convert(json);
    // // }

    // print(TezsterNodeWriter.prettyJson({
    //   "prim": "Right",
    //   "args": [
    //     {
    //       "prim": "Left",
    //       "args": [
    //         {"prim": "Unit"}
    //       ]
    //     }
    //   ]
    // }));

    // print("newJsonData ===> $newJsonData");
    // var pubkey = TezsterNodeWriter.writePublicKey(
    //     "edpkuLog552hecagkykJ3fTvop6grTMhfZY4TWbvchDWdYyxCHcrQL");
    // print("pubkey ===> $pubkey");
    // TezsterNodeWriter.writeBranch(
    //     "BKzEzxCwQcXBJNHCxGbnq9H8P3aV7EfFZaot54nShmF3YAgwHDj");

    // {
    //   "destination": "KT1LRre6w4EgkCRLwUugQLEdRGPvJdTmx3Ae",
    //   "amount": "10",
    //   "storage_limit": "1000",
    //   "gas_limit": "100000",
    //   "counter": "606113",
    //   "fee": "100000",
    //   "source": "tz1NN5QooJWkW44KFfrXqLRaxEa5Wxw3f9FF",
    //   "kind": "transaction",
    //   "parameters": {
    //     "entrypoint": "default",
    // "value": {
    //   "prim": "Right",
    //   "args": [
    //     {
    //       "prim": "Left",
    //       "args": [
    //         {"prim": "Unit"}
    //       ]
    //     }
    //   ]
    // }
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    // tezosWalletUtil();
    // tezosNodeWriter();
    nodeWriter();
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
