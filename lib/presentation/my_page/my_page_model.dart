import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class MyPageModel extends ChangeNotifier {
  Future<void> signOut() async {
    await auth.signOut();
    notifyListeners();
  }
}
