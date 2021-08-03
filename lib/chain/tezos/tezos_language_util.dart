import 'package:tezster_dart/michelson_parser/michelson_parser.dart';

class TezosLanguageUtil {
  static var primitiveRecordOrder = ["prim", "args", "annots"];

  static String translateMichelsonToMicheline(String code) {
    var result = MichelsonParser.parseMichelson(code);
    return result;
  }

  static String translateMichelineToHex(p) {
    return MichelsonParser.translateMichelineToHex(p);
  }

/*

export function normalizePrimitiveRecordOrder(obj: object)  {
        if (Array.isArray(obj)) {
            return obj.map(normalizePrimitiveRecordOrder);
        }

        if (typeof obj === "object") {
            return Object.keys(obj)
                .sort((k1, k2) => primitiveRecordOrder.indexOf(k1) - primitiveRecordOrder.indexOf(k2))
                .reduce((newObj, key) => ({
                    ...newObj,
                    [key]: normalizePrimitiveRecordOrder(obj[key])
                }), {});
        }
        return obj;
    }

 */

  static dynamic normalizePrimitiveRecordOrder(data) {
    if (data is List) return data.map(normalizePrimitiveRecordOrder).toList();

    if (data is Map) {
      var keys = data.keys.toList();
      keys.sort((k1, k2) =>
          TezosLanguageUtil.primitiveRecordOrder.indexOf(k1) -
          TezosLanguageUtil.primitiveRecordOrder.indexOf(k2));

      data = keys.fold({}, (obj, value) => {...obj, value: data[value]});
    }
    return data;
  }
}
