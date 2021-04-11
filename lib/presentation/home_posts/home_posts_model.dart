import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';

class HomePostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Auth.User? loggedInUser;
  UserProfile? userProfile;

  List<Post> _posts = [];
  List<Post> get posts => _posts;
  Map<String, List<Reply>> _replies = {};
  Map<String, List<Reply>> get replies => _replies;
  List<Reply> _rawReplies = [];
  Map<String, List<Reply>> _repliesToReply = {};
  Map<String, List<Reply>> get repliesToReply => _repliesToReply;

  QueryDocumentSnapshot? lastVisibleOfTheBatch;
  int loadLimit = 10;
  // // bool isPostsExisting = false;
  bool canLoadMore = false;
  bool isLoading = false;

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> get getPostsWithReplies => _getPostsWithReplies();
  Future<void> get loadPostsWithReplies => _loadPostsWithReplies();

  Future<void> _getPostsWithReplies() async {
    startLoading();

    Query queryBatch = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    _posts.clear();
    _rawReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _posts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _posts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _posts = docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadPostsWithReplies() async {
    startLoading();

    Query queryBatch = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastVisibleOfTheBatch!)
        .limit(loadLimit);
    // queryBatch = queryBatch.startAfterDocument(lastVisibleOfTheBatch!);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      canLoadMore = false;
      _posts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      canLoadMore = false;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _posts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      canLoadMore = true;
      lastVisibleOfTheBatch = docs[docs.length - 1];
      _posts += docs.map((doc) => Post(doc)).toList();
    }
    await _addBookmarkToPosts();
    await _getRepliesToPosts();
    await _getRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _addBookmarkToPosts() async {
    // List<Post> _bookmarkedPosts = [];
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

    // bookmark付けてる
    for (int i = 0; i < _posts.length; i++) {
      for (QueryDocumentSnapshot bookmarkedPostDoc in bookmarkedPostDocs) {
        if (_posts[i].id == bookmarkedPostDoc.id) {
          _posts[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _getRepliesToPosts() async {
    if (_posts.isNotEmpty) {
      for (final post in _posts) {
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
        _rawReplies += replies;
        _replies[post.id] = replies;
      }
    }
  }

  Future<void> _getRepliesToReplies() async {
    if (_rawReplies.isNotEmpty) {
      for (final reply in _rawReplies) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(reply.uid)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final docs = querySnapshot.docs;
        final repliesToReply = docs.map((doc) => Reply(doc)).toList();
        _repliesToReply[reply.id] = repliesToReply;
      }
    }
  }

  void listenAuthStateChanges() {
    _auth.userChanges().listen((Auth.User? user) async {
      if (user == null) {
        this.loggedInUser = (await _auth.signInAnonymously()).user;
      } else {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // setはuserDocのDocumentIdをもつDocumentにデータを保存する。
          // addは自動生成されたidが付与されたDocumentにデータを保存する。
          await userDoc.reference.set({
            'userId': user.uid,
            'nickname': '匿名',
            'position': '',
            'gender': '',
            'age': '',
            'area': '',
            'postCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (!user.isAnonymous) {
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

  Future<void> signOut() async {
    await _auth.signOut();
    loggedInUser = null;
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
