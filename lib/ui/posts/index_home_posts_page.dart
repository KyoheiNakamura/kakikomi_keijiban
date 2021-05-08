import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/ui/components/scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/ui/posts/index_bookmarked_posts_page.dart';
import 'package:kakikomi_keijiban/ui/contact/contact_page.dart';
import 'package:kakikomi_keijiban/ui/drafts/index_drafts_page.dart';
import 'package:kakikomi_keijiban/ui/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/ui/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/ui/posts/index_my_posts_page.dart';
import 'package:kakikomi_keijiban/ui/posts/index_my_replies_page.dart';
import 'package:kakikomi_keijiban/ui/post/add_post_page.dart';
import 'package:kakikomi_keijiban/ui/posts/index_home_posts_model.dart';
import 'package:kakikomi_keijiban/ui/notices/index_notices_page.dart';
import 'package:kakikomi_keijiban/ui/search/search_page.dart';
import 'package:kakikomi_keijiban/ui/authentication/registration_method_page.dart';
import 'package:kakikomi_keijiban/ui/settings/index_settings_page.dart';
import 'package:kakikomi_keijiban/ui/authentication/sign_in_page.dart';
import 'package:provider/provider.dart';

class IndexHomePostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IndexHomePostsModel>(
      create: (context) => IndexHomePostsModel()..init(context),
      child: DefaultTabController(
        length: kTabs.length,
        child: Scaffold(
          backgroundColor: kLightPink,
          drawer: SafeArea(child: AccountDrawer()),
          body: Consumer<IndexHomePostsModel>(builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isModalLoading,
              child: SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverAppBar(
                          toolbarHeight: 50,
                          // elevation: 0,
                          title: Text('ホーム'),
                          // title: Text('発達障害困りごと掲示板（仮）'),
                          actions: [
                            IconButton(
                              icon: Icon(Icons.search, size: 24),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                model.isNoticeExisting == true
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_outlined,
                                size: 24,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IndexNoticesPage(),
                                  ),
                                );
                                model.confirmIsNoticeExisting();
                              },
                            ),
                          ],
                          floating: true,
                          pinned: true,
                          snap: true,
                          forceElevated: innerBoxIsScrolled,
                          bottom: TabBar(
                            tabs: kTabs
                                .map(
                                  (String name) => Tab(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ];
                  },

                  /// タブ名(ページ名)で表示を場合分け
                  body: TabBarView(
                    children: kTabs.map((String name) {
                      return TabBarViewChild(
                        tabName: name,
                        model: model,
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          }),
          floatingActionButton:
              Consumer<IndexHomePostsModel>(builder: (context, model, child) {
            return FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // elevation: 0,
              highlightElevation: 0,
              splashColor: kDarkPink,
              backgroundColor: kLightPink,
              label: Row(
                children: [
                  Icon(
                    Icons.create,
                    color: kDarkPink,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '投稿',
                    style: TextStyle(
                      color: kDarkPink,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                final result = await Navigator.push<valueFromShowConfirmDialog>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPostPage(),
                  ),
                );
                // 投稿された時
                if (result != valueFromShowConfirmDialog.discard) {
                  model.startModalLoading();
                  await model.getPostsWithReplies(kAllPostsTab);
                  await model.getPostsWithReplies(kMyPostsTab);
                  model.stopModalLoading();
                }
              },
            );
          }),
        ),
      ),
    );
  }
}

class TabBarViewChild extends StatelessWidget {
  TabBarViewChild({required this.tabName, required this.model});

  final String tabName;
  final IndexHomePostsModel model;

  @override
  Widget build(BuildContext context) {
    final List<Post> posts = model.getPosts(tabName);
    return Builder(
      builder: (BuildContext context) {
        return ScrollBottomNotificationListener(
          model: model,
          tabName: tabName,
          child: Scrollbar(
            thickness: 6.0,
            radius: Radius.circular(8.0),
            child: RefreshIndicator(
              onRefresh: () => model.getPostsWithReplies(tabName),
              child: CustomScrollView(
                key: PageStorageKey<String>(tabName),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: 30.0,
                      bottom: 60.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return Column(
                            children: [
                              PostCard(
                                post: post,
                                indexOfPost: index,
                                passedModel: model,
                                tabName: tabName,
                              ),
                              post == posts.last && model.isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(),
                            ],
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AccountDrawer extends StatelessWidget with ShowConfirmDialogMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<IndexHomePostsModel>(builder: (context, model, child) {
      final bool? isCurrentUserAnonymous =
          (AppModel.user?.isCurrentUserAnonymous() ?? false);
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
                      builder: (context) => IndexMyPostsPage(),
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
                      builder: (context) => IndexMyRepliesPage(),
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
                      builder: (context) => IndexBookmarkedPostsPage(),
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
                      builder: (context) => IndexDraftsPage(),
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
    return Consumer<IndexHomePostsModel>(builder: (context, model, child) {
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
                          builder: (context) => RegistrationMethodPage(),
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
