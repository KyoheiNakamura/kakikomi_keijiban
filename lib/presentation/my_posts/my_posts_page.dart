import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:provider/provider.dart';

class MyPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).popUntil(
          ModalRoute.withName('/'),
        );
        return Future.value(true);
      },
      child: ChangeNotifierProvider<MyPostsModel>(
        create: (context) => MyPostsModel()..getPostsWithReplies,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              elevation: 0,
              centerTitle: true,
              title: Text(
                '自分の投稿',
                style: kAppBarTextStyle,
              ),
            ),
            body: Consumer<MyPostsModel>(builder: (context, model, child) {
              final List<Post> myPosts = model.posts;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Theme.of(context).primaryColorDark),
                child: SafeArea(
                  child: Container(
                    color: kLightPink,
                    child: RefreshIndicator(
                      onRefresh: () => model.getPostsWithReplies,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 30.0),
                        itemBuilder: (BuildContext context, int index) {
                          final post = myPosts[index];
                          return PostCard(
                            post: post,
                            replies: model.replies[post.id],
                            isMyPostsPage: true,
                          );
                        },
                        itemCount: myPosts.length,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
