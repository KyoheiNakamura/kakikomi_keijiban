import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';

class AppModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  Auth.User? loggedInUser;
  UserProfile? userProfile;

  Future<void> listenAuthStateChanges() async {
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

  // // ignore: close_sinks
  // final _userStateStreamController = StreamController<UserState>();
  // Stream<UserState> get userState => _userStateStreamController.stream;
  //
  // late UserState _state;
  //
  // // コンストラクタ
  // AppModel() {
  //   _init();
  // }
  //
  // // 初期化処理
  // Future _init() async {
  //   // packageの初期化処理
  //   await Firebase.initializeApp();
  //
  //   // ログイン状態の変化を監視し、変更があればUserStateをstreamで通知する
  //   FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
  //     UserState state = UserState.signedOut;
  //     final user = await _fetchUser(firebaseUser);
  //     if (user != null) {
  //       state = UserState.signedIn;
  //     }
  //
  //     // 前回と同じ通知はしない
  //     if (_state == state) {
  //       return;
  //     }
  //     _state = state;
  //
  //     // singedOut の場合すぐに SplashPage が閉じてしまうので少し待つ
  //     if (_state == UserState.signedOut) {
  //       await Future.delayed(Duration(seconds: 2));
  //     }
  //     _userStateStreamController.sink.add(_state);
  //   });
  // }
  //
  // // ユーザを取得する
  // Future<User?> _fetchUser(User? firebaseUser) async {
  //   if (firebaseUser == null) {
  //     return null;
  //   }
  //   final docUser = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(firebaseUser.uid)
  //       .get();
  //   if (!docUser.exists) {
  //     return null;
  //   }
  //   final FirebaseAuth _auth = FirebaseAuth.instance;
  //   final User user = _auth.currentUser!;
  //   return user;
  // }
}
