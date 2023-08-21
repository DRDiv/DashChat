import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class Post {
  String? username;

  String? postUrl;
  String? time;
  List<String> comments = [];
  int likes = 0;
  Map<String, dynamic> docReturn() {
    Map<String, dynamic> doc = {
      'username': username,
      'postUrl': postUrl,
      'time': DateTime.now(),
      'comments': comments,
      'likes': likes,
    };
    return doc;
  }

  Future<void> addPost(FileImage _postImage) async {
    User current = await User.getCurrentUser();
    username = current.UserName;
    File profileFile = _postImage!.file;
    Reference storageReference0 = FirebaseStorage.instance.ref();
    String fileName = path.basename(profileFile.path);
    Reference storageReference = storageReference0.child('posts/$fileName');

    TaskSnapshot taskSnapshot = await storageReference.putFile(profileFile);

    postUrl = await taskSnapshot.ref.getDownloadURL();
    final CollectionReference postCollection =
        FirebaseFirestore.instance.collection('posts');
    postCollection.add(docReturn());
  }
}
