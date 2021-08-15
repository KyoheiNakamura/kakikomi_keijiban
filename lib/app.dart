import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_to_reply_card/reply_to_reply_card_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/main/main_page.dart';
import 'package:kakikomi_keijiban/presentation/splash_page.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final model = AppModel();
  @override
  Widget build(BuildContext context) {
    model.init();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '発達障害困りごと掲示板',
      theme: ThemeData(
        primaryColor: kDarkPink,
        primaryColorDark: kDeepDarkPink,
        accentColor: kDarkPink,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          // color: Color(0xFFFAFAFA),
          color: kbackGroundGrey,
          // elevation: .5,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.grey),
          textTheme: TextTheme(headline6: kAppBarTextStyle),
        ),
        scaffoldBackgroundColor: kbackGroundGrey,
        fontFamily: 'GenShinGothic',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: FutureBuilder<void>(
        future: model.init(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashPage();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const MainPage();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
