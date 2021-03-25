import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:kakikomi_keijiban/reply.dart';

class HomeModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<Post> _posts = [];
  List<List<Reply>> _replies = [];

  List<Post> get posts => _posts;
  List<List<Reply>> get replies => _replies;

  Future<void> getPostsWithReplies() async {
    final querySnapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    final docs = querySnapshot.docs;
    final posts = docs.map((doc) => Post(doc)).toList();
    _posts = posts;
    for (final post in posts) {
      final querySnapshot = await _firestore
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final replies = docs.map((doc) => Reply(doc)).toList();
      _replies.add(replies);
    }
    notifyListeners();
  }

  void getPostsRealtime() {
    final snapshots = _firestore.collection('posts').snapshots();
    snapshots.listen((snapshot) {
      final docs = snapshot.docs;
      final _posts = docs.map((doc) => Post(doc)).toList();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      this._posts = _posts;
      notifyListeners();
    });
  }

// Future getPosts() async {
//   final querySnapshot = await _firestore.collection('posts').get();
//   final docs = querySnapshot.docs;
//   final posts = docs.map((doc) => Post(doc)).toList();
//   posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//   _posts = posts;
//   notifyListeners();
// }

// Future<void> updatePost(Post post) async {
//     final collection = _firestore.collection('posts');
//     await collection.doc(post.id).update({'title': post.title});
//     notifyListeners();
//   }

  Future<void> deletePost(Post post) async {
    final collection = _firestore.collection('posts');
    await collection.doc(post.id).delete();
    notifyListeners();
  }
}
