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
  String delegate;
  Map<String, Object> script;

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
    this.delegate,
    this.script,
  }) {
    if (kind == 'delegation') {
      gasLimit = TezosConstants.DefaultDelegationGasLimit;
      storageLimit = TezosConstants.DefaultDelegationStorageLimit;
    }
  }

  Map<String, Object> toJson() => kind == 'delegation'
      ? {
          'counter': counter.toString(),
          'delegate': delegate,
          'fee': fee.toString(),
          'gas_limit': TezosConstants.DefaultDelegationGasLimit.toString(),
          'kind': kind,
          'source': source,
          'storage_limit':
              TezosConstants.DefaultDelegationStorageLimit.toString(),
        }
      : kind == 'origination'
          ? {
              'kind': kind,
              'source': source,
              'fee': fee,
              'counter': counter.toString(),
              'gas_limit': gasLimit.toString(),
              'storage_limit': storageLimit.toString(),
              'balance': amount,
              'delegate': delegate,
              'script': script,
            }
          : {
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
