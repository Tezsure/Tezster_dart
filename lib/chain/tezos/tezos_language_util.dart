
import 'package:tezster_dart/michelson_parser/michelson_parser.dart';

class TezosLanguageUtil {
  static String translateMichelsonToMicheline(String code) {
    // jsonDecode()
    var result = MichelsonParser.parseMichelson(code);
    return result;
  }

  static String translateMichelineToHex(p) {
    return MichelsonParser.translateMichelineToHex(p);
  }
}
