import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/account_drawer.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_model.dart';
import 'package:kakikomi_keijiban/presentation/search/search_page.dart';
import 'package:provider/provider.dart';

class HomePostsPage extends StatelessWidget {
  final List<String> _tabs = <String>['ホーム', '自分の投稿', 'ブックマーク'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        drawer: SafeArea(child: AccountDrawer()),
        body: Consumer3<HomePostsModel, MyPostsModel, BookmarkedPostsModel>(
            builder: (context, homePostsModel, myPostsModel,
                bookmarkedPostsModel, child) {
          final Map<String, dynamic> _tabPresentations = {
            'ホーム': homePostsModel,
            '自分の投稿': myPostsModel,
            // '自分の返信': myRepliesModel,
            'ブックマーク': bookmarkedPostsModel,
          };
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
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
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
                                    await homePostsModel.getPostsWithReplies;
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
                          final model = _tabPresentations[name];
                          return TabBarViewChild(name: name, model: model);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
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
                builder: (context) => AddPostPage(
                    userProfile:
                        Provider.of<HomePostsModel>(context, listen: false)
                            .userProfile),
              ),
            );
            await Provider.of<HomePostsModel>(context, listen: false)
                .getPostsWithReplies;
            await Provider.of<MyPostsModel>(context, listen: false)
                .getPostsWithReplies;
            // await homeModel.getPostsWithReplies;
          },
        ),
        // }),
      ),
    );
  }
}

class TabBarViewChild extends StatelessWidget {
  TabBarViewChild({required this.name, required this.model});

  final String name;
  final model;

  @override
  Widget build(BuildContext context) {
    final List<Post> posts = model.posts;
    return RefreshIndicator(
      onRefresh: () => model.getPostsWithReplies,
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
                    if (model.canLoadMore) {
                      // ignore: unnecessary_statements
                      model.loadPostsWithReplies;
                    }
                  }
                } else {
                  return false;
                }
                return false;
              },
              child: CustomScrollView(
                key: PageStorageKey<String>(name),
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
                                replies: model.replies[post.id],
                                givenModel: model,
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
