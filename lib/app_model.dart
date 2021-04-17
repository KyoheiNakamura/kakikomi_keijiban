import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:kakikomi_keijiban/domain/user.dart';

class AppModel {
  static User? user;

  static Future<void> listenAuthStateChanges() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final Auth.FirebaseAuth _auth = Auth.FirebaseAuth.instance;

    _auth.authStateChanges().listen((Auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        await _auth.signInAnonymously();
      } else {
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          await userDoc.reference.set({
            'userId': firebaseUser.uid,
            'nickname': '匿名',
            'position': '',
            'gender': '',
            'age': '',
            'area': '',
            'postCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          final newUserDoc =
              await _firestore.collection('users').doc(firebaseUser.uid).get();
          user = User(newUserDoc);
        } else {
          user = User(userDoc);
        }
      }
    });
  }

  static Future<void> reloadUser() async {
    try {
      final currentUser = Auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        user = User(userDoc);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
