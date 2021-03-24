import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/components/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (context) => HomeModel()..getPostsWithReplies(),
      child: Scaffold(
        body: Consumer<HomeModel>(builder: (context, model, child) {
          final List<Post> posts = model.posts;
          return Container(
            color: kDarkPink,
            child: SafeArea(
              child: Container(
                color: Colors.white,
                child: RefreshIndicator(
                  onRefresh: () => model.getPostsWithReplies(),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        toolbarHeight: 50,
                        elevation: 0,
                        centerTitle: true,
                        leading: IconButton(
                          icon: Icon(
                            Icons.account_circle,
                            size: 30,
                          ),
                          onPressed: () {},
                        ),
                        title: Text(
                          '発達障害困りごと掲示板',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              size: 30,
                            ),
                            onPressed: () {},
                          ),
                        ],
                        // pinned: true,
                        floating: true,
                      ),
                      SliverPadding(padding: EdgeInsets.only(bottom: 30.0)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = posts[index];
                            return PostCard(post: post, index: index);
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
        floatingActionButton: Consumer<HomeModel>(builder: (
          context,
          model,
          child,
        ) {
          return FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
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
                  '投稿する',
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
