import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashchat/src/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class Story {
  String? userToken;
  String? storyUrl;
  Timestamp? time;
  List likes = [];
  List views = [];
  Map<String, dynamic> docReturn() {
    Map<String, dynamic> doc = {
      'userToken': userToken,
      'storyUrl': storyUrl,
      'time': DateTime.now(),
      'likes': likes,
      'views': views,
    };
    return doc;
  }

  Story() {}
  Story.set(this.userToken, this.storyUrl, this.time, this.views, this.likes);
  Future<void> addStory(FileImage _postImage) async {
    User current = await User.getCurrentUser();
    userToken = current.userToken;
    File profileFile = _postImage!.file;
    Reference storageReference0 = FirebaseStorage.instance.ref();
    String fileName = path.basename(profileFile.path);
    Reference storageReference = storageReference0.child('stories/$fileName');

    TaskSnapshot taskSnapshot = await storageReference.putFile(profileFile);

    storyUrl = await taskSnapshot.ref.getDownloadURL();
    final CollectionReference postCollection =
        FirebaseFirestore.instance.collection('stories');
    postCollection.add(docReturn());
  }

  static Future<List<Story>> getAllStories() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('stories');
    QuerySnapshot querySnapshot = await usersCollection.get();
    List<Story> storyList = [];
    for (QueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
      Story storyTemp = Story.set(
        queryDocumentSnapshot['userToken'],
        queryDocumentSnapshot['storyUrl'],
        queryDocumentSnapshot['time'],
        queryDocumentSnapshot['views'],
        queryDocumentSnapshot['likes'],
      );
      storyList.add(storyTemp);
    }
    return storyList;
  }

  static Future<Story> getStory(String storyUrl) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('stories');
    Query usersQuery = usersCollection.where('storyUrl', isEqualTo: storyUrl);

    QuerySnapshot querySnapshot = await usersQuery.get();
    Story story = Story.set(
      querySnapshot.docs[0]['userToken'],
      querySnapshot.docs[0]['storyUrl'],
      querySnapshot.docs[0]['time'],
      querySnapshot.docs[0]['views'],
      querySnapshot.docs[0]['likes'],
    );
    return story;
  }

  static Future<void> likePost(String storyUrl, String userToken) async {
    QuerySnapshot<Map<String, dynamic>> postList = await FirebaseFirestore
        .instance
        .collection('stories')
        .where('storyUrl', isEqualTo: storyUrl)
        .get();

    DocumentSnapshot postDocSnapshot = postList.docs.first;
    String postDocId = postDocSnapshot.id;
    List likes = postDocSnapshot['likes'];
    likes.add(userToken);

    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('stories').doc(postDocId);
    await postDocRef.update({
      'likes': likes,
    });
  }

  static Future<void> addView(String storyUrl, String userToken) async {
    QuerySnapshot<Map<String, dynamic>> postList = await FirebaseFirestore
        .instance
        .collection('stories')
        .where('storyUrl', isEqualTo: storyUrl)
        .get();

    DocumentSnapshot postDocSnapshot = postList.docs.first;
    String postDocId = postDocSnapshot.id;
    List views = postDocSnapshot['views'];
    if (views.contains(userToken)) return;
    views.add(userToken);

    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('stories').doc(postDocId);
    await postDocRef.update({
      'views': views,
    });
  }
}
