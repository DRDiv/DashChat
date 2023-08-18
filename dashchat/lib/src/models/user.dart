import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class User {
  String UserName;
  String? Password;
  String UserId;
  String? RegisterToken;
  User(this.UserName, Password, this.UserId) {
    this.Password = _hashPass(Password);
    RegisterToken = _generateRegistrationId();
  }
  String _hashPass(String pass) {
    var bytes = utf8.encode(pass);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }

  String _generateRegistrationId() {
    final random = Random();
    const int idLength = 32; // Length of the registration ID
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    String registrationId = '';
    for (int i = 0; i < idLength; i++) {
      registrationId += chars[random.nextInt(chars.length)];
    }

    return registrationId;
  }
}
