import 'package:tezster_dart/chain/tezos/tezos_message_utils.dart';
import 'package:tezster_dart/models/operation_model.dart';

class TezosMessageCodec {
  static String encodeOperation(OperationModel message) {
    if (message.kind == 'transaction') return encodeTransaction(message);
    if (message.kind == 'reveal') return encodeReveal(message);
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
}
