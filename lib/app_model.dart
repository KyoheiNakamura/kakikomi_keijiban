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
            'updatedAt': FieldValue.serverTimestamp(),
          });
          final newUserDoc =
              await _firestore.collection('users').doc(user.uid).get();
          userProfile = UserProfile(newUserDoc);
        } else {
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
}
