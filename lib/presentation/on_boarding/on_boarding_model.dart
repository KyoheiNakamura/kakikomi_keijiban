import 'dart:core';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingModel extends ChangeNotifier {
  int currentPage = 0;

  void onPageChangedCallBack(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  Future<void> completeOnBoardingPage(BuildContext context) async {
    final preference = await SharedPreferences.getInstance();
    // チュートリアル終了後に環境変数をtrueでセットする。
    await preference.setBool(kOnBoardingDoneKey, true);
    Navigator.pop(context);
  }
}
