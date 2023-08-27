import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class Post {
  String? userToken;

  String? postUrl;
  Timestamp? time;
  String caption = "";
  List comments = [];
  List likes = [];
  Map<String, dynamic> docReturn() {
    Map<String, dynamic> doc = {
      'userToken': userToken,
      'postUrl': postUrl,
      'time': DateTime.now(),
      'comments': comments,
      'likes': likes,
      'caption': caption,
    };
    return doc;
  }

  Post() {}
  Post.set(this.userToken, this.postUrl, this.time, this.comments, this.likes,
      this.caption);
  Future<void> addPost(FileImage _postImage) async {
    User current = await User.getCurrentUser();
    userToken = current.userToken;
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

  static Future<List<Post>> getAllPost() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('posts');
    QuerySnapshot querySnapshot = await usersCollection.get();
    List<Post> postList = [];
    for (QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
      Post postTemp = Post.set(
          queryDocumentSnapshot['userToken'],
          queryDocumentSnapshot['postUrl'],
          queryDocumentSnapshot['time'],
          queryDocumentSnapshot['comments'],
          queryDocumentSnapshot['likes'],
          queryDocumentSnapshot['caption']);
      postList.add(postTemp);
    }
    return postList;
  }

  static Future<Post> getPost(String postUrl) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('posts');
    Query usersQuery = usersCollection.where('postUrl', isEqualTo: postUrl);

    QuerySnapshot querySnapshot = await usersQuery.get();
    Post post = Post.set(
        querySnapshot.docs[0]['userToken'],
        querySnapshot.docs[0]['postUrl'],
        querySnapshot.docs[0]['time'],
        querySnapshot.docs[0]['comments'],
        querySnapshot.docs[0]['likes'],
        querySnapshot.docs[0]['caption']);
    return post;
  }

  static Future<void> addComment(
      String postUrl, String comment, String userToken, Timestamp time) async {
    QuerySnapshot<Map<String, dynamic>> postList = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('postUrl', isEqualTo: postUrl)
        .get();

    DocumentSnapshot postDocSnapshot = postList.docs.first;
    String postDocId = postDocSnapshot.id;
    List comments = postDocSnapshot['comments'];
    Map docs = {
      'userToken': userToken,
      'comments': comment,
      'time': time,
    };
    comments.add(docs);

    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('posts').doc(postDocId);
    await postDocRef.update({
      'comments': comments,
    });
  }

  static Future<void> likePost(String postUrl, String userToken) async {
    QuerySnapshot<Map<String, dynamic>> postList = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('postUrl', isEqualTo: postUrl)
        .get();

    DocumentSnapshot postDocSnapshot = postList.docs.first;
    String postDocId = postDocSnapshot.id;
    List likes = postDocSnapshot['likes'];
    likes.add(userToken);

    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('posts').doc(postDocId);
    await postDocRef.update({
      'likes': likes,
    });
  }

  static Future<void> unlikePost(String postUrl, String userToken) async {
    QuerySnapshot<Map<String, dynamic>> postList = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('postUrl', isEqualTo: postUrl)
        .get();

    DocumentSnapshot postDocSnapshot = postList.docs.first;
    String postDocId = postDocSnapshot.id;
    List likes = postDocSnapshot['likes'];
    likes.remove(userToken);

    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('posts').doc(postDocId);
    await postDocRef.update({
      'likes': likes,
    });
  }

  Future<void> updateCaption(String caption) async {
    QuerySnapshot<Map<String, dynamic>> postList = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('postUrl', isEqualTo: postUrl)
        .get();

    DocumentSnapshot postDocSnapshot = postList.docs.first;
    String postDocId = postDocSnapshot.id;
    this.caption = caption;
    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('posts').doc(postDocId);
    await postDocRef.update({
      'caption': caption,
    });
  }
}
