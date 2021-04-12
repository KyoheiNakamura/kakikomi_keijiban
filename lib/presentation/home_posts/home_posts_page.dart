import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/account_drawer.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/search/search_page.dart';
import 'package:provider/provider.dart';

class HomePostsPage extends StatelessWidget {
  final List<String> _tabs = <String>[
    kAllPostsTab,
    kMyPostsTab,
    kBookmarkedPostsTab
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomePostsModel>(
      create: (context) => HomePostsModel()..init(),
      child: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          drawer: SafeArea(child: AccountDrawer()),
          body: Consumer<HomePostsModel>(builder: (context, model, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
              child: SafeArea(
                child: Container(
                  color: kLightPink,
                  child: Stack(
                    children: [
                      NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverOverlapAbsorber(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                              sliver: SliverAppBar(
                                toolbarHeight: 50,
                                // elevation: 0,
                                centerTitle: true,
                                title: Text(
                                  '発達障害困りごと掲示板',
                                  style: kAppBarTextStyle,
                                ),
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
                                      await model
                                          .getPostsWithReplies(kAllPostsTab);
                                    },
                                  ),
                                ],
                                floating: true,
                                pinned: true,
                                snap: true,
                                forceElevated: innerBoxIsScrolled,
                                bottom: TabBar(
                                  tabs: _tabs
                                      .map((String name) => Tab(text: name))
                                      .toList(),
                                ),
                              ),
                            ),
                          ];
                        },

                        /// タブ名(ページ名)で表示を場合分け
                        body: TabBarView(
                          children: _tabs.map((String name) {
                            return TabBarViewChild(tabName: name, model: model);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
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
              backgroundColor: Color(0xFFFCF0F5),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPostPage(),
                  ),
                );
                await model.getPostsWithReplies(kAllPostsTab);
                await model.getPostsWithReplies(kMyPostsTab);
                // await homeModel.getPostsWithReplies;
              },
            );
          }),
          // }),
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
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent) {
                  if (model.isLoading) {
                    return false;
                  } else {
                    if (model.getCanLoadMore(tabName)) {
                      // ignore: unnecessary_statements
                      model.loadPostsWithReplies(tabName);
                    }
                  }
                } else {
                  return false;
                }
                return false;
              },
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
                          // RangeError (index): Invalid value: Valid value range is empty: 1
                          // Todo postsが空じゃない時にpostに入れる
                          final post = posts[index];
                          return Column(
                            children: [
                              PostCard(
                                post: post,
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
            );
          },
        ),
      ),
    );
  }
}
