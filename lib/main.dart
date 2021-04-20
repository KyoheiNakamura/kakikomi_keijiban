import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/app.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kDeepDarkPink, // status bar color
    statusBarBrightness: Brightness.dark, //status bar brightness
    // statusBarIconBrightness: Brightness.light, //status barIcon brightness
    // systemNavigationBarColor: Colors.blue, // navigation bar color
    // systemNavigationBarDividerColor: Colors.greenAccent,//Navigation bar divider color
    // systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
  ));
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(App());
}
