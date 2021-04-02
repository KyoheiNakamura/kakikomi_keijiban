import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_model.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_model.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home/home_model.dart';
import 'package:kakikomi_keijiban/presentation/home/home_page.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/search/search_model.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_model.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_model.dart';
import 'package:kakikomi_keijiban/presentation/sign_up/sign_up_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeModel()),
        ChangeNotifierProvider(create: (_) => AddPostModel()),
        ChangeNotifierProvider(create: (_) => AddReplyToPostModel()),
        ChangeNotifierProvider(create: (_) => BookmarkedPostsModel()),
        ChangeNotifierProvider(create: (_) => MyPostsModel()),
        ChangeNotifierProvider(create: (_) => SearchModel()),
        ChangeNotifierProvider(create: (_) => SelectRegistrationMethodModel()),
        ChangeNotifierProvider(create: (_) => SignInModel()),
        ChangeNotifierProvider(create: (_) => SignUpModel()),
      ],
      child: MaterialApp(
        title: '発達障害困りごと掲示板',
        theme: ThemeData(
          primaryColor: kDarkPink,
          primaryColorDark: Color(0xFFa54352),
          accentColor: kDarkPink,
          brightness: Brightness.light,
          fontFamily: 'GenShinGothic',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
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
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
        },
      ),
    );
  }
}
