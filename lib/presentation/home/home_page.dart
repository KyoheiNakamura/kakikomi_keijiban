import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/account_drawer.dart';
import 'package:kakikomi_keijiban/components/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/home/home_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (context) => HomeModel()
        ..listenAuthStateChanges()
        ..getPostsWithReplies(),
      child: Scaffold(
        drawer: SafeArea(child: AccountDrawer()),
        body: Consumer<HomeModel>(builder: (context, model, child) {
          final List<Post> posts = model.posts;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
            child: SafeArea(
              child: Container(
                color: kLightPink,
                child: RefreshIndicator(
                  onRefresh: () => model.getPostsWithReplies(),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        toolbarHeight: 50,
                        elevation: 0,
                        centerTitle: true,
                        title: Text(
                          'ホーム',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.search, size: 24),
                            onPressed: () async {
                              // await Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => SearchPage()),
                              // );
                              // await model.getPostsWithReplies();
                            },
                          ),
                        ],
                        // pinned: true,
                        floating: true,
                      ),
                      SliverPadding(padding: EdgeInsets.only(bottom: 30.0)),
                      // Todo 10件まですぐ表示できるようにして、他はその都度描画するみたいなふうにしよう。多分そういうプロパティかなにかがあるはず。
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = posts[index];
                            return PostCard(
                                post: post, pageName: HomeModel.homePage);
                            // return PostCard(post);
                          },
                          childCount: posts.length,
                        ),
                      ),
                      SliverPadding(padding: EdgeInsets.only(bottom: 90.0)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        floatingActionButton:
            Consumer<HomeModel>(builder: (context, model, child) {
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
              await model.getPostsWithReplies();
            },
          );
        }),
      ),
    );
  }
}
