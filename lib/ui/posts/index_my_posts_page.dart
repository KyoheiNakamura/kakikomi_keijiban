import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/ui/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/ui/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/ui/components/scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/ui/posts/index_my_posts_model.dart';
import 'package:provider/provider.dart';

class IndexMyPostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).popUntil(
          ModalRoute.withName('/'),
        );
        return Future.value(true);
      },
      child: ChangeNotifierProvider<IndexMyPostsModel>(
        create: (context) => IndexMyPostsModel()..init(),
        child: Scaffold(
          backgroundColor: kLightPink,
          appBar: AppBar(
            title: Text('自分の投稿'),
          ),
          body: Consumer<IndexMyPostsModel>(builder: (context, model, child) {
            final List<Post> myPosts = model.posts;
            return LoadingSpinner(
              inAsyncCall: model.isModalLoading,
              child: RefreshIndicator(
                onRefresh: () => model.getPostsWithReplies,
                child: ScrollBottomNotificationListener(
                  model: model,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 30, bottom: 60),
                    itemBuilder: (BuildContext context, int index) {
                      final post = myPosts[index];
                      return Column(
                        children: [
                          PostCard(
                            post: post,
                            indexOfPost: index,
                            passedModel: model,
                          ),
                          post == myPosts.last && model.isLoading
                              ? CircularProgressIndicator()
                              : SizedBox(),
                        ],
                      );
                    },
                    itemCount: myPosts.length,
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
