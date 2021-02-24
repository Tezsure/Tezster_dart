# tezster_dart

[![Star on GitHub](https://img.shields.io/github/stars/Tezsure/tezster_dart?style=flat&logo=github&colorB=green&label=stars)](https://github.com/Tezsure/tezster_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Github issues](https://img.shields.io/github/issues/Tezsure/tezster_dart)](https://github.com/Tezsure/tezster_dart/issues?q=is%3Aissue+is%3Aopen+)

[![Tezster banner](https://tezster.s3-ap-southeast-1.amazonaws.com/TEZSTER_CLI/1_jDB5enULQVo2UfeiwD32qA.png)](https://github.com/Tezsure)
A library for building decentralized applications in Flutter, currently focused on the Tezos platform. Tezster_dart package contains all the function that is required to build tezos application.

## What is Tezos

Tezos is a decentralized blockchain that governs itself by establishing a true digital commonwealth. It facilitates formal verification, a technique which mathematically proves the correctness of the code governing transactions and boosts the security of the most sensitive or financially weighted smart contracts.

### Features

* Tezos wallet utilities.
  * Get Balance.
  * Generate mnemonics.
  * Generate keys from mnemonic.
  * Generate keys from mnemonics and passphrase.
  * Sign Operation Group.
  * Unlock fundraiser identity.
  * Transfer Balance.
  * Delegate an Account.
  * Deploy a contract.
  * Call a contract.
  * Operation confirmation.
  * Activating a fundraiser account
  * Reveal an account
  
### Getting started

Check out the [example](https://github.com/Tezsure/tezster_dart/tree/master/example) directory for a sample app for using Tezster_dart.

### Import using

``` dart
import 'package:tezster_dart/tezster_dart.dart';
```

### Usage

* Get Balance

``` dart
String balance = await TezsterDart.getBalance('tz1c....ozGGs', 'your rpc server');
```

* Generate mnemonic

``` dart
String mnemonic = TezsterDart.generateMnemonic(); // sustain laugh capital drop brush artist ahead blossom bread spring motor other mountain thumb volcano engine shed guilt famous loud force hundred same brave
```

* Generate keys from mnemonic

``` dart
List<String> keys = await TezsterDart.getKeysFromMnemonic(mnemonic: "Your Mnemonic");

/* [edskRdVS5H9YCRAG8yqZkX2nUTbGcaDqjYgopkJwRuPUnYzCn3t9ZGksncTLYe33bFjq29pRhpvjQizCCzmugMGhJiXezixvdC,
   edpkuLog552hecagkykJ3fTvop6grTMhfZY4TWbvchDWdYyxCHcrQL,
   tz1g85oYHLFKDpNfDHPeBUbi3S7pUsgCB28q] */
```

* Create / Unlock identity from mnemonic and passphrase.

``` dart
List<String> identityWithMnemonic = await TezsterDart.getKeysFromMnemonicAndPassphrase(
      mnemonic: "your mnemonic",
      passphrase: "pa$\$w0rd");

/* [edskS9kdgvCWDiZL1yP1qH5xLCWYHQub4qibfU8DQZjv7wX7BskxSsL6h9j1yDYJ7Y9jDbMULNmfLhw9vBJPqDw3TeVHHd34w7,
    edpkuRr9yHChSt2MTWHCeHe2JM3zJZxHgj8vEANwb8WENrZbLxYzbx,
    tz1hTe7oxtQr67dg6dWfTX3V44oPY7pzkFZS] */
```

* Sign operation with private key and forged operation

``` dart
List<String> signOperationGroup = await TezsterDart.signOperationGroup(
    privateKey: "edskRdV..... .XezixvdA",
    forgedOperation: "713cb068fe.... .b940ee");

/* [edsigtrBnsjSngfP6LULUDeo84eJVks4LWReYrZBUjKQNJjhVsG7bksqZ7CKnRePMceMe3vgRHHbyd2CqRdC8iEAK5NcyNn4iEB,
    713cb068fe3ac078351727eb5c34279e22b75b0cf4dc0a8d3d599e27031db136040cb9f9da085607c05cac1ca4c62a3f3cfb
    8146aa9b7f631e52f877a1d363474404da8130b0b940ee8c7ce5bf2968c1204c1c4b2ba98bcbd08fc4ad3cad706d39ac55e4
    dd61fde5a8496840ce2d377389a4ca7842bf613d3f096fda819c26e43adfb0cad1336a430d] */
```

* Unlock fundraiser identity.

``` dart
List<String> identityFundraiser = await TezsterDart.unlockFundraiserIdentity(
    mnemonic: "your mnemonic",
    email: "test@example.com",
    password: "pa$\$w0rd");

/* [edskRzNDm2dpqe2yd5zYAw1vmjr8sAwMubfcXajxdCNNr4Ud39BoppeqMAzoCPmb14mzfXRhjtydQjCbqU2VzWrsq6JP4D9GVb,
    edpkvASxrq16v5Awxpz4XPTA2d6QFaCL8expPrPNcVgVbWxT84Kdw2,
    tz1hhkSbaocSWm3wawZUuUdX57L3maSH16Pv] */
```

* Transfer Balance.
    * The most basic operation on the chain is the transfer of value between two accounts.  In this example we have the account we activated above: tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy and some random testnet address to test with: tz1RVcUP9nUurgEJMDou8eW3bVDs6qmP5Lnc. Note all amounts are in µtz, as in micro-tez, hence 0.5tz is represented as 500000. The fee of 1500 was chosen arbitrarily, but some operations have minimum fee requirements.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKey: 'edpkvQtuhdZQmjdjVfaY9Kf4hHfrRJYugaJErkCGvV3ER1S7XWsrrj',
      secretKey:
          'edskRgu8wHxjwayvnmpLDDijzD3VZDoAH7ZLqJWuG4zg7LbxmSWZWhtkSyM5Uby41rGfsBGk4iPKWHSDniFyCRv3j7YFCknyHH',
      publicKeyHash: 'tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy',
    );

var signer = await TezsterDart.createSigner(
    TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    
var result = await TezsterDart.sendTransactionOperation(
      server,
      signer,
      keyStore,
      'tz1RVcUP9nUurgEJMDou8eW3bVDs6qmP5Lnc',
      500000,
      1500,
    );

print("Applied operation ===> $result['appliedOp']");
print("Operation groupID ===> $result['operationGroupID']");

```

* Delegate an Account.
    * One of the most exciting features of Tezos is delegation. This is a means for non-"baker" (non-validator) accounts to participate in the on-chain governance process and receive staking rewards. It is possible to delegate both implicit and originated accounts. For implicit addresses, those starting with tz1, tz2 and tz3, simply call sendDelegationOperation. Originated accounts, that is smart contracts, must explicitly support delegate assignment, but can also be deployed with a delegate already set.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKey: 'edpkvQtuhdZQmjdjVfaY9Kf4hHfrRJYugaJErkCGvV3ER1S7XWsrrj',
      secretKey:
          'edskRgu8wHxjwayvnmpLDDijzD3VZDoAH7ZLqJWuG4zg7LbxmSWZWhtkSyM5Uby41rGfsBGk4iPKWHSDniFyCRv3j7YFCknyHH',
      publicKeyHash: 'tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy',
    );

var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var result = await TezsterDart.sendDelegationOperation(
      server,
      signer,
      keyStore,
      'tz1RVcUP9nUurgEJMDou8eW3bVDs6qmP5Lnc',
      10000,
    );

print("Applied operation ===> $result['appliedOp']");
print("Operation groupID ===> $result['operationGroupID']");

```

* Deploy a contract.
    * With this release we are excited to include the feature of trestles chain interactions, including contract deployment a user can directly write smart contracts in Michelson language and deploy it on Tezos chain using the `sendContractOriginationOperation()` method in return you'll get an origination id of the deployed contract that can be use to track the contract on chain. We have set an example for you below.

``` dart
var server = '';

var contract = """parameter string;
    storage string;
    code { DUP;
        DIP { CDR ; NIL string ; SWAP ; CONS } ;
        CAR ; CONS ;
        CONCAT;
        NIL operation; PAIR}""";

var storage = '"Sample"';

var keyStore = KeyStoreModel(
      publicKey: 'edpkvQtuhdZQmjdjVfaY9Kf4hHfrRJYugaJErkCGvV3ER1S7XWsrrj',
      secretKey:
          'edskRgu8wHxjwayvnmpLDDijzD3VZDoAH7ZLqJWuG4zg7LbxmSWZWhtkSyM5Uby41rGfsBGk4iPKWHSDniFyCRv3j7YFCknyHH',
      publicKeyHash: 'tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy',
    );

var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

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

print("Operation groupID ===> $result['operationGroupID']");

```
reference link: `https://github.com/Tezsure/Tezster_dart/blob/master/example/lib/main.dart#L110`
<br>

* Call a contract.
    * We have also included the feature to call or invoke a deployed contract just use the inbuilt `sendContractInvocationOperation()` method in return you'll get an origination id of the invoked contract that can be used to track the contracts on chain. We have set an example for you below.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKey: 'edpkvQtuhdZQmjdjVfaY9Kf4hHfrRJYugaJErkCGvV3ER1S7XWsrrj',
      secretKey:
          'edskRgu8wHxjwayvnmpLDDijzD3VZDoAH7ZLqJWuG4zg7LbxmSWZWhtkSyM5Uby41rGfsBGk4iPKWHSDniFyCRv3j7YFCknyHH',
      publicKeyHash: 'tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy',
    );

var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var contractAddress = 'KT1KA7DqFjShLC4CPtChPX8QtRYECUb99xMY';

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

print("Operation groupID ===> $result['operationGroupID']");

```
reference link: `https://github.com/Tezsure/Tezster_dart/blob/master/example/lib/main.dart#L141`
<br>

* Operation confirmation.
    * No wonder it's really important to await for confirmation for any on chain interactions. Hence, we have provided `awaitOperationConfirmation()` method with this release that developers can leverage for their advantage to confirm the originated contract's operations id. We have set an example for you how to use it.

``` dart
var server = '';

var network = 'carthagenet';

var serverInfo = {
      'url': '',
      'apiKey': '',
      'network': network
    };

var contract = """parameter string;
    storage string;
    code { DUP;
        DIP { CDR ; NIL string ; SWAP ; CONS } ;
        CAR ; CONS ;
        CONCAT;
        NIL operation; PAIR}""";

var storage = '"Sample"';

var keyStore = KeyStoreModel(
      publicKey: 'edpkvQtuhdZQmjdjVfaY9Kf4hHfrRJYugaJErkCGvV3ER1S7XWsrrj',
      secretKey:
          'edskRgu8wHxjwayvnmpLDDijzD3VZDoAH7ZLqJWuG4zg7LbxmSWZWhtkSyM5Uby41rGfsBGk4iPKWHSDniFyCRv3j7YFCknyHH',
      publicKeyHash: 'tz1QSHaKpTFhgHLbqinyYRjxD5sLcbfbzhxy',
    );

var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

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

print("Operation groupID ===> $result['operationGroupID']");

var groupId = result['operationGroupID'];

var conseilResult = await TezsterDart.awaitOperationConfirmation(
        serverInfo, network, groupId, 5);

print('Originated contract at ${conseilResult['originated_contracts']}');

```
reference link: `https://github.com/Tezsure/Tezster_dart/blob/master/example/lib/main.dart#L162`
<br>

* Activating a fundraiser account 
    * A fundraiser account needs to be activated to be used for any operation. Hence, we have included the facility to activate a faucet account. All the user has to do is call the `sendIdentityActivationOperation()` method and viola the faucet or a fundraiser account will be activated. We have set an example for you how to use it.

``` dart
var server = '';

var faucetKeyStore = KeyStoreModel(
      publicKeyHash: 'tz1ga.....trZNA6A',
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

var keys = await TezsterDart.unlockFundraiserIdentity(
        email: faucetKeyStore.email,
        passphrase: faucetKeyStore.password,
        mnemonic: faucetKeyStore.seed.join(' '));

faucetKeyStore
      ..publicKey = keys[1]
      ..secretKey = keys[0]
      ..publicKeyHash = keys[2];

var activationOperationSigner = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(faucetKeyStore.secretKey, 'edsk'));

var activationOperationResult =
        await TezsterDart.sendIdentityActivationOperation(server,
            activationOperationSigner, faucetKeyStore, faucetKeyStore.secret);

print('${activationOperationResult['operationGroupID']}');
```
<br>

* Reveal an account
    * Once a fundraiser account has been activated it needs to be revealed on-chain. Hence, we have included the facility to reveal the faucet/fundraiser account all you have to do is call the `sendKeyRevealOperation()` method, and voila it’s revealed. We have set an example for you how to use it.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKeyHash: 'tz1U.....W5MHgi',
      secretKey:
          'edskRp......bL2B6g',
      publicKey: 'edpktt.....U1gYJu2',
    );

var signer = await TezsterDart.createSigner(
        TezsterDart.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var result =
        await TezsterDart.sendKeyRevealOperation(server, signer, keyStore);

print('${result['operationGroupID']}');
```
<br>

---
**NOTE:**
Use stable version of flutter to avoid package conflicts.

---

### Feature requests and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/Tezsure/tezster_dart/issues/new). If you want to contribute to this libary, please submit a Pull Request.