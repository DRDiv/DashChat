import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'dart:math';
import 'package:dashchat/src/models/message.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class User {
  String? userToken;
  String userName;
  String displayName;
  String? password;

  String email;
  FileImage? _profile;
  String profileUrl = "";
  String caption;
  List followers = [];
  List following = [];
  List posts = [];
  Map<String, dynamic> docReturn() {
    Map<String, dynamic> docs = {
      'userToken': userToken,
      'userName': userName,
      'displayName': displayName,
      'password': password,
      'email': email,
      'profileUrl': profileUrl,
      'caption': caption,
      'followers': followers,
      'following': following,
      'posts': posts,
    };
    return docs;
  }

  User(this.userName, password, this.email, this.displayName, this._profile,
      this.caption) {
    userToken = Uuid().v4();
    this.password = _hashPass(password);
  }
  User.setUser(
      this.userToken,
      this.userName,
      this.password,
      this.email,
      this.displayName,
      this.profileUrl,
      this.caption,
      this.followers,
      this.following,
      this.posts);
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
        .createUserWithEmailAndPassword(email: email, password: password!);

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    usersCollection.add(docReturn());
    Message message = Message(userToken!);
    message.registerDm();
  }

  static Future<User> get(String userToken) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    Query usersQuery = usersCollection.where('userToken', isEqualTo: userToken);

    QuerySnapshot querySnapshot = await usersQuery.get();
    if (querySnapshot.docs.isEmpty) {
      return User("", "", "", "", null, "");
    }

    User user = User.setUser(
      querySnapshot.docs[0]['userToken'],
      querySnapshot.docs[0]['userName'],
      querySnapshot.docs[0]['password'],
      querySnapshot.docs[0]['email'],
      querySnapshot.docs[0]['displayName'],
      querySnapshot.docs[0]['profileUrl'],
      querySnapshot.docs[0]['caption'],
      querySnapshot.docs[0]['followers'],
      querySnapshot.docs[0]['following'],
      querySnapshot.docs[0]['posts'],
    );
    return user;
  }

  static Future<User> getByUsername(String userName) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    Query usersQuery = usersCollection.where('userName', isEqualTo: userName);

    QuerySnapshot querySnapshot = await usersQuery.get();
    if (querySnapshot.docs.isEmpty) {
      return User("", "", "", "", null, "");
    }
    User user = User.setUser(
      querySnapshot.docs[0]['userToken'],
      querySnapshot.docs[0]['userName'],
      querySnapshot.docs[0]['password'],
      querySnapshot.docs[0]['email'],
      querySnapshot.docs[0]['displayName'],
      querySnapshot.docs[0]['profileUrl'],
      querySnapshot.docs[0]['caption'],
      querySnapshot.docs[0]['followers'],
      querySnapshot.docs[0]['following'],
      querySnapshot.docs[0]['posts'],
    );
    return user;
  }

  static Future<User> getCurrentUser() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('userSession');

    QuerySnapshot querySnapshot = await usersCollection.get();

    User user = await User.get(querySnapshot.docs[0]['userToken'] as String);
    return user;
  }

  static Future<Map> getUsernameMap() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await usersCollection.get();
    Map userNameMap = {};
    for (QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
      userNameMap[queryDocumentSnapshot['userToken']] =
          queryDocumentSnapshot['userName'];
    }
    return userNameMap;
  }

  static Future<String> getUsername(String userToken) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    Query usersQuery = usersCollection.where('userToken', isEqualTo: userToken);

    QuerySnapshot querySnapshot = await usersQuery.get();
    if (querySnapshot.docs.isEmpty) {
      return "";
    }

    User user = User.setUser(
      querySnapshot.docs[0]['userToken'],
      querySnapshot.docs[0]['userName'],
      querySnapshot.docs[0]['password'],
      querySnapshot.docs[0]['email'],
      querySnapshot.docs[0]['displayName'],
      querySnapshot.docs[0]['profileUrl'],
      querySnapshot.docs[0]['caption'],
      querySnapshot.docs[0]['followers'],
      querySnapshot.docs[0]['following'],
      querySnapshot.docs[0]['posts'],
    );
    return user.userName;
  }

  Future<bool> userExist() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot usersQuery =
        await usersCollection.where('userName', isEqualTo: userName).get();

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
    Map<String, dynamic> docs = {'userToken': userToken};
    var uuid = Uuid();
    docs['loginToken'] = uuid.v1();
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
        .where('userToken', isEqualTo: userToken)
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

  Future<void> removeFollowing(String user) async {
    QuerySnapshot<Map<String, dynamic>> userList = await FirebaseFirestore
        .instance
        .collection('users')
        .where('userToken', isEqualTo: userToken)
        .get();

    DocumentSnapshot userDocSnapshot = userList.docs.first;
    String userDocId = userDocSnapshot.id;

    following.remove(user);

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
        .where('userToken', isEqualTo: userToken)
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

  Future<void> removeFollower(String user) async {
    QuerySnapshot<Map<String, dynamic>> userList = await FirebaseFirestore
        .instance
        .collection('users')
        .where('userToken', isEqualTo: userToken)
        .get();

    DocumentSnapshot userDocSnapshot = userList.docs.first;
    String userDocId = userDocSnapshot.id;

    followers.remove(user);

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userDocId);
    await userDocRef.update({
      'followers': followers,
    });
  }

  Future<void> addPost(String postUrl) async {
    QuerySnapshot<Map<String, dynamic>> userList = await FirebaseFirestore
        .instance
        .collection('users')
        .where('userToken', isEqualTo: userToken)
        .get();

    DocumentSnapshot userDocSnapshot = userList.docs.first;
    String userDocId = userDocSnapshot.id;

    posts.add(postUrl);

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userDocId);
    await userDocRef.update({
      'posts': posts,
    });
  }

  String _hashPass(String pass) {
    var bytes = utf8.encode(pass);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }
}
