import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_page.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/presentation/contact/contact_page.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_page.dart';
import 'package:kakikomi_keijiban/presentation/empathized_posts/empathized_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/my_page/my_page_model.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_page.dart';
import 'package:kakikomi_keijiban/presentation/settings/settings_page.dart';
import 'package:kakikomi_keijiban/presentation/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

class MyPage extends StatelessWidget with ShowConfirmDialogMixin {
  const MyPage();

  @override
  Widget build(BuildContext context) {
    final isCurrentUserAnonymous =
        AppModel.user?.isCurrentUserAnonymous() ?? false;
    return ChangeNotifierProvider<MyPageModel>(
      create: (context) => MyPageModel(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ChangingHeader(isCurrentUserAnonymous: isCurrentUserAnonymous),
          const Divider(thickness: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('自分の投稿'),
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommonPostsPage(
                    title: '自分の投稿',
                    type: CommonPostsType.myPosts,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.rotationY(math.pi),
              child: const Icon(Icons.reply_outlined),
            ),
            title: const Text('自分の返信'),
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommonPostsPage(
                    title: '自分の返信',
                    type: CommonPostsType.myReplies,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('ブックマーク'),
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommonPostsPage(
                    title: 'ブックマーク',
                    type: CommonPostsType.bookmarkedPosts,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('ワカル'),
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmpathizedPostsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.drafts_outlined),
            title: const Text('下書き'),
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => DraftsPage(),
                ),
              );
            },
          ),
          const Divider(thickness: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('設定'),
            onTap: () async {
              // if (isCurrentUserAnonymous != null &&
              //     isCurrentUserAnonymous == false) {
              final result = await Navigator.push<ValueFromShowConfirmDialog>(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
              if (result == ValueFromShowConfirmDialog.logout) {
                await context.read<MyPageModel>().signOut();
                // await model.reloadTabs();
              }
              // } else {
              //   await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => SelectRegistrationMethodPage(),
              //     ),
              //   );
              // }
              //
            },
          ),
          ListTile(
            leading: const Icon(Icons.alternate_email_outlined),
            title: const Text('お問い合わせ'),
            onTap: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChangingHeader extends StatelessWidget {
  const ChangingHeader({required this.isCurrentUserAnonymous});
  final bool? isCurrentUserAnonymous;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyPageModel>(
      builder: (context, model, child) {
        return isCurrentUserAnonymous == false
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppModel.user?.nickname ?? '',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppModel.user?.email ?? '',
                      style: const TextStyle(color: kGrey),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                            icon: const Icon(Icons.help_outline),
                            color: kDarkPink,
                          ),
                          const SizedBox(width: 16),
                          const Flexible(
                            child: Text(
                              '全ての機能をご利用いただくには新規会員登録もしくはログインが必要です。',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    OutlinedButton(
                      child: const Text(
                        '会員登録',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(kDarkPink),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SelectRegistrationMethodPage(),
                          ),
                        );
                        // if (result == 'signedIn') {
                        //   await model.reloadTabs();
                        // }
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      child: const Text(
                        'ログイン',
                        style: TextStyle(color: kDarkPink),
                      ),
                      onPressed: () async {
                        await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                        );
                        // if (result == 'signedIn') {
                        //   await model.reloadTabs();
                        // }
                      },
                    )
                  ],
                ),
              );
      },
    );
  }
}
