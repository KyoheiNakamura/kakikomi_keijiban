import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_page.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_page.dart';
import 'package:kakikomi_keijiban/presentation/settings/settings_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

class AccountDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomePostsModel>(builder: (context, model, child) {
      final user = AppModel.user;
      final isCurrentUserAnonymous = user?.isCurrentUserAnonymous();
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ChangingDrawerHeader(isCurrentUserAnonymous),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.description),
                title: Text('自分の投稿'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPostsPage()),
                  );
                },
              ),
              ListTile(
                leading: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(Icons.reply),
                ),
                title: Text('自分の返信'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyRepliesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.star_border),
                title: Text('ブックマーク'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookmarkedPostsPage(),
                    ),
                  );
                  await model.getPostsWithReplies(kAllPostsTab);
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.drafts),
                title: Text('下書き'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DraftsPage(),
                    ),
                  );
                },
              ),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('設定'),
                onTap: () async {
                  isCurrentUserAnonymous != null &&
                          isCurrentUserAnonymous == false
                      ? await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        )
                      : await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectRegistrationMethodPage(),
                          ),
                        );
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
  ChangingDrawerHeader(this.isCurrentUserAnonymous);
  final bool? isCurrentUserAnonymous;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePostsModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: isCurrentUserAnonymous != null && isCurrentUserAnonymous == false
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppModel.user!.nickname,
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    // context.read<AppModel>().loggedInUser!.email!,
                    'アノニマスじゃないよ',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () async {
                      await model.signOut();
                      Navigator.pop(context);
                      await model.init();
                    },
                    child: Text('ログアウト'),
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
                          builder: (context) => SelectRegistrationMethodPage(),
                        ),
                      );
                      model.init();
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
                      Navigator.pop(context);
                      model.init();
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
