import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

class TezsterMessageUtil {
  TezsterMessageUtil._();
  static String twoByteHex(int n) {
    if (n < 128) {
      String hexString = "0" + n.toRadixString(16);
      return hexString.substring(hexString.length - 2);
    }

    String h = '';

    if (n > 2147483648) {
      BigInt r = BigInt.from(n);
      while (r > BigInt.zero) {
        //Review
        String data = ('0' + r.toRadixString(16) + 127.toRadixString(16));
        h = data.substring(data.length - 2) + h;
        r = r >> 7;
      }
    } else {
      int r = n;
      while (r > 0) {
        // Review
        String data = ('0' + (r & 127).toRadixString(16));
        h = data.substring(data.length - 2) + h;
        r = r >> 7;
      }
    }
    return h;
  }

  static String writeInt(int value) {
    if (value < 0) {
      return "Use writeSignedInt to encode negative numbers";
    }

    String twoByteHexString = twoByteHex(value);
    // print("twoByteHexString ==> $twoByteHexString");

    List<int> hexStringToList = hex.decode(twoByteHexString);
    // print("hexStringToList ===> $hexStringToList");

    Uint8List twoByteUint8List = Uint8List.fromList(hexStringToList);
    // print("twoByteUint8List ===> $twoByteUint8List");

    Map mapData = twoByteUint8List.asMap();
    // print("mapData ===> $mapData");

    List<int> hexList = [];

    mapData.forEach((key, value) {
      var hexValue = key == 0 ? value : value ^ 0x80;
      // print(key.toString() + " " + value.toString());
      // print(hexValue);
      hexList.add(hexValue);
    });
    // print("hexList ===> $hexList");

    List reversedList = (hexList.reversed).toList();

    Uint8List conversion = Uint8List.fromList((hexList.reversed).toList());
    // print("conversion $conversion");

    String reversedIntListDataToHex = hex.encode(reversedList);
    // print("reversedIntListDataToHex ===> $reversedIntListDataToHex");

    return reversedIntListDataToHex;
  }

  static String writeAddress(String address) {
    Uint8List uintBsList = bs58check.decode(address).sublist(3);
    // List<int> bsList = List.from(uintBsList);
    String hexString = hex.encode(uintBsList);
    // print("hexString ===> $hexString");

    if (address.startsWith("tz1")) {
      return "0000" + hexString;
    } else if (address.startsWith("tz2")) {
      return "0001" + hexString;
    } else if (address.startsWith("tz3")) {
      return "0002" + hexString;
    } else if (address.startsWith("KT1")) {
      return "01" + hexString + "00";
    } else {
      throw ErrorDescription("Unrecognized address prefix: ");
    }
  }

  static String writeBoolean(bool value) => value ? "ff" : "00";
}
