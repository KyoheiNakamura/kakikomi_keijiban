import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_to_reply_card/reply_to_reply_card_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/home/home_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/splash_page.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  final model = AppModel();
  @override
  Widget build(BuildContext context) {
    model.init();
    return MultiProvider(
      providers: [
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
          appBarTheme: const AppBarTheme(
            color: Color(0xFFFAFAFA),
            elevation: .5,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.grey),
            textTheme: TextTheme(headline6: kAppBarTextStyle),
          ),
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
              return SplashPage();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return HomePage();
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
