import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';

class HomePostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Auth.User? loggedInUser;
  UserProfile? userProfile;

  List<Post> _allPosts = [];
  List<Post> _myPosts = [];
  List<Post> _bookmarkedPosts = [];
  // List<Post> get allPosts => _allPosts;
  // List<Post> get myPosts => _myPosts;
  // List<Post> get bookmarkedPosts => _bookmarkedPosts;
  Map<String, List<Reply>> _allReplies = {};
  // Map<String, List<Reply>> get allReplies => _allReplies;
  Map<String, List<Reply>> _myReplies = {};
  // Map<String, List<Reply>> get myReplies => _myReplies;
  Map<String, List<Reply>> _bookmarkedReplies = {};
  // Map<String, List<Reply>> get bookmarkedReplies => _bookmarkedReplies;
  List<Reply> _allRawReplies = [];
  List<Reply> _myRawReplies = [];
  List<Reply> _bookmarkedRawReplies = [];
  Map<String, List<Reply>> _allRepliesToReply = {};
  // Map<String, List<Reply>> get allRepliesToReply => _allRepliesToReply;
  Map<String, List<Reply>> _myRepliesToReply = {};
  // Map<String, List<Reply>> get myRepliesToReply => _myRepliesToReply;
  Map<String, List<Reply>> _bookmarkedRepliesToReply = {};
  // Map<String, List<Reply>> get bookmarkedRepliesToReply =>
  //     _bookmarkedRepliesToReply;

  QueryDocumentSnapshot? allPostsLastVisible;
  QueryDocumentSnapshot? myPostsLastVisible;
  QueryDocumentSnapshot? bookmarkedPostsLastVisible;
  int loadLimit = 10;
  // // bool isPostsExisting = false;
  bool _allPostsCanLoadMore = false;
  bool _myPostsCanLoadMore = false;
  bool _bookmarkedPostsCanLoadMore = false;
  bool isLoading = false;

  // Future<void> get getAllPostsWithReplies => _getAllPostsWithReplies();
  // Future<void> get loadAllPostsWithReplies => _loadAllPostsWithReplies();
  // Future<void> get getMyPostsWithReplies => _getMyPostsWithReplies();
  // Future<void> get loadMyPostsWithReplies => _loadMyPostsWithReplies();
  // Future<void> get getBookmarkedPostsWithReplies =>
  //     _getBookmarkedPostsWithReplies();
  // Future<void> get loadBookmarkedPostsWithReplies =>
  //     _loadBookmarkedPostsWithReplies();

  Future<void> init() async {
    await _listenAuthStateChanges();
    await _getAllPostsWithReplies();
    await _getMyPostsWithReplies();
    await _getBookmarkedPostsWithReplies();
  }

  List<Post> getPosts(String tabName) {
    if (tabName == kAllPostsTab) {
      return this._allPosts;
    } else if (tabName == kMyPostsTab) {
      return this._myPosts;
    } else if (tabName == kBookmarkedPostsTab) {
      return this._bookmarkedPosts;
    } else {
      return [];
    }
  }

  Map<String, List<Reply>> getReplies(String tabName) {
    if (tabName == kAllPostsTab) {
      return this._allReplies;
    } else if (tabName == kMyPostsTab) {
      return this._myReplies;
    } else if (tabName == kBookmarkedPostsTab) {
      return this._bookmarkedReplies;
    } else {
      return {};
    }
  }

  Map<String, List<Reply>> getRepliesToReply(String tabName) {
    if (tabName == kAllPostsTab) {
      return this._allRepliesToReply;
    } else if (tabName == kMyPostsTab) {
      return this._myRepliesToReply;
    } else if (tabName == kBookmarkedPostsTab) {
      return this._bookmarkedRepliesToReply;
    } else {
      return {};
    }
  }

  bool getCanLoadMore(String tabName) {
    if (tabName == kAllPostsTab) {
      return this._allPostsCanLoadMore;
    } else if (tabName == kMyPostsTab) {
      return this._myPostsCanLoadMore;
    } else if (tabName == kBookmarkedPostsTab) {
      return this._bookmarkedPostsCanLoadMore;
    } else {
      return false;
    }
  }

  Future<void> getPostsWithReplies(String tabName) async {
    if (tabName == kAllPostsTab) {
      await _getAllPostsWithReplies();
    } else if (tabName == kMyPostsTab) {
      await _getMyPostsWithReplies();
    } else if (tabName == kBookmarkedPostsTab) {
      await _getBookmarkedPostsWithReplies();
    }
  }

  Future<void> loadPostsWithReplies(String tabName) async {
    if (tabName == kAllPostsTab) {
      await _loadAllPostsWithReplies();
    } else if (tabName == kMyPostsTab) {
      await _loadMyPostsWithReplies();
    } else if (tabName == kBookmarkedPostsTab) {
      await _loadBookmarkedPostsWithReplies();
    }
  }

  Future<void> _getAllPostsWithReplies() async {
    startLoading();

    Query queryBatch = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._allPosts.clear();
    _allRawReplies.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      _allPostsCanLoadMore = false;
      this._allPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      _allPostsCanLoadMore = false;
      allPostsLastVisible = docs[docs.length - 1];
      this._allPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      _allPostsCanLoadMore = true;
      allPostsLastVisible = docs[docs.length - 1];
      this._allPosts = docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToPosts(this._allPosts);
    await _getRepliesToPosts(
      posts: this._allPosts,
      replies: this._allReplies,
      rawReplies: this._allRawReplies,
    );
    await _getRepliesToReplies(
      rawReplies: this._allRawReplies,
      repliesToReply: this._allRepliesToReply,
    );

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadAllPostsWithReplies() async {
    startLoading();

    Query queryBatch = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(allPostsLastVisible!)
        .limit(loadLimit);
    // queryBatch = queryBatch.startAfterDocument(lastVisible!);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      _allPostsCanLoadMore = false;
      this._allPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      _allPostsCanLoadMore = false;
      allPostsLastVisible = docs[docs.length - 1];
      this._allPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      _allPostsCanLoadMore = true;
      allPostsLastVisible = docs[docs.length - 1];
      this._allPosts += docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToPosts(this._allPosts);
    await _getRepliesToPosts(
      posts: this._allPosts,
      replies: this._allReplies,
      rawReplies: this._allRawReplies,
    );
    await _getRepliesToReplies(
      rawReplies: this._allRawReplies,
      repliesToReply: this._allRepliesToReply,
    );

    stopLoading();
    notifyListeners();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._myPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._myPostsCanLoadMore = false;
      this._myPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = false;
      myPostsLastVisible = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = true;
      myPostsLastVisible = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToPosts(this._myPosts);
    await _getRepliesToPosts(
      posts: this._myPosts,
      replies: this._myReplies,
      rawReplies: _myRawReplies,
    );
    await _getRepliesToReplies(
      rawReplies: this._myRawReplies,
      repliesToReply: this._myRepliesToReply,
    );

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(myPostsLastVisible!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._myPostsCanLoadMore = false;
      this._myPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = false;
      myPostsLastVisible = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = true;
      myPostsLastVisible = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToPosts(this._myPosts);
    await _getRepliesToPosts(
      posts: this._myPosts,
      replies: this._myReplies,
      rawReplies: _myRawReplies,
    );
    await _getRepliesToReplies(
      rawReplies: this._myRawReplies,
      repliesToReply: this._myRepliesToReply,
    );

    stopLoading();
    notifyListeners();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    this._bookmarkedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._bookmarkedPostsCanLoadMore = false;
      this._bookmarkedPosts = [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = false;
      bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts = await _getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = true;
      bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts = await _getBookmarkedPosts(docs);
    }

    await _getRepliesToPosts(
      posts: this._bookmarkedPosts,
      replies: this._bookmarkedReplies,
      rawReplies: _bookmarkedRawReplies,
    );
    await _getRepliesToReplies(
      rawReplies: this._bookmarkedRawReplies,
      repliesToReply: this._bookmarkedRepliesToReply,
    );

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    Query queryBatch = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(bookmarkedPostsLastVisible!)
        .limit(loadLimit);
    final querySnapshot = await queryBatch.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._bookmarkedPostsCanLoadMore = false;
      this._bookmarkedPosts += [];
    } else if (docs.length < loadLimit) {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = false;
      bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts += await _getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = true;
      bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts += await _getBookmarkedPosts(docs);
    }

    await _getRepliesToPosts(
      posts: this._bookmarkedPosts,
      replies: this._bookmarkedReplies,
      rawReplies: _bookmarkedRawReplies,
    );
    await _getRepliesToReplies(
      rawReplies: this._bookmarkedRawReplies,
      repliesToReply: this._bookmarkedRepliesToReply,
    );

    stopLoading();
    notifyListeners();
  }

  Future<List<Post>> _getBookmarkedPosts(
      List<QueryDocumentSnapshot> docs) async {
    final postSnapshots = await Future.wait(docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['postId'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs =
        postSnapshots.map((postSnapshot) => postSnapshot.docs[0]).toList();
    final bookmarkedPosts = bookmarkedPostDocs.map((doc) => Post(doc)).toList();
    for (int i = 0; i < bookmarkedPosts.length; i++) {
      bookmarkedPosts[i].isBookmarked = true;
    }
    return bookmarkedPosts;
  }

  Future<void> _addBookmarkToPosts(List<Post> posts) async {
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

    // postsにbookmark付けてる
    for (int i = 0; i < posts.length; i++) {
      for (QueryDocumentSnapshot bookmarkedPostDoc in bookmarkedPostDocs) {
        if (posts[i].id == bookmarkedPostDoc.id) {
          posts[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _getRepliesToPosts({
    required List<Post> posts,
    required Map<String, List<Reply>> replies,
    required List<Reply> rawReplies,
  }) async {
    if (posts.isNotEmpty) {
      for (final post in posts) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(post.uid)
            .collection('posts')
            .doc(post.id)
            .collection('replies')
            .orderBy('createdAt')
            .get();
        final docs = querySnapshot.docs;
        final _replies = docs.map((doc) => Reply(doc)).toList();
        rawReplies += _replies;
        replies[post.id] = _replies;
      }
    }
  }

  Future<void> _getRepliesToReplies({
    required List<Reply> rawReplies,
    required Map<String, List<Reply>> repliesToReply,
  }) async {
    if (rawReplies.isNotEmpty) {
      for (final reply in rawReplies) {
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
        final _repliesToReply = docs.map((doc) => Reply(doc)).toList();
        repliesToReply[reply.id] = _repliesToReply;
      }
    }
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<void> _listenAuthStateChanges() async {
    _auth.userChanges().listen((Auth.User? user) async {
      if (user == null) {
        this.loggedInUser = (await _auth.signInAnonymously()).user;
      } else {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
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
