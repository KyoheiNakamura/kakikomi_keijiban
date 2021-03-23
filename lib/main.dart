import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '発達障害お悩み掲示板',
      theme: ThemeData(
        primaryColor: Color(0xFFDC5A6E),
        accentColor: Color(0xFFE89AA6),
        brightness: Brightness.light,
        fontFamily: 'GenShinGothic',
        // appBarTheme: AppBarTheme(
        //   centerTitle: true,
        //   textTheme: ThemeData.light().textTheme.copyWith(
        //         headline6: TextStyle(
        //           fontFamily: "MyFont",
        //           fontSize: 18.0,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        // ),
      ),
      home: HomePage(),
    );
  }
}
