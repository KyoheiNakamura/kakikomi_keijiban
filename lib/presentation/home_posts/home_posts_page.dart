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
import 'package:kakikomi_keijiban/presentation/search/search_page.dart';
import 'package:provider/provider.dart';

class HomePostsPage extends StatelessWidget {
  final List<String> _tabs = <String>['ホーム', '自分の投稿', 'ブックマーク'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length, // This is the number of tabs.
      child: Scaffold(
        drawer: SafeArea(child: AccountDrawer()),
        body: Consumer3<HomePostsModel, MyPostsModel, BookmarkedPostsModel>(
            builder: (context, homePostsModel, myPostsModel,
                bookmarkedPostsModel, child) {
          // final List<Post> posts = homePostsModel.posts;
          final Map<String, dynamic> tabPresentations = {
            'ホーム': homePostsModel,
            '自分の投稿': myPostsModel,
            'ブックマーク': bookmarkedPostsModel,
          };
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
            child: SafeArea(
              child: Container(
                color: kLightPink,
                child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    // These are the slivers that show up in the "outer" scroll view.
                    return <Widget>[
                      SliverOverlapAbsorber(
                        // This widget takes the overlapping behavior of the SliverAppBar,
                        // and redirects it to the SliverOverlapInjector below. If it is
                        // missing, then it is possible for the nested "inner" scroll view
                        // below to end up under the SliverAppBar even when the inner
                        // scroll view thinks it has not been scrolled.
                        // This is not necessary if the "headerSliverBuilder" only builds
                        // widgets that do not overlap the next sliver.
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverAppBar(
                          toolbarHeight: 50,
                          elevation: 0,
                          centerTitle: true,
                          title: Text(
                            'ホーム',
                            style: kAppBarTextStyle,
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(Icons.search, size: 24),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()),
                                );
                                await homePostsModel.getPostsWithReplies;
                              },
                            ),
                          ],
                          // pinned: true,
                          floating: true,
                          // This is the title in the app bar.
                          pinned: true,
                          // The "forceElevated" property causes the SliverAppBar to show
                          // a shadow. The "innerBoxIsScrolled" parameter is true when the
                          // inner scroll view is scrolled beyond its "zero" point, i.e.
                          // when it appears to be scrolled below the SliverAppBar.
                          // Without this, there are cases where the shadow would appear
                          // or not appear inappropriately, because the SliverAppBar is
                          // not actually aware of the precise position of the inner
                          // scroll views.
                          forceElevated: innerBoxIsScrolled,
                          bottom: TabBar(
                            // These are the widgets to put in each tab in the tab bar.
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
                    // These are the contents of the tab views, below the tabs.
                    children: _tabs.map((String name) {
                      final model = tabPresentations[name];
                      return RefreshIndicator(
                        onRefresh: () => model.getPostsWithReplies,
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            // This Builder is needed to provide a BuildContext that is
                            // "inside" the NestedScrollView, so that
                            // sliverOverlapAbsorberHandleFor() can find the
                            // NestedScrollView.
                            builder: (BuildContext context) {
                              return CustomScrollView(
                                // The "controller" and "primary" members should be left
                                // unset, so that the NestedScrollView can control this
                                // inner scroll view.
                                // If the "controller" property is set, then this scroll
                                // view will not be associated with the NestedScrollView.
                                // The PageStorageKey should be unique to this ScrollView;
                                // it allows the list to remember its scroll position when
                                // the tab view is not on the screen.
                                key: PageStorageKey<String>(name),
                                slivers: <Widget>[
                                  SliverOverlapInjector(
                                    // This is the flip side of the SliverOverlapAbsorber
                                    // above.
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(
                                            context),
                                  ),
                                  // Todo 10件まですぐ表示できるようにして、他はその都度描画するみたいなふうにしよう。多分そういうプロパティかなにかがあるはず。
                                  SliverPadding(
                                    padding: EdgeInsets.only(
                                        top: 30.0, bottom: 60.0),

                                    /// SliverListで場合分け。３パターン渡そう
                                    sliver: TabPresentationSliverList(model)
                                        .getSliverList(),
                                    // SliverList(
                                    //   delegate: SliverChildBuilderDelegate(
                                    //     (context, index) {
                                    //       final post = posts[index];
                                    //       return PostCard(
                                    //         post: post,
                                    //         replies:
                                    //             homeModel.replies[post.id],
                                    //       );
                                    //       // return PostCard(post);
                                    //     },
                                    //     childCount: posts.length,
                                    //   ),
                                    // ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        }),
        floatingActionButton:
            Consumer<HomePostsModel>(builder: (context, homeModel, child) {
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
                MaterialPageRoute(builder: (context) => AddPostPage()),
              );
              await homeModel.getPostsWithReplies;
            },
          );
        }),
      ),
    );
  }
}

class TabPresentationSliverList {
  TabPresentationSliverList(this.model);

  final model;

  SliverList getSliverList() {
    final List<Post> posts = model.posts;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            replies: model.replies[post.id],
          );
          // return PostCard(post);
        },
        childCount: posts.length,
      ),
    );
  }
}
