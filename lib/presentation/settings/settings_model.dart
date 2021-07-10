import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class SettingsModel extends ChangeNotifier {
  Future<void> signOut() async {
    await auth.signOut();
    // notifyListeners();
  }
}
