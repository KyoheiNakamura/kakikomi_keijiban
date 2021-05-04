import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_page.dart';
import 'package:kakikomi_keijiban/presentation/on_boarding/on_boarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePostsModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
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
      await refreshThePostAfterUpdated(
        posts: _allPosts,
        oldPost: oldPost,
        indexOfPost: indexOfPost,
      );
      notifyListeners();
    } else if (tabName == kMyPostsTab) {
      await refreshThePostAfterUpdated(
        posts: _myPosts,
        oldPost: oldPost,
        indexOfPost: indexOfPost,
      );
      notifyListeners();
    } else if (tabName == kBookmarkedPostsTab) {
      await refreshThePostAfterUpdated(
        posts: _bookmarkedPosts,
        oldPost: oldPost,
        indexOfPost: indexOfPost,
      );
      notifyListeners();
    }
  }

  void removeThePostOfPostsAfterDeleted({
    required String tabName,
    required Post post,
  }) {
    if (tabName == kAllPostsTab) {
      removeThePostAfterDeleted(posts: _allPosts, post: post);
      notifyListeners();
    } else if (tabName == kMyPostsTab) {
      removeThePostAfterDeleted(posts: _myPosts, post: post);
      notifyListeners();
    } else if (tabName == kBookmarkedPostsTab) {
      removeThePostAfterDeleted(posts: _bookmarkedPosts, post: post);
      notifyListeners();
    }
  }

  Future<void> _getAllPostsWithReplies() async {
    startLoading();

    this._allPostsQuery = firestore
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

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(this._allPosts, bookmarkedPostsIds);
    await addEmpathy(this._allPosts, empathizedPostsIds);
    await getReplies(this._allPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadAllPostsWithReplies() async {
    startLoading();

    this._allPostsQuery = firestore
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

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(this._allPosts, bookmarkedPostsIds);
    await addEmpathy(this._allPosts, empathizedPostsIds);
    await getReplies(this._allPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    this._myPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
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

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(this._myPosts, bookmarkedPostsIds);
    await addEmpathy(this._myPosts, empathizedPostsIds);
    await getReplies(this._myPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    this._myPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
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

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(this._myPosts, bookmarkedPostsIds);
    await addEmpathy(this._myPosts, empathizedPostsIds);
    await getReplies(this._myPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startLoading();

    this._bookmarkedPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
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
      this._bookmarkedPosts = await getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = true;
      this._bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts = await getBookmarkedPosts(docs);
    }

    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addEmpathy(this._bookmarkedPosts, empathizedPostsIds);
    await getReplies(this._bookmarkedPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    this._bookmarkedPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
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
      this._bookmarkedPosts += await getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      this._bookmarkedPostsCanLoadMore = true;
      this._bookmarkedPostsLastVisible = docs[docs.length - 1];
      this._bookmarkedPosts += await getBookmarkedPosts(docs);
    }

    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addEmpathy(this._bookmarkedPosts, empathizedPostsIds);
    await getReplies(this._bookmarkedPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
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
    await auth.signOut();
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
  //   final snapshots = firestore.collection('posts').snapshots();
  //   snapshots.listen((snapshot) {
  //     final docs = snapshot.docs;
  //     final _posts = docs.map((doc) => Post(doc)).toList();
  //     _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //     this._posts = _posts;
  //     notifyListeners();
  //   });
  // }
}
