import 'dart:math';

import 'package:flutter/cupertino.dart';

class PasswordGenerator {
  /// @desc Function to generate password based on some criteria
  /// @param bool isWithLetters: password must contain letters
  /// @param bool isWithUppercase: password must contain uppercase letters
  /// @param bool isWithNumbers: password must contain numbers
  /// @param bool isWithSpecial: password must contain special chars
  /// @param int length: password length
  /// @return string: new password
  static String generatePassword(
      {@required double length,
      bool isWithLetters,
      bool isWithUppercase,
      bool isWithNumbers,
      bool isWithSpecial}) {
    //Define the allowed chars to use in the password
    String _lowerCaseLetters = "abcdefghijklmnopqrstuvwxyz";
    String _upperCaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    String _numbers = "0123456789";
    String _special = r'!@#$%^&*()+_-=}{[]|:;"/?.><,`~';  

    //Create the empty string that will contain the allowed chars
    String _allowedChars = "";

    //Put chars on the allowed ones based on the input values
    _allowedChars += (isWithLetters ? _lowerCaseLetters : '');
    _allowedChars += (isWithUppercase ? _upperCaseLetters : '');
    _allowedChars += (isWithNumbers ? _numbers : '');
    _allowedChars += (isWithSpecial ? _special : '');

    int i = 0;
    String _result = "";

    //Create password
    while (i < length.round()) {
      //Get random int
      int randomInt = Random.secure().nextInt(_allowedChars.length);
      //Get random char and append it to the password
      _result += _allowedChars[randomInt];
      i++;
    }

    return _result;
  }
}
