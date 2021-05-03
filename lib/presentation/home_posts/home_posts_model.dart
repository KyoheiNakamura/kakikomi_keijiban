import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_page.dart';
import 'package:kakikomi_keijiban/presentation/on_boarding/on_boarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePostsModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Post> _allPosts = [];
  List<Post> _myPosts = [];
  List<Post> _bookmarkedPosts = [];

  Query? _allPostsQuery;
  Query? _myPostsQuery;
  Query? _bookmarkedPostsQuery;

  QueryDocumentSnapshot? _allPostsLastVisible;
  QueryDocumentSnapshot? _myPostsLastVisible;
  QueryDocumentSnapshot? _bookmarkedPostsLastVisible;

  int _loadLimit = 10;
  // bool isPostsExisting = false;

  bool _allPostsCanLoadMore = false;
  bool _myPostsCanLoadMore = false;
  bool _bookmarkedPostsCanLoadMore = false;

  bool isLoading = false;
  bool isModalLoading = false;

  Future<void> init(BuildContext context) async {
    // 下二行await不要論
    await _showOnBoardingPage(context);
    await _openSpecifiedPageByNotification(context);
    startModalLoading();
    await _getAllPostsWithReplies();
    stopModalLoading();
    await _getMyPostsWithReplies();
    await _getBookmarkedPostsWithReplies();
  }

  Future<void> reloadTabs() async {
    startModalLoading();
    await _getAllPostsWithReplies();
    stopModalLoading();
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
    startModalLoading();
    if (tabName == kAllPostsTab) {
      await _getAllPostsWithReplies();
    } else if (tabName == kMyPostsTab) {
      await _getMyPostsWithReplies();
    }
    stopModalLoading();
    if (tabName == kBookmarkedPostsTab) {
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
        .doc(oldPost.userId)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    Post post = Post(doc);
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final _replies = docs.map((doc) => Reply(doc)).toList();
    post.replies = _replies;

    for (int i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
      final _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.userId)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      final _docs = _querySnapshot.docs;
      final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      reply.repliesToReply = _repliesToReplies;
    }
    // 更新前のpostをpostsから削除
    this._allPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._allPosts.insert(indexOfPost, post);
    notifyListeners();
  }

  void _removeThePostOfAllPostsAfterDeleted(Post post) {
    this._allPosts.remove(post);
    notifyListeners();
  }

  Future<void> _refreshThePostOfMyPostsAfterUpdated(
      {required Post oldPost, required int indexOfPost}) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(oldPost.userId)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    Post post = Post(doc);
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final _replies = docs.map((doc) => Reply(doc)).toList();
    post.replies = _replies;

    for (int i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
      final _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.userId)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      final _docs = _querySnapshot.docs;
      final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      reply.repliesToReply = _repliesToReplies;
    }
    // 更新前のpostをpostsから削除
    this._myPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._myPosts.insert(indexOfPost, post);
    notifyListeners();
  }

  void _removeThePostOfMyPostsAfterDeleted(Post post) {
    this._myPosts.remove(post);
    notifyListeners();
  }

  Future<void> _refreshThePostOfBookmarkedPostsAfterUpdated(
      {required Post oldPost, required int indexOfPost}) async {
    // 更新後のpostを取得
    final doc = await _firestore
        .collection('users')
        .doc(oldPost.userId)
        .collection('posts')
        .doc(oldPost.id)
        .get();
    final post = Post(doc);
    final querySnapshot = await _firestore
        .collection('users')
        .doc(post.userId)
        .collection('posts')
        .doc(post.id)
        .collection('replies')
        .orderBy('createdAt')
        .get();
    final docs = querySnapshot.docs;
    final _replies = docs.map((doc) => Reply(doc)).toList();
    post.replies = _replies;

    for (int i = 0; i < _replies.length; i++) {
      final reply = _replies[i];
      final _querySnapshot = await _firestore
          .collection('users')
          .doc(reply.userId)
          .collection('posts')
          .doc(reply.postId)
          .collection('replies')
          .doc(reply.id)
          .collection('repliesToReply')
          .orderBy('createdAt')
          .get();
      final _docs = _querySnapshot.docs;
      final _repliesToReplies = _docs.map((doc) => ReplyToReply(doc)).toList();
      reply.repliesToReply = _repliesToReplies;
    }
    // 更新前のpostをpostsから削除
    this._bookmarkedPosts.removeAt(indexOfPost);
    // 更新後のpostをpostsに追加
    this._bookmarkedPosts.insert(indexOfPost, post);
    notifyListeners();
  }

  void _removeThePostOfBookmarkedPostsAfterDeleted(Post post) {
    this._bookmarkedPosts.remove(post);
    notifyListeners();
  }

  Future<void> _getAllPostsWithReplies() async {
    startLoading();

    this._allPostsQuery = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .limit(_loadLimit);
    final querySnapshot = await this._allPostsQuery!.get();
    final docs = querySnapshot.docs;
    this._allPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._allPostsCanLoadMore = false;
      this._allPosts = [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      this._allPostsCanLoadMore = false;
      this._allPostsLastVisible = docs[docs.length - 1];
      this._allPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this._allPostsCanLoadMore = true;
      this._allPostsLastVisible = docs[docs.length - 1];
      this._allPosts = docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToAllPosts();
    await _addEmpathyToAllPosts();
    await _getAllReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadAllPostsWithReplies() async {
    startLoading();

    this._allPostsQuery = FirebaseFirestore.instance
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_allPostsLastVisible!)
        .limit(_loadLimit);
    final querySnapshot = await this._allPostsQuery!.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._allPostsCanLoadMore = false;
      this._allPosts += [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      this._allPostsCanLoadMore = false;
      this._allPostsLastVisible = docs[docs.length - 1];
      this._allPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this._allPostsCanLoadMore = true;
      this._allPostsLastVisible = docs[docs.length - 1];
      this._allPosts += docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToAllPosts();
    await _addEmpathyToAllPosts();
    await _getAllReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    this._myPostsQuery = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(_loadLimit);
    final querySnapshot = await this._myPostsQuery!.get();
    final docs = querySnapshot.docs;
    this._myPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._myPostsCanLoadMore = false;
      this._myPosts = [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = false;
      this._myPostsLastVisible = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = true;
      this._myPostsLastVisible = docs[docs.length - 1];
      this._myPosts = docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToMyPosts();
    await _addEmpathyToMyPosts();
    await _getMyReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    this._myPostsQuery = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(this._myPostsLastVisible!)
        .limit(_loadLimit);
    final querySnapshot = await this._myPostsQuery!.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._myPostsCanLoadMore = false;
      this._myPosts += [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = false;
      this._myPostsLastVisible = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      this._myPostsCanLoadMore = true;
      this._myPostsLastVisible = docs[docs.length - 1];
      this._myPosts += docs.map((doc) => Post(doc)).toList();
    }

    await _addBookmarkToMyPosts();
    await _addEmpathyToMyPosts();
    await _getMyReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startLoading();

    this._bookmarkedPostsQuery = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(_loadLimit);
    final querySnapshot = await this._bookmarkedPostsQuery!.get();
    final docs = querySnapshot.docs;
    this._bookmarkedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._bookmarkedPostsCanLoadMore = false;
      this._bookmarkedPosts = [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = false;
      this._bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts = await _getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = true;
      this._bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts = await _getBookmarkedPosts(docs);
    }

    await _addEmpathyToBookmarkedPosts();
    await _getBookmarkedReplies();

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    this._bookmarkedPostsQuery = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_bookmarkedPostsLastVisible!)
        .limit(_loadLimit);
    final querySnapshot = await this._bookmarkedPostsQuery!.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      this._bookmarkedPostsCanLoadMore = false;
      this._bookmarkedPosts += [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = false;
      this._bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts += await _getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = true;
      this._bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts += await _getBookmarkedPosts(docs);
    }

    await _addEmpathyToBookmarkedPosts();
    await _getBookmarkedReplies();

    stopLoading();
    notifyListeners();
  }

  // Todo bookmarkedPosts/{bookmarkedPost_id}にbookmarkしたpostのidのみじゃなくて、中身を全部持たせる。
  Future<List<Post>> _getBookmarkedPosts(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final postSnapshots = await Future.wait(docs
        .map((bookmarkedPost) => _firestore
            .collectionGroup('posts')
            .where('id', isEqualTo: bookmarkedPost['id'])
            // .orderBy('createdAt', descending: true)
            .get())
        .toList());
    final bookmarkedPostDocs = postSnapshots.map((postSnapshot) {
      if (postSnapshot.docs.isNotEmpty) {
        return postSnapshot.docs[0];
      } else {
        return null;
      }
    }).toList();
    // bookmarkedPostDocsからnullを全て削除
    bookmarkedPostDocs.removeWhere((element) => element == null);
    final bookmarkedPosts =
        bookmarkedPostDocs.map((doc) => Post(doc!)).toList();
    for (int i = 0; i < bookmarkedPosts.length; i++) {
      bookmarkedPosts[i].isBookmarked = true;
    }
    return bookmarkedPosts;
  }

  Future<void> _getBookmarkedPostsIds() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
  }

  Future<void> _addBookmarkToAllPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        // .orderBy('createdAt', descending: true)
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    for (int i = 0; i < this._allPosts.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
        if (this._allPosts[i].id == bookmarkedPostsIds[n]) {
          this._allPosts[i].isBookmarked = true;
        }
      }
    }
  }

  Future<void> _addBookmarkToMyPosts() async {
    final bookmarkedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        // .orderBy('createdAt', descending: true)
        .get();
    final List<String> bookmarkedPostsIds = bookmarkedPostsSnapshot.docs
        .map((bookmarkedPost) => bookmarkedPost.id)
        .toList();
    for (int i = 0; i < this._myPosts.length; i++) {
      for (int n = 0; n < bookmarkedPostsIds.length; n++) {
        if (this._myPosts[i].id == bookmarkedPostsIds[n]) {
          this._myPosts[i].isBookmarked = true;
        }
      }
    }
  }

  // 今度これでまとめよう
  Future<void> _addEmpathy(List<dynamic> list) async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    for (int i = 0; i < list.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (list[i].id == empathizedPostsIds[n]) {
          list[i].isEmpathized = true;
        }
      }
    }
  }

  Future<List<String>> _getEmpathizedPostsIds() async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    return empathizedPostsIds;
  }

  Future<void> _addEmpathyToAllPosts() async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    for (int i = 0; i < this._allPosts.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (this._allPosts[i].id == empathizedPostsIds[n]) {
          this._allPosts[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> _addEmpathyToMyPosts() async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    for (int i = 0; i < this._myPosts.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (this._myPosts[i].id == empathizedPostsIds[n]) {
          this._myPosts[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> _addEmpathyToBookmarkedPosts() async {
    final empathizedPostsSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('empathizedPosts')
        .get();
    final List<String> empathizedPostsIds = empathizedPostsSnapshot.docs
        .map((empathizedPost) => empathizedPost.id)
        .toList();
    for (int i = 0; i < this._bookmarkedPosts.length; i++) {
      for (int n = 0; n < empathizedPostsIds.length; n++) {
        if (this._bookmarkedPosts[i].id == empathizedPostsIds[n]) {
          this._bookmarkedPosts[i].isEmpathized = true;
        }
      }
    }
  }

  Future<void> _getAllReplies() async {
    final List<String> empathizedPostsIds = await _getEmpathizedPostsIds();
    for (int i = 0; i < _allPosts.length; i++) {
      final post = _allPosts[i];
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final _replies = docs.map((doc) => Reply(doc)).toList();
      for (int i = 0; i < _replies.length; i++) {
        for (int n = 0; n < empathizedPostsIds.length; n++) {
          if (_replies[i].id == empathizedPostsIds[n]) {
            _replies[i].isEmpathized = true;
          }
        }
      }
      post.replies = _replies;

      for (int i = 0; i < _replies.length; i++) {
        final reply = _replies[i];
        final _querySnapshot = await _firestore
            .collection('users')
            .doc(reply.userId)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final _docs = _querySnapshot.docs;
        final _repliesToReplies =
            _docs.map((doc) => ReplyToReply(doc)).toList();
        for (int i = 0; i < _repliesToReplies.length; i++) {
          for (int n = 0; n < empathizedPostsIds.length; n++) {
            if (_repliesToReplies[i].id == empathizedPostsIds[n]) {
              _repliesToReplies[i].isEmpathized = true;
            }
          }
        }
        reply.repliesToReply = _repliesToReplies;
      }
    }
  }

  Future<void> _getMyReplies() async {
    final List<String> empathizedPostsIds = await _getEmpathizedPostsIds();
    for (int i = 0; i < _myPosts.length; i++) {
      final post = _myPosts[i];
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final _replies = docs.map((doc) => Reply(doc)).toList();
      for (int i = 0; i < _replies.length; i++) {
        for (int n = 0; n < empathizedPostsIds.length; n++) {
          if (_replies[i].id == empathizedPostsIds[n]) {
            _replies[i].isEmpathized = true;
          }
        }
      }
      post.replies = _replies;

      for (int i = 0; i < _replies.length; i++) {
        final reply = _replies[i];
        final _querySnapshot = await _firestore
            .collection('users')
            .doc(reply.userId)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final _docs = _querySnapshot.docs;
        final _repliesToReplies =
            _docs.map((doc) => ReplyToReply(doc)).toList();
        for (int i = 0; i < _repliesToReplies.length; i++) {
          for (int n = 0; n < empathizedPostsIds.length; n++) {
            if (_repliesToReplies[i].id == empathizedPostsIds[n]) {
              _repliesToReplies[i].isEmpathized = true;
            }
          }
        }
        reply.repliesToReply = _repliesToReplies;
      }
    }
  }

  Future<void> _getBookmarkedReplies() async {
    final List<String> empathizedPostsIds = await _getEmpathizedPostsIds();
    for (int i = 0; i < _bookmarkedPosts.length; i++) {
      final post = _bookmarkedPosts[i];
      final querySnapshot = await _firestore
          .collection('users')
          .doc(post.userId)
          .collection('posts')
          .doc(post.id)
          .collection('replies')
          .orderBy('createdAt')
          .get();
      final docs = querySnapshot.docs;
      final _replies = docs.map((doc) => Reply(doc)).toList();
      for (int i = 0; i < _replies.length; i++) {
        for (int n = 0; n < empathizedPostsIds.length; n++) {
          if (_replies[i].id == empathizedPostsIds[n]) {
            _replies[i].isEmpathized = true;
          }
        }
      }
      post.replies = _replies;

      for (int i = 0; i < _replies.length; i++) {
        final reply = _replies[i];
        final _querySnapshot = await _firestore
            .collection('users')
            .doc(reply.userId)
            .collection('posts')
            .doc(reply.postId)
            .collection('replies')
            .doc(reply.id)
            .collection('repliesToReply')
            .orderBy('createdAt')
            .get();
        final _docs = _querySnapshot.docs;
        final _repliesToReplies =
            _docs.map((doc) => ReplyToReply(doc)).toList();
        for (int i = 0; i < _repliesToReplies.length; i++) {
          for (int n = 0; n < empathizedPostsIds.length; n++) {
            if (_repliesToReplies[i].id == empathizedPostsIds[n]) {
              _repliesToReplies[i].isEmpathized = true;
            }
          }
        }
        reply.repliesToReply = _repliesToReplies;
      }
    }
  }

  Future<void> _openSpecifiedPageByNotification(BuildContext context) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage?.data['page'] == 'HomePostsPage') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePostsPage()),
      );
    } else if (initialMessage?.data['page'] == 'MyPostsPage') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPostsPage()),
      );
    } else if (initialMessage?.data['page'] == 'MyRepliesPage') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyRepliesPage()),
      );
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message?.data['page'] == 'HomePostsPage') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePostsPage()),
        );
      } else if (message?.data['page'] == 'MyPostsPage') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPostsPage()),
        );
      } else if (message?.data['page'] == 'MyRepliesPage') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRepliesPage()),
        );
      }
    });
  }

  Future<void> _showOnBoardingPage(BuildContext context) async {
    final preference = await SharedPreferences.getInstance();
    // 最初の起動ならチュートリアル表示
    if (preference.getBool(kOnBoardingDoneKey) != true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingPage()),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void startModalLoading() {
    isModalLoading = true;
    notifyListeners();
  }

  void stopModalLoading() {
    isModalLoading = false;
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
