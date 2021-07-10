import 'dart:async';

// ignore: library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/entity/user.dart';

class AppModel {
  static User? user;

  bool anonymousUserIsLoading = false;

  Future<void> init() async {
    await _listenAuthStateChanges();
    await _listenOnTokenRefresh();
  }

  Future<void> _listenAuthStateChanges() async {
    auth.authStateChanges().listen((Auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        // アノニマスユーザーでのログイン中にもイベントが流れくることにより、
        // signInAnonymously() が複数回呼ばれてしまうのを防ぐために
        // anonymousUserIsLoading フラグを使用している。
        if (!anonymousUserIsLoading) {
          anonymousUserIsLoading = true;
          await auth.signInAnonymously();
          anonymousUserIsLoading = false;
        }
      } else {
        final userDoc = await _getUserDoc(firebaseUser.uid);
        if (!userDoc.exists) {
          await _saveAnonymousToFirebase(userDoc);
          final newUserDoc = await _getUserDoc(firebaseUser.uid);
          user = User(newUserDoc);
        } else {
          user = User(userDoc);
        }
      }
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserDoc(String uid) async {
    final userDoc = await firestore.collection('users').doc(uid).get();
    return userDoc;
  }

  Future<void> _saveAnonymousToFirebase(
    DocumentSnapshot<Map<String, dynamic>> userDoc,
  ) async {
    await userDoc.reference.set(<String, dynamic>{
      'userId': userDoc.id,
      'nickname': '匿名',
      'position': '',
      'gender': '',
      'age': '',
      'area': '',
      'postCount': 0,
      'topics': <String>[],
      'pushNoticesSetting': kInitialpushNoticesSetting,
      'badges': <String, bool>{},
      'createdAt': serverTimestamp(),
      'updatedAt': serverTimestamp(),
    });
  }

  Future<void> _listenOnTokenRefresh() async {
    final token = await FirebaseMessaging.instance.getToken();

    await _saveTokenToFirebase(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToFirebase);
  }

  Future<void> _saveTokenToFirebase(String? token) async {
    final userId = auth.currentUser?.uid;

    if (userId != null && token != null) {
      final fetchedToken = await firestore
          .collection('users')
          .doc(userId)
          .collection('tokens')
          .doc(token)
          .get();
      if (!fetchedToken.exists) {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('tokens')
            .doc(token)
            .set(<String, String>{
          'id': token,
        });
      }
    }
  }

  static Future<void> reloadUser() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        final userDoc =
            await firestore.collection('users').doc(currentUser.uid).get();
        user = User(userDoc);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
