import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/domain/user.dart';

class AppModel {
  static User? user;

  Future<void> init() async {
    await _listenAuthStateChanges();
    await _listenOnTokenRefresh();
  }

  Future<void> _listenAuthStateChanges() async {
    auth.authStateChanges().listen((Auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        await auth.signInAnonymously();
      } else {
        final userDoc =
            await firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          await userDoc.reference.set({
            'userId': firebaseUser.uid,
            'nickname': '匿名',
            'position': '',
            'gender': '',
            'age': '',
            'area': '',
            'postCount': 0,
            'topics': [],
            'pushNoticesSetting': kInitialpushNoticesSetting,
            'badges': {},
            'createdAt': serverTimestamp(),
            'updatedAt': serverTimestamp(),
          });
          final newUserDoc =
              await firestore.collection('users').doc(firebaseUser.uid).get();
          user = User(newUserDoc);
        } else {
          user = User(userDoc);
        }
      }
    });
  }

  Future<void> _listenOnTokenRefresh() async {
    String? token = await FirebaseMessaging.instance.getToken();

    await _saveTokenToFirebase(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToFirebase);
  }

  Future<void> _saveTokenToFirebase(String? token) async {
    String? userId = auth.currentUser?.uid;

    if (userId != null) {
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
            .set({
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
