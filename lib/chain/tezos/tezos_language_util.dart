import 'package:tokenizer/tokenizer.dart';

class TezosLanguageUtil {
  static String normalizeMichelineWhiteSpace(String fragment) {
    return fragment
        .replaceAll(new RegExp(r'/\n/g'), ' ')
        .replaceAll(new RegExp(r'/ +/g'), ' ')
        .replaceAll(new RegExp(r'/\[{/g'), '[ {')
        .replaceAll(new RegExp(r'/}\]/g'), '} ]')
        .replaceAll(new RegExp(r'/},{/g'), '}, {')
        .replaceAll(new RegExp(r'/\]}/g'), '] }')
        .replaceAll(new RegExp(r'/":"/g'), '": "')
        .replaceAll(new RegExp(r'/":\[/g'), '": [')
        .replaceAll(new RegExp(r'/{"/g'), '{ "')
        .replaceAll(new RegExp(r'/"}/g'), '" }')
        .replaceAll(new RegExp(r'/,"/g'), ', "')
        .replaceAll(new RegExp(r'/","/g'), '", "')
        .replaceAll(new RegExp(r'/\[\[/g'), '[ [')
        .replaceAll(new RegExp(r'/\]\]/g'), '] ]')
        .replaceAll(new RegExp(r'/\["/g'), '\[ "')
        .replaceAll(new RegExp(r'/"\]/g'), '" \]')
        .replaceAll(new RegExp(r'/\[ +\]/g'), '\[\]')
        .trim();
  }

  static String translateMichelsonToMicheline(String code) {
      final tokenizer = Tokenizer({'{'});

  }
}
