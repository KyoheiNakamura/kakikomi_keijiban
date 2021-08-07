import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';

class SettingsModel extends ChangeNotifier {
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } on Exception catch (e) {
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    }
  }
}
