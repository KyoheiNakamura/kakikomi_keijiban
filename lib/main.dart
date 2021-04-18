import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/app.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

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
  runApp(App());
}
