import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/account_drawer.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/search/search_page.dart';
import 'package:provider/provider.dart';

class HomePostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomePostsModel>(
      create: (context) => HomePostsModel()..init(context),
      child: SafeArea(
        child: DefaultTabController(
          length: kTabs.length,
          child: Scaffold(
            backgroundColor: kLightPink,
            drawer: SafeArea(child: AccountDrawer()),
            body: Consumer<HomePostsModel>(builder: (context, model, child) {
              return LoadingSpinner(
                inAsyncCall: model.isModalLoading,
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
                          title: Text('発達障害困りごと掲示板（仮）'),
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
              );
            }),
            floatingActionButton:
                Consumer<HomePostsModel>(builder: (context, model, child) {
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
                  final result =
                      await Navigator.push<valueFromShowConfirmDialog>(
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
      ),
    );
  }
}

class TabBarViewChild extends StatelessWidget {
  TabBarViewChild({required this.tabName, required this.model});

  final String tabName;
  final HomePostsModel model;

  @override
  Widget build(BuildContext context) {
    final List<Post> posts = model.getPosts(tabName);
    return RefreshIndicator(
      onRefresh: () => model.getPostsWithReplies(tabName),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (BuildContext context) {
            return ScrollBottomNotificationListener(
              model: model,
              tabName: tabName,
              child: Scrollbar(
                thickness: 6.0,
                radius: Radius.circular(8.0),
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
            );
          },
        ),
      ),
    );
  }
}
