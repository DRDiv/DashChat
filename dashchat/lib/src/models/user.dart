import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class User {
  String UserName;
  String DisplayName;
  String? Password;

  String email;
  FileImage? _profile;
  String profileUrl = "";
  String caption;
  List followers = [];
  List following = [];
  Map<String, dynamic> docReturn() {
    Map<String, dynamic> docs = {
      'name': UserName,
      'displayName': DisplayName,
      'Password': Password,
      'email': email,
      'profileUrl': profileUrl,
      'caption': caption,
      'followers': followers,
      'following': following
    };
    return docs;
  }

  User(this.UserName, Password, this.email, this.DisplayName, this._profile,
      this.caption) {
    this.Password = _hashPass(Password);
  }
  User.getUser(this.UserName, this.Password, this.email, this.DisplayName,
      this.profileUrl, this.caption, this.followers, this.following);
  Future<void> Register() async {
    if (_profile != null) {
      File profileFile = _profile!.file;
      Reference storageReference0 = FirebaseStorage.instance.ref();
      String fileName = path.basename(profileFile.path);
      Reference storageReference = storageReference0.child('avatars/$fileName');

      TaskSnapshot taskSnapshot = await storageReference.putFile(profileFile);

      profileUrl = await taskSnapshot.ref.getDownloadURL();
    }
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: Password!);

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    usersCollection.add(docReturn());
  }

  static Future<User> get(String username) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    Query usersQuery = usersCollection.where('name', isEqualTo: username);

    QuerySnapshot querySnapshot = await usersQuery.get();
    if (querySnapshot.docs.isEmpty) {
      return User("", "", "", "", null, "");
    }
    User user = User.getUser(
      querySnapshot.docs[0]['name'],
      querySnapshot.docs[0]['Password'],
      querySnapshot.docs[0]['email'],
      querySnapshot.docs[0]['displayName'],
      querySnapshot.docs[0]['profileUrl'],
      querySnapshot.docs[0]['caption'],
      querySnapshot.docs[0]['followers'],
      querySnapshot.docs[0]['following'],
    );
    return user;
  }

  static Future<User> getCurrentUser() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('userSession');

    QuerySnapshot querySnapshot = await usersCollection.get();

    User user = await User.get(querySnapshot.docs[0]['name']);
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

  Future<void> login() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('userSession');
    Map<String, dynamic> docs = {'name': UserName};
    var uuid = Uuid();
    docs['tokenId'] = uuid.v4();
    usersCollection.add(docs);
  }

  static Future<void> logout() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('userSession');

    QuerySnapshot querySnapshot = await collectionRef.get();
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
  }

  static Future<bool> userLoggedIn() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('userSession');
    QuerySnapshot usersQuery = await usersCollection.get();
    return usersQuery.docs.isNotEmpty;
  }

  Future<void> addFollowing(String user) async {
    QuerySnapshot<Map<String, dynamic>> userList = await FirebaseFirestore
        .instance
        .collection('users')
        .where('name', isEqualTo: UserName)
        .get();

    DocumentSnapshot userDocSnapshot = userList.docs.first;
    String userDocId = userDocSnapshot.id;

    following.add(user);

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userDocId);
    await userDocRef.update({
      'following': following,
    });
  }

  Future<void> addFollower(String user) async {
    QuerySnapshot<Map<String, dynamic>> userList = await FirebaseFirestore
        .instance
        .collection('users')
        .where('name', isEqualTo: UserName)
        .get();

    DocumentSnapshot userDocSnapshot = userList.docs.first;
    String userDocId = userDocSnapshot.id;

    followers.add(user);

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userDocId);
    await userDocRef.update({
      'followers': followers,
    });
  }

  String _hashPass(String pass) {
    var bytes = utf8.encode(pass);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }
}
