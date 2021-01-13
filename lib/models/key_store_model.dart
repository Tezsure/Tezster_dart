import 'package:flutter/cupertino.dart';

class KeyStoreModel {
  String publicKey;
  String secretKey;
  String publicKeyHash;
  String seed;

  KeyStoreModel(
      {@required this.publicKey,
      @required this.secretKey,
      @required this.publicKeyHash,
      this.seed});
}
