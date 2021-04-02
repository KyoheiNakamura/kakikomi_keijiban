import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:provider/provider.dart';

class BookmarkedPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).popUntil(
          ModalRoute.withName('/'),
        );
        return Future.value(true);
      },
      child: ChangeNotifierProvider<BookmarkedPostsModel>(
        create: (context) =>
            BookmarkedPostsModel()..getBookmarkedPostsWithReplies(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'ブックマークした投稿',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              Consumer<BookmarkedPostsModel>(builder: (context, model, child) {
            final List<Post> bookmarkedPosts = model.bookmarkedPosts;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
              child: SafeArea(
                child: Container(
                  color: kLightPink,
                  child: RefreshIndicator(
                    onRefresh: () => model.getBookmarkedPostsWithReplies(),
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 30.0),
                      itemBuilder: (BuildContext context, int index) {
                        final post = bookmarkedPosts[index];
                        return PostCard(
                          post: post,
                          pageName: BookmarkedPostsModel.bookmarkedPostsPage,
                        );
                      },
                      itemCount: bookmarkedPosts.length,
                    ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPostPage()),
              );
              // await model.getBookmarkedPostsWithReplies();
            },
          ),
        ),
      ),
    );
  }
}
