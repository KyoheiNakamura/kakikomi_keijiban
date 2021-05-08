import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/contact/contact_page.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_page.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_page.dart';
import 'package:kakikomi_keijiban/presentation/settings/settings_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

class AccountDrawer extends StatelessWidget with ShowConfirmDialogMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomePostsModel>(builder: (context, model, child) {
      final bool? isCurrentUserAnonymous =
          AppModel.user?.isCurrentUserAnonymous() ?? false;
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
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPostsPage(),
                    ),
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
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyRepliesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('ブックマーク'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookmarkedPostsPage(),
                    ),
                  );
                  // await model.getPostsWithReplies(kAllPostsTab);
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.drafts),
                title: Text('下書き'),
                onTap: () async {
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                  // if (isCurrentUserAnonymous != null &&
                  //     isCurrentUserAnonymous == false) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                  if (result == valueFromShowConfirmDialog.logout) {
                    await model.signOut();
                    // Navigator.pop(context);
                    await model.reloadTabs();
                  }
                  // } else {
                  //   await Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => SelectRegistrationMethodPage(),
                  //     ),
                  //   );
                  // }
                  // Navigator.pop(context);
                },
              ),
              Divider(thickness: 1.0),
              ListTile(
                leading: Icon(Icons.alternate_email),
                title: Text('お問い合わせ'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactPage(),
                    ),
                  );
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
      return isCurrentUserAnonymous == false
          ? Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 120.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    (AppModel.user?.nickname ?? ''),
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    (AppModel.user?.email ?? ''),
                    style: TextStyle(color: kGrey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectRegistrationMethodPage(),
                        ),
                      );
                      if (result == 'signedIn') {
                        await model.reloadTabs();
                      }
                    },
                  ),
                  SizedBox(height: 16.0),
                  OutlinedButton(
                    child: Text(
                      'ログイン',
                      style: TextStyle(color: kDarkPink),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                      if (result == 'signedIn') {
                        await model.reloadTabs();
                      }
                    },
                  )
                ],
              ),
            );
    });
  }
}
