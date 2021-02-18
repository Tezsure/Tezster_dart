import 'dart:math';

import 'package:flutter/cupertino.dart';

class PasswordGenerator {

  static String generatePassword(
      {@required double length,
      bool isWithLetters,
      bool isWithUppercase,
      bool isWithNumbers,
      bool isWithSpecial}) {
    String _lowerCaseLetters = "abcdefghijklmnopqrstuvwxyz";
    String _upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    String _numbers = "0123456789";
    String _special = r'!@#$%^&*()+_-=}{[]|:;"/?.><,`~';  

    String _allowedChars = "";

    _allowedChars += (isWithLetters ? _lowerCaseLetters : '');
    _allowedChars += (isWithUppercase ? _upperCaseLetters : '');
    _allowedChars += (isWithNumbers ? _numbers : '');
    _allowedChars += (isWithSpecial ? _special : '');

    int i = 0;
    String _result = "";

    while (i < length.round()) {
      int randomInt = Random.secure().nextInt(_allowedChars.length);
      _result += _allowedChars[randomInt];
      i++;
    }

    return _result;
  }
}
