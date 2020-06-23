import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

class NodeWriterHelper {
  static String _readSignatureWithHint(Uint8List payload, String hint) {
    String encodedPayoad = hex.encode(payload);
    String concatEncodedPayload = '09f5cd8612' + encodedPayoad;
    String encodedPayoadToHexString =
        hex.encode(concatEncodedPayload.codeUnits);
    Uint8List finlaListForBS58CHECK = hex.decode(encodedPayoadToHexString);
    if (hint == 'edsig') {
      return bs58check.encode(finlaListForBS58CHECK);
    } else {
      throw {"messgae": "Unrecognized key hint, '$hint'"};
    }
  }
}
