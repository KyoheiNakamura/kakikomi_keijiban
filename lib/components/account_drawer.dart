import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_page.dart';
import 'package:kakikomi_keijiban/presentation/settings/settings_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

class AccountDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomePostsModel>(builder: (context, model, child) {
      final bool isLoggedInUserNotAnonymous = model.loggedInUser != null &&
          model.loggedInUser!.isAnonymous == false;
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ChangingDrawerHeader(isLoggedInUserNotAnonymous),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('自分の投稿'),
                onTap: () async {
                  isLoggedInUserNotAnonymous
                      ? await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyPostsPage()),
                        )
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectRegistrationMethodPage()),
                        );
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.star_border),
                title: Text('ブックマーク'),
                onTap: () async {
                  isLoggedInUserNotAnonymous
                      ? await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookmarkedPostsPage()),
                        )
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectRegistrationMethodPage()),
                        );
                  await model.getPostsWithReplies;
                  // Navigator.pop(context);
                },
              ),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('設定'),
                onTap: () async {
                  isLoggedInUserNotAnonymous
                      ? await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                // UpdateProfilePage(model.userProfile!),
                                SettingsPage(model.userProfile!),
                          ),
                        )
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectRegistrationMethodPage(),
                          ),
                        );
                  // await model.getUserProfile();
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

class ChangingDrawerHeader extends StatelessWidget {
  ChangingDrawerHeader(this.isLoggedInUserNotAnonymous);
  final bool isLoggedInUserNotAnonymous;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePostsModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoggedInUserNotAnonymous
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    model.userProfile!.nickname,
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    model.loggedInUser!.email!,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () async {
                      await model.signOut();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ログアウト',
                    ),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(Icons.help_outline),
                          color: kDarkPink,
                        ),
                        SizedBox(width: 16.0),
                        Flexible(
                          child: Text(
                            '全ての機能をご利用いただくには新規会員登録もしくはログインが必要です。',
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  OutlinedButton(
                    child: Text(
                      '会員登録',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(kDarkPink),
                    ),
                    onPressed: () async {
                      // Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectRegistrationMethodPage()),
                      );
                      // model.getCurrentUser();
                      // Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 16.0),
                  OutlinedButton(
                    child: Text(
                      'ログイン',
                      style: TextStyle(color: kDarkPink),
                    ),
                    onPressed: () async {
                      // Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                      // model.getCurrentUser();
                      // Navigator.pop(context);
                    },
                  )
                ],
              ),
      );
    });
  }
}
