import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/account_drawer.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_page.dart';
import 'package:kakikomi_keijiban/presentation/search/search_page.dart';
import 'package:provider/provider.dart';

class HomePostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomePostsModel>(
      create: (context) => HomePostsModel()..init(context),
      child: DefaultTabController(
        length: TabType.values.length,
        child: Scaffold(
          backgroundColor: kLightPink,
          drawer: SafeArea(child: AccountDrawer()),
          body: Consumer<HomePostsModel>(
            builder: (context, model, child) {
              return LoadingSpinner(
                isModalLoading: model.isModalLoading,
                child: SafeArea(
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                          sliver: SliverAppBar(
                            toolbarHeight: 50,
                            // elevation: 0,
                            title: const Text('発達障害困りごと掲示板（仮）'),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.search, size: 24),
                                onPressed: () async {
                                  await Navigator.push<void>(
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
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NoticesPage(),
                                    ),
                                  );
                                  await model.confirmIsNoticeExisting();
                                },
                              ),
                            ],
                            floating: true,
                            pinned: true,
                            snap: true,
                            // forceElevated: innerBoxIsScrolled,
                            bottom: TabBar(
                              tabs: TabType.values.map(
                                (TabType tabType) {
                                  return Tab(
                                    child: Text(
                                      tabName(tabType),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ];
                    },

                    /// タブ名(ページ名)で表示を場合分け
                    body: TabBarView(
                      children: TabType.values.map((TabType tabType) {
                        return TabBarViewChild(
                          tabType: tabType,
                          model: model,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: Consumer<HomePostsModel>(
            builder: (context, model, child) {
              return FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // elevation: 0,
                highlightElevation: 0,
                splashColor: kDarkPink,
                backgroundColor: kLightPink,
                label: Row(
                  children: const [
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
                  final result =
                      await Navigator.push<ValueFromShowConfirmDialog>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPostPage(),
                    ),
                  );
                  // 投稿された時
                  if (result != ValueFromShowConfirmDialog.discard) {
                    model.startModalLoading();
                    await model.getPostsWithReplies(TabType.allPostsTab);
                    await model.getPostsWithReplies(TabType.myPostsTab);
                    model.stopModalLoading();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String tabName(TabType tabType) {
    switch (tabType) {
      case TabType.allPostsTab:
        return '新着の投稿';
      case TabType.myPostsTab:
        return '自分の投稿';
      case TabType.bookmarkedPostsTab:
        return 'ブックマーク';
    }
  }
}

enum TabType {
  allPostsTab,
  myPostsTab,
  bookmarkedPostsTab,
}

class TabBarViewChild extends StatelessWidget {
  const TabBarViewChild({
    required this.tabType,
    required this.model,
  });

  final TabType tabType;
  final HomePostsModel model;

  @override
  Widget build(BuildContext context) {
    final posts = model.getPosts(tabType);
    return Builder(
      builder: (BuildContext context) {
        return CommonScrollBottomNotificationListener(
          model: model,
          tabType: tabType,
          child: RefreshIndicator(
            onRefresh: () => model.getPostsWithReplies(tabType),
            child: Scrollbar(
              thickness: 6,
              radius: const Radius.circular(8),
              child: CustomScrollView(
                key: PageStorageKey<TabType>(tabType),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 60),
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
                                tabType: tabType,
                              ),
                              post == posts.last && model.isLoading
                                  ? const CircularProgressIndicator()
                                  : const SizedBox(),
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
