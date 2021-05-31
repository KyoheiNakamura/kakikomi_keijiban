import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/mixin/provide_common_posts_method_mixin.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_page.dart';
import 'package:kakikomi_keijiban/presentation/on_boarding/on_boarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePostsModel extends ChangeNotifier with ProvideCommonPostsMethodMixin {
  List<Post> _allPosts = [];
  List<Post> _myPosts = [];
  List<Post> _bookmarkedPosts = [];

  late Query _allPostsQuery;
  late Query _myPostsQuery;
  late Query _bookmarkedPostsQuery;

  late QueryDocumentSnapshot _allPostsLastVisible;
  late QueryDocumentSnapshot _myPostsLastVisible;
  late QueryDocumentSnapshot _bookmarkedPostsLastVisible;

  final int _loadLimit = 5;
  // bool isPostsExisting = false;

  bool _allPostsCanLoadMore = false;
  bool _myPostsCanLoadMore = false;
  bool _bookmarkedPostsCanLoadMore = false;

  // ScrollController _allPostsScrollController = ScrollController();
  // ScrollController _myPostsScrollController = ScrollController();
  // ScrollController _bookmarkedPostsScrollController = ScrollController();

  bool isLoading = false;
  bool isModalLoading = false;

  bool isNoticeExisting = false;

  Future<void> init(BuildContext context) async {
    // 下二行await不要論
    await _showOnBoardingPage(context);
    await _openSpecifiedPageByNotification(context);
    confirmIsNoticeExisting();
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

  List<Post> getPosts(TabType tabType) {
    if (tabType == TabType.allPostsTab) {
      return _allPosts;
    } else if (tabType == TabType.myPostsTab) {
      return _myPosts;
    } else if (tabType == TabType.bookmarkedPostsTab) {
      return _bookmarkedPosts;
    } else {
      return [];
    }
  }

  bool canLoadMore(TabType tabType) {
    if (tabType == TabType.allPostsTab) {
      return _allPostsCanLoadMore;
    } else if (tabType == TabType.myPostsTab) {
      return _myPostsCanLoadMore;
    } else if (tabType == TabType.bookmarkedPostsTab) {
      return _bookmarkedPostsCanLoadMore;
    } else {
      return false;
    }
  }

  Future<void> getPostsWithReplies(TabType tabType) async {
    startModalLoading();
    if (tabType == TabType.allPostsTab) {
      await _getAllPostsWithReplies();
    } else if (tabType == TabType.myPostsTab) {
      await _getMyPostsWithReplies();
    }
    stopModalLoading();
    if (tabType == TabType.bookmarkedPostsTab) {
      await _getBookmarkedPostsWithReplies();
    }
  }

  Future<void> loadPostsWithReplies(TabType tabType) async {
    if (tabType == TabType.allPostsTab) {
      await _loadAllPostsWithReplies();
    } else if (tabType == TabType.myPostsTab) {
      await _loadMyPostsWithReplies();
    } else if (tabType == TabType.bookmarkedPostsTab) {
      await _loadBookmarkedPostsWithReplies();
    }
  }

  Future<void> refreshThePostOfPostsAfterUpdated({
    required TabType tabType,
    required Post oldPost,
    required int indexOfPost,
  }) async {
    if (tabType == TabType.allPostsTab) {
      await refreshThePostAfterUpdated(
        posts: _allPosts,
        oldPost: oldPost,
        indexOfPost: indexOfPost,
      );
      notifyListeners();
    } else if (tabType == TabType.myPostsTab) {
      await refreshThePostAfterUpdated(
        posts: _myPosts,
        oldPost: oldPost,
        indexOfPost: indexOfPost,
      );
      notifyListeners();
    } else if (tabType == TabType.bookmarkedPostsTab) {
      await refreshThePostAfterUpdated(
        posts: _bookmarkedPosts,
        oldPost: oldPost,
        indexOfPost: indexOfPost,
      );
      notifyListeners();
    }
  }

  void removeThePostOfPostsAfterDeleted({
    required TabType tabType,
    required Post post,
  }) {
    if (tabType == TabType.allPostsTab) {
      removeThePostAfterDeleted(posts: _allPosts, post: post);
      notifyListeners();
    } else if (tabType == TabType.myPostsTab) {
      removeThePostAfterDeleted(posts: _myPosts, post: post);
      notifyListeners();
    } else if (tabType == TabType.bookmarkedPostsTab) {
      removeThePostAfterDeleted(posts: _bookmarkedPosts, post: post);
      notifyListeners();
    }
  }

  // ScrollController? getScrollController(TabType tabType) {
  //   if (tabType == TabType.allPostsTab) {
  //     return _allPostsScrollController;
  //   } else if (tabType == TabType.myPostsTab) {
  //     return _myPostsScrollController;
  //   } else if (tabType == TabType.bookmarkedPostsTab) {
  //     return _bookmarkedPostsScrollController;
  //   }
  // }

  Future<void> _getAllPostsWithReplies() async {
    startLoading();

    _allPostsQuery = firestore
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .limit(_loadLimit);
    final querySnapshot = await _allPostsQuery.get();
    final docs = querySnapshot.docs;
    _allPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      _allPostsCanLoadMore = false;
      _allPosts = [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      _allPostsCanLoadMore = false;
      _allPostsLastVisible = docs[docs.length - 1];
      _allPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      _allPostsCanLoadMore = true;
      _allPostsLastVisible = docs[docs.length - 1];
      _allPosts = docs.map((doc) => Post(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_allPosts, bookmarkedPostsIds);
    await addEmpathy(_allPosts, empathizedPostsIds);
    await getReplies(_allPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadAllPostsWithReplies() async {
    startLoading();

    _allPostsQuery = firestore
        .collectionGroup('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_allPostsLastVisible)
        .limit(_loadLimit);
    final querySnapshot = await _allPostsQuery.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      _allPostsCanLoadMore = false;
      _allPosts += [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      _allPostsCanLoadMore = false;
      _allPostsLastVisible = docs[docs.length - 1];
      _allPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      _allPostsCanLoadMore = true;
      _allPostsLastVisible = docs[docs.length - 1];
      _allPosts += docs.map((doc) => Post(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_allPosts, bookmarkedPostsIds);
    await addEmpathy(_allPosts, empathizedPostsIds);
    await getReplies(_allPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _getMyPostsWithReplies() async {
    startLoading();

    _myPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('posts')
        .orderBy('updatedAt', descending: true)
        .limit(_loadLimit);
    final querySnapshot = await _myPostsQuery.get();
    final docs = querySnapshot.docs;
    _myPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      _myPostsCanLoadMore = false;
      _myPosts = [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      _myPostsCanLoadMore = false;
      _myPostsLastVisible = docs[docs.length - 1];
      _myPosts = docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      _myPostsCanLoadMore = true;
      _myPostsLastVisible = docs[docs.length - 1];
      _myPosts = docs.map((doc) => Post(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_myPosts, bookmarkedPostsIds);
    await addEmpathy(_myPosts, empathizedPostsIds);
    await getReplies(_myPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadMyPostsWithReplies() async {
    startLoading();

    _myPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_myPostsLastVisible)
        .limit(_loadLimit);
    final querySnapshot = await _myPostsQuery.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      _myPostsCanLoadMore = false;
      _myPosts += [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      _myPostsCanLoadMore = false;
      _myPostsLastVisible = docs[docs.length - 1];
      _myPosts += docs.map((doc) => Post(doc)).toList();
    } else {
      // isPostsExisting = true;
      _myPostsCanLoadMore = true;
      _myPostsLastVisible = docs[docs.length - 1];
      _myPosts += docs.map((doc) => Post(doc)).toList();
    }

    final bookmarkedPostsIds = await getBookmarkedPostsIds();
    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addBookmark(_myPosts, bookmarkedPostsIds);
    await addEmpathy(_myPosts, empathizedPostsIds);
    await getReplies(_myPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _getBookmarkedPostsWithReplies() async {
    startLoading();

    _bookmarkedPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .limit(_loadLimit);
    final querySnapshot = await _bookmarkedPostsQuery.get();
    final docs = querySnapshot.docs;
    _bookmarkedPosts.clear();
    if (docs.length == 0) {
      // isPostsExisting = false;
      _bookmarkedPostsCanLoadMore = false;
      _bookmarkedPosts = [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      _bookmarkedPostsCanLoadMore = false;
      _bookmarkedPostsLastVisible = docs[docs.length - 1];
      _bookmarkedPosts = await getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      _bookmarkedPostsCanLoadMore = true;
      _bookmarkedPostsLastVisible = docs[docs.length - 1];
      _bookmarkedPosts = await getBookmarkedPosts(docs);
    }

    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addEmpathy(_bookmarkedPosts, empathizedPostsIds);
    await getReplies(_bookmarkedPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _loadBookmarkedPostsWithReplies() async {
    startLoading();

    _bookmarkedPostsQuery = firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('bookmarkedPosts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_bookmarkedPostsLastVisible)
        .limit(_loadLimit);
    final querySnapshot = await _bookmarkedPostsQuery.get();
    final docs = querySnapshot.docs;
    if (docs.length == 0) {
      // isPostsExisting = false;
      _bookmarkedPostsCanLoadMore = false;
      _bookmarkedPosts += [];
    } else if (docs.length < _loadLimit) {
      // isPostsExisting = true;
      _bookmarkedPostsCanLoadMore = false;
      _bookmarkedPostsLastVisible = docs[docs.length - 1];
      _bookmarkedPosts += await getBookmarkedPosts(docs);
    } else {
      // isPostsExisting = true;
      _bookmarkedPostsCanLoadMore = true;
      _bookmarkedPostsLastVisible = docs[docs.length - 1];
      _bookmarkedPosts += await getBookmarkedPosts(docs);
    }

    final empathizedPostsIds = await getEmpathizedPostsIds();

    await addEmpathy(_bookmarkedPosts, empathizedPostsIds);
    await getReplies(_bookmarkedPosts, empathizedPostsIds);

    stopLoading();
    notifyListeners();
  }

  Future<void> _openSpecifiedPageByNotification(BuildContext context) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage?.data['page'] == 'HomePostsPage') {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (context) => HomePostsPage()),
      );
    } else if (initialMessage?.data['page'] == 'MyPostsPage') {
      await Navigator.push<void>(
        context,
        // MaterialPageRoute(builder: (context) => MyPostsPage()),
        MaterialPageRoute(builder: (context) => NoticesPage()),
      );
      await confirmIsNoticeExisting();
    } else if (initialMessage?.data['page'] == 'MyRepliesPage') {
      await Navigator.push<void>(
        context,
        // MaterialPageRoute(builder: (context) => MyRepliesPage()),
        MaterialPageRoute(builder: (context) => NoticesPage()),
      );
      await confirmIsNoticeExisting();
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
      if (message?.data['page'] == 'HomePostsPage') {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => HomePostsPage()),
        );
      } else if (message?.data['page'] == 'MyPostsPage') {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => NoticesPage()),
        );
        await confirmIsNoticeExisting();
      } else if (message?.data['page'] == 'MyRepliesPage') {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => NoticesPage()),
        );
        await confirmIsNoticeExisting();
      }
    });
  }

  Future<void> _showOnBoardingPage(BuildContext context) async {
    final preference = await SharedPreferences.getInstance();
    // 最初の起動ならチュートリアル表示
    if (preference.getBool(kOnBoardingDoneKey) != true) {
      Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingPage()),
      );
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    notifyListeners();
  }

  Future<void> confirmIsNoticeExisting() async {
    await AppModel.reloadUser();
    isNoticeExisting = AppModel.user?.badges['notice'] ?? false;
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
  //     _posts = _posts;
  //     notifyListeners();
  //   });
  // }
}
