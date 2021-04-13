import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_to_reply_card/reply_to_reply_card_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppModel>(
          create: (context) => AppModel()..listenAuthStateChanges(),
        ),
        ChangeNotifierProvider<PostCardModel>(
          create: (context) => PostCardModel(),
        ),
        ChangeNotifierProvider<ReplyCardModel>(
          create: (context) => ReplyCardModel(),
        ),
        ChangeNotifierProvider<ReplyToReplyCardModel>(
          create: (context) => ReplyToReplyCardModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '発達障害困りごと掲示板',
        theme: ThemeData(
          primaryColor: kDarkPink,
          primaryColorDark: kDeepDarkPink,
          accentColor: kDarkPink,
          brightness: Brightness.light,
          fontFamily: 'GenShinGothic',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePostsPage(),
        },
      ),
    );
  }
}
