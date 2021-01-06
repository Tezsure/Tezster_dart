import 'package:tezster_dart/helper/constants.dart';

class OperationModel {
  String destination;
  String amount;
  int storageLimit;
  int gasLimit;
  int counter;
  String fee;
  String source;
  String kind;
  String publicKey;

  OperationModel({
    this.destination,
    this.amount,
    this.counter,
    this.fee,
    this.source,
    this.kind = 'transaction',
    this.gasLimit = TezosConstants.DefaultTransactionGasLimit,
    this.storageLimit = TezosConstants.DefaultTransactionStorageLimit,
    this.publicKey,
  });

  Map<String, String> toJson() => {
        'destination': destination,
        'amount': amount,
        'storage_limit': storageLimit.toString(),
        'gas_limit': gasLimit.toString(),
        'counter': counter.toString(),
        'fee': fee,
        'source': source,
        'kind': kind,
      };
}
