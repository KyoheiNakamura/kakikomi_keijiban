import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/app.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  // ステータスバーの色を kbackGroundGrey に変更
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: kbackGroundGrey,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // If your message is a notification one (includes a notification property),
  // the Firebase SDKs will intercept this and display a visible notification
  // to your users (assuming you have requested permission & the user has
  // notifications enabled). Once displayed, the background handler
  // will be executed (if provided).
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(App());
}
