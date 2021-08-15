import 'dart:async';
import 'dart:core';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_page.dart';
import 'package:kakikomi_keijiban/presentation/on_boarding/on_boarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeModel extends ChangeNotifier {
  bool isNoticeExisting = false;

  int selectedIndex = 0;

  Future<void> init(BuildContext context) async {
    await _showOnBoardingPage(context);
    await _openSpecifiedPageByNotification(context);
    await _confirmIsNoticeExisting();
  }

  Future<void> _openSpecifiedPageByNotification(BuildContext context) async {
    // Get any messages which caused the application to open from
    // a terminated state.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage?.data['page'] == 'HomePostsPage') {
      // await Navigator.push<void>(
      //   context,
      //   // MaterialPageRoute(builder: (context) => HomePostsPage()),
      //   MaterialPageRoute(builder: (context) => HomePage()),
      // );
    } else if (initialMessage?.data['page'] == 'MyPostsPage') {
      await Navigator.push<void>(
        context,
        // MaterialPageRoute(builder: (context) => MyPostsPage()),
        MaterialPageRoute(builder: (context) => const NoticesPage()),
      );
      await _confirmIsNoticeExisting();
    } else if (initialMessage?.data['page'] == 'MyRepliesPage') {
      await Navigator.push<void>(
        context,
        // MaterialPageRoute(builder: (context) => MyRepliesPage()),
        MaterialPageRoute(builder: (context) => const NoticesPage()),
      );
      await _confirmIsNoticeExisting();
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
      if (message?.data['page'] == 'HomePostsPage') {
        // await Navigator.push<void>(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePostsPage()),
        // );
      } else if (message?.data['page'] == 'MyPostsPage') {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => const NoticesPage()),
        );
        await _confirmIsNoticeExisting();
      } else if (message?.data['page'] == 'MyRepliesPage') {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (context) => const NoticesPage()),
        );
        await _confirmIsNoticeExisting();
      }
    });
  }

  Future<void> _showOnBoardingPage(BuildContext context) async {
    final preference = await SharedPreferences.getInstance();
    // 最初の起動ならチュートリアル表示
    if (preference.getBool(kOnBoardingDoneKey) != true) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (context) => const OnBoardingPage()),
      );
    }
  }

  Future<void> _confirmIsNoticeExisting() async {
    await AppModel.reloadUser();
    isNoticeExisting = AppModel.user?.badges['notice'] ?? false;
    notifyListeners();
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
