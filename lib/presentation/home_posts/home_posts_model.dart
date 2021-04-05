import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';

class HomePostsModel extends ChangeNotifier {
  static final homePage = 'HomePage';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Auth.User? loggedInUser;
  UserProfile? userProfile;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Map<String, List<Reply>> _replies = {};
  Map<String, List<Reply>> get replies => _replies;

  List<Post> _bookmarkedPosts = [];
  List<Post> get bookmarkedPosts => _bookmarkedPosts;

  void listenAuthStateChanges() {
    _auth.userChanges().listen((Auth.User? user) async {
      if (user == null) {
        this.loggedInUser = (await _auth.signInAnonymously()).user;
      } else {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // setはuserDocのDocument idをもつDocumentにデータを保存する。
          // addは自動生成されたidが付与されたDocumentにデータを保存する。
          await userDoc.reference.set({
            'nickname': '名無し',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          userProfile = UserProfile(userDoc);
        }
        this.loggedInUser = user;
      }
      notifyListeners();
    });
  }

  Future<void> getUserProfile() async {
    if (loggedInUser!.isAnonymous == false) {
      final userDoc =
          await _firestore.collection('users').doc(loggedInUser!.uid).get();
      userProfile = UserProfile(userDoc);
      print('final Dance!!!');
    }
    notifyListeners();
  }

  void signOut() async {
    await _auth.signOut();
    loggedInUser = null;
    notifyListeners();
  }

  Future<void> get getPostsWithReplies => _getPostsWithReplies();

  Future<void> _getPostsWithReplies() async {
    final querySnapshot = await _firestore
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .get();
    final docs = querySnapshot.docs;
    final posts = docs.map((doc) => Post(doc)).toList();
    _posts = posts;
    await _getBookmarkedPosts();
    for (int i = 0; i < _posts.length; i++) {
      for (Post bookmarkedPost in _bookmarkedPosts) {
        if (_posts[i].id == bookmarkedPost.id) {
          _posts[i].isBookmarked = true;
        }
      }
    }
    for (final post in posts) {
      // final querySnapshot = await _firestore
      //     .collectionGroup('replies')
      //     .where('postId', isEqualTo: post.id)
      //     .orderBy('createdAt')
      //     .get();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.uid)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final replies = docs.map((doc) => Reply(doc)).toList();
      _replies[post.id] = replies;
    }
    notifyListeners();
  }

  Future<void> _getBookmarkedPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .get();
    final postSnapshots = await Future.wait(bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['postId'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    _bookmarkedPosts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
    // postCardでブックマークアイコンの切り替えのために書いてる
    for (int i = 0; i < _bookmarkedPosts.length; i++) {
      _bookmarkedPosts[i].isBookmarked = true;
    }
    notifyListeners();
  }

  // void getPostsRealtime() {
  //   final snapshots = _firestore.collection('posts').snapshots();
  //   snapshots.listen((snapshot) {
  //     final docs = snapshot.docs;
  //     final _posts = docs.map((doc) => Post(doc)).toList();
  //     _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //     this._posts = _posts;
  //     notifyListeners();
  //   });
  // }
}
