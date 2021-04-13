import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';

class HomePostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  List<Post> _allPosts = [];
  List<Post> _myPosts = [];
  List<Post> _bookmarkedPosts = [];

  Map<String, List<Reply>> _allReplies = {};
  Map<String, List<Reply>> _myReplies = {};
  Map<String, List<Reply>> _bookmarkedReplies = {};

  List<Reply> _allRawReplies = [];
  List<Reply> _myRawReplies = [];
  List<Reply> _bookmarkedRawReplies = [];

  Map<String, List<ReplyToReply>> _allRepliesToReply = {};
  Map<String, List<ReplyToReply>> _myRepliesToReply = {};
  Map<String, List<ReplyToReply>> _bookmarkedRepliesToReply = {};

  Query? allPostsQuery;
  Query? myPostsQuery;
  Query? bookmarkedPostsQuery;

  QueryDocumentSnapshot? allPostsLastVisible;
  QueryDocumentSnapshot? myPostsLastVisible;
  QueryDocumentSnapshot? bookmarkedPostsLastVisible;
  int loadLimit = 10;
  // // bool isPostsExisting = false;
  bool _allPostsCanLoadMore = false;
  bool _myPostsCanLoadMore = false;
  bool _bookmarkedPostsCanLoadMore = false;
  bool isLoading = false;

  Future<void> init() async {
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

  Map<String, List<ReplyToReply>> getRepliesToReply(String tabName) {
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

  Future<void> refreshThePostOfPostsAfterUpdated({
    required String tabName,
    required Post oldPost,
    required int indexOfPost,
  }) async {
    if (tabName == kAllPostsTab) {
      await _refreshThePostOfAllPostsAfterUpdated(
          oldPost: oldPost, indexOfPost: indexOfPost);
    } else if (tabName == kMyPostsTab) {
      await _refreshThePostOfMyPostsAfterUpdated(
          oldPost: oldPost, indexOfPost: indexOfPost);
    } else if (tabName == kBookmarkedPostsTab) {
      await _refreshThePostOfBookmarkedPostsAfterUpdated(
          oldPost: oldPost, indexOfPost: indexOfPost);
    }
  }

  void removeThePostOfPostsAfterDeleted({
    required String tabName,
    required Post post,
  }) {
    if (tabName == kAllPostsTab) {
      _removeThePostOfAllPostsAfterDeleted(post);
    } else if (tabName == kMyPostsTab) {
      _removeThePostOfMyPostsAfterDeleted(post);
    } else if (tabName == kBookmarkedPostsTab) {
      _removeThePostOfBookmarkedPostsAfterDeleted(post);
    }
  }

  Future<void> _refreshThePostOfAllPostsAfterUpdated({
    required Post oldPost,
    required int indexOfPost,
  }) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    Post newPost = Post(doc);
    // 更新前のpostをpostsから削除
    _allPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    _allPosts.insert(indexOfPost, newPost);
    notifyListeners();
  }

  void _removeThePostOfAllPostsAfterDeleted(Post post) {
    _allPosts.remove(post);
    notifyListeners();
  }

  Future<void> _refreshThePostOfMyPostsAfterUpdated(
      {required Post oldPost, required int indexOfPost}) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    Post newPost = Post(doc);
    // 更新前のpostをpostsから削除
    _myPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    _myPosts.insert(indexOfPost, newPost);
    notifyListeners();
  }

  void _removeThePostOfMyPostsAfterDeleted(Post post) {
    _myPosts.remove(post);
    notifyListeners();
  }

  Future<void> _refreshThePostOfBookmarkedPostsAfterUpdated(
      {required Post oldPost, required int indexOfPost}) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    Post newPost = Post(doc);
    // 更新前のpostをpostsから削除
    _bookmarkedPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    _bookmarkedPosts.insert(indexOfPost, newPost);
    notifyListeners();
  }

  void _removeThePostOfBookmarkedPostsAfterDeleted(Post post) {
    _bookmarkedPosts.remove(post);
    notifyListeners();
  }

  Future<void> _getAllPostsWithReplies() async {
    startLoading();

    this.allPostsQuery = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await this.allPostsQuery!.get();
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
    await _getAllRepliesToPosts();
    await _getAllRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadAllPostsWithReplies() async {
    startLoading();

    this.allPostsQuery = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(allPostsLastVisible!)
        .limit(loadLimit);
    final querySnapshot = await this.allPostsQuery!.get();
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
    await _getAllRepliesToPosts();
    await _getAllRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    this.myPostsQuery = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await this.myPostsQuery!.get();
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
    await _getMyRepliesToPosts();
    await _getMyRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    this.myPostsQuery = _firestore
        .collection('users')
        .doc(uid)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(myPostsLastVisible!)
        .limit(loadLimit);
    final querySnapshot = await this.myPostsQuery!.get();
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
    await _getMyRepliesToPosts();
    await _getMyRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startLoading();

    this.bookmarkedPostsQuery = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit);
    final querySnapshot = await this.bookmarkedPostsQuery!.get();
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

    await _getBookmarkedRepliesToPosts();
    await _getBookmarkedRepliesToReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    this.bookmarkedPostsQuery = _firestore
        .collection('users')
        .doc(uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(bookmarkedPostsLastVisible!)
        .limit(loadLimit);
    final querySnapshot = await this.bookmarkedPostsQuery!.get();
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

    await _getBookmarkedRepliesToPosts();
    await _getBookmarkedRepliesToReplies();

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

  Future<void> _getAllRepliesToPosts() async {
    if (_allPosts.isNotEmpty) {
      for (final post in _allPosts) {
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
        this._allRawReplies += _replies;
        this._allReplies[post.id] = _replies;
      }
    }
  }

  Future<void> _getMyRepliesToPosts() async {
    if (_myPosts.isNotEmpty) {
      for (final post in _myPosts) {
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
        this._myRawReplies += _replies;
        this._myReplies[post.id] = _replies;
      }
    }
  }

  Future<void> _getBookmarkedRepliesToPosts() async {
    if (_bookmarkedPosts.isNotEmpty) {
      for (final post in _bookmarkedPosts) {
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
        this._bookmarkedRawReplies += _replies;
        this._bookmarkedReplies[post.id] = _replies;
      }
    }
  }

  Future<void> _getAllRepliesToReplies() async {
    if (_allRawReplies.isNotEmpty) {
      for (final reply in _allRawReplies) {
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
        final _repliesToReply = docs.map((doc) => ReplyToReply(doc)).toList();
        this._allRepliesToReply[reply.id] = _repliesToReply;
      }
    }
  }

  Future<void> _getMyRepliesToReplies() async {
    if (_myRawReplies.isNotEmpty) {
      for (final reply in _myRawReplies) {
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
        final _repliesToReply = docs.map((doc) => ReplyToReply(doc)).toList();
        this._myRepliesToReply[reply.id] = _repliesToReply;
      }
    }
  }

  Future<void> _getBookmarkedRepliesToReplies() async {
    if (_bookmarkedRawReplies.isNotEmpty) {
      for (final reply in _bookmarkedRawReplies) {
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
        final _repliesToReply = docs.map((doc) => ReplyToReply(doc)).toList();
        this._bookmarkedRepliesToReply[reply.id] = _repliesToReply;
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
