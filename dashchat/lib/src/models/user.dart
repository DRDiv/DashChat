import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class User {
  String UserName;
  String DisplayName;
  String? Password;

  String email;
  User(this.UserName, Password, this.email, this.DisplayName) {
    this.Password = _hashPass(Password);
  }
  Future<void> Register() async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: Password!);

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    usersCollection.add({
      'name': UserName,
      'displayName': DisplayName,
      'Password': Password,
      'email': email
    });
  }

  static Future<User> get(String username) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    Query usersQuery = usersCollection.where('name', isEqualTo: username);

    // Execute the query and fetch documents
    QuerySnapshot querySnapshot = await usersQuery.get();
    if (querySnapshot.docs.isEmpty) {
      return User("", "", "", "");
    }
    User user = User(
        querySnapshot.docs[0]['name'],
        querySnapshot.docs[0]['Password'],
        querySnapshot.docs[0]['email'],
        querySnapshot.docs[0]['displayName']);
    return user;
  }

  Future<bool> userExist() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot usersQuery =
        await usersCollection.where('name', isEqualTo: UserName).get();

    if (usersQuery.docs.isNotEmpty) return true;
    return false;
  }

  Future<bool> emailExist() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot usersQuery =
        await usersCollection.where('email', isEqualTo: email).get();

    if (usersQuery.docs.isNotEmpty) return true;
    return false;
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
