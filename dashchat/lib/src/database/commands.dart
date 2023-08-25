import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class SearchQuery {
  Future<List<Map<String, dynamic>>> getUsers(String like) async {
    if (like.isEmpty) {
      return [];
    }

    User current = await User.getCurrentUser();
    String usernameCurrent = current.userName;

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot usersQuery = await usersCollection.get();

    List<Map<String, dynamic>> matchingUsers = usersQuery.docs
        .where((doc) =>
            doc['userName'] != usernameCurrent &&
            RegExp(like, caseSensitive: false)
                .hasMatch(doc['userName'] as String))
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return matchingUsers;
  }
}
