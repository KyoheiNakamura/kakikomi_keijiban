import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
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
        create: (context) => BookmarkedPostsModel()..init(),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: kLightPink,
            appBar: AppBar(
              toolbarHeight: 50,
              title: Text('ブックマークした投稿'),
            ),
            body: Consumer<BookmarkedPostsModel>(
                builder: (context, model, child) {
              final List<Post> bookmarkedPosts = model.posts;
              return SafeArea(
                child: LoadingSpinner(
                  inAsyncCall: model.isModalLoading,
                  child: RefreshIndicator(
                    onRefresh: () => model.getPostsWithReplies,
                    child: ScrollBottomNotificationListener(
                      model: model,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 30.0),
                        itemBuilder: (BuildContext context, int index) {
                          final post = bookmarkedPosts[index];
                          return Column(
                            children: [
                              PostCard(
                                post: post,
                                indexOfPost: index,
                                passedModel: model,
                              ),
                              post == bookmarkedPosts.last && model.isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(),
                            ],
                          );
                        },
                        itemCount: bookmarkedPosts.length,
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
