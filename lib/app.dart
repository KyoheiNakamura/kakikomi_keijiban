import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_model.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostCardModel>(
      create: (context) => PostCardModel(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => HomePostsModel()
              ..getPostsWithReplies
              ..listenAuthStateChanges(),
          ),
          ChangeNotifierProvider(
            create: (_) => PostCardModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => MyPostsModel()..getPostsWithReplies,
          ),
          // ChangeNotifierProvider(
          //   create: (_) => MyRepliesModel()..getPostsWithReplies,
          // ),
          ChangeNotifierProvider(
            create: (_) => BookmarkedPostsModel()..getPostsWithReplies,
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
      ),
    );
  }
}
