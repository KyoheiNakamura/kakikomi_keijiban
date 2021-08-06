import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:provider/provider.dart';

class BookmarkedPostsPage extends StatelessWidget {
  const BookmarkedPostsPage({Key? key}) : super(key: key);

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
        child: Scaffold(
          backgroundColor: kLightPink,
          appBar: AppBar(
            toolbarHeight: 50,
            title: const Text('ブックマークした投稿'),
          ),
          body:
              Consumer<BookmarkedPostsModel>(builder: (context, model, child) {
            final bookmarkedPosts = model.posts;
            return LoadingSpinner(
              isModalLoading: model.isModalLoading,
              child: RefreshIndicator(
                onRefresh: () => model.getPostsWithReplies,
                child: CommonScrollBottomNotificationListener(
                  model: model,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 30, bottom: 60),
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
                              ? const CircularProgressIndicator()
                              : const SizedBox(),
                        ],
                      );
                    },
                    itemCount: bookmarkedPosts.length,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
