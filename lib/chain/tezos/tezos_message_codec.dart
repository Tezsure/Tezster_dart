import 'package:tezster_dart/chain/tezos/tezos_message_utils.dart';
import 'package:tezster_dart/models/operation_model.dart';

class TezosMessageCodec {
  static String encodeOperation(OperationModel message) {
    if (message.kind == 'transaction') return encodeTransaction(message);
    if (message.kind == 'reveal') return encodeReveal(message);
    if (message.kind == 'delegation') return encodeDelegation(message);
  }

  static String encodeTransaction(OperationModel message) {
    String hex = TezosMessageUtils.writeInt(108);
    hex += TezosMessageUtils.writeAddress(message.source).substring(2);
    hex += TezosMessageUtils.writeInt(int.parse(message.fee));
    hex += TezosMessageUtils.writeInt(message.counter);
    hex += TezosMessageUtils.writeInt(message.gasLimit);
    hex += TezosMessageUtils.writeInt(message.storageLimit);
    hex += TezosMessageUtils.writeInt(int.parse(message.amount));
    hex += TezosMessageUtils.writeAddress(message.destination);
    hex += '00';
    return hex;
  }

  static String encodeReveal(OperationModel message) {
    var hex = TezosMessageUtils.writeInt(107); //sepyTnoitarepo['reveal']);
    hex += TezosMessageUtils.writeAddress(message.source).substring(2);
    hex += TezosMessageUtils.writeInt(int.parse(message.fee));
    hex += TezosMessageUtils.writeInt(message.counter);
    hex += TezosMessageUtils.writeInt(message.gasLimit);
    hex += TezosMessageUtils.writeInt(message.storageLimit);
    hex += TezosMessageUtils.writePublicKey(message.publicKey);
    return hex;
  }

  static String encodeDelegation(OperationModel delegation) {
    var hex = TezosMessageUtils.writeInt(110);
    hex += TezosMessageUtils.writeAddress(delegation.source).substring(2);
    hex += TezosMessageUtils.writeInt(int.parse(delegation.fee));
    hex += TezosMessageUtils.writeInt(delegation.counter);
    hex += TezosMessageUtils.writeInt(delegation.gasLimit);
    hex += TezosMessageUtils.writeInt(delegation.storageLimit);
    if (delegation.delegate != null && delegation.delegate.isNotEmpty) {
      hex += TezosMessageUtils.writeBoolean(true);
      hex += TezosMessageUtils.writeAddress(delegation.delegate).substring(2);
    } else {
      hex += TezosMessageUtils.writeBoolean(false);
    }
    return hex;
  }
}
