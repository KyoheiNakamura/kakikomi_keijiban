import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/ui/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/ui/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/ui/components/scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/ui/posts/index_search_result_posts_model.dart';
import 'package:provider/provider.dart';

class IndexSearchResultPostsPage extends StatelessWidget {
  IndexSearchResultPostsPage(this.searchWord);
  final String searchWord;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IndexSearchResultPostsModel>(
      create: (context) => IndexSearchResultPostsModel()..init(searchWord),
      child: Scaffold(
        backgroundColor: kLightPink,
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text('$searchWord の検索結果'),
        ),
        body: Consumer<IndexSearchResultPostsModel>(
            builder: (context, model, child) {
          final List<Post> chosenCategoryPosts = model.posts;
          return LoadingSpinner(
            inAsyncCall: model.isModalLoading,
            child: RefreshIndicator(
              onRefresh: () => model.getPostsWithRepliesChosenField(),
              child: ScrollBottomNotificationListener(
                model: model,
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 30, bottom: 60),
                  itemBuilder: (BuildContext context, int index) {
                    final post = chosenCategoryPosts[index];
                    return Column(
                      children: [
                        PostCard(
                          post: post,
                          indexOfPost: index,
                          passedModel: model,
                        ),
                        post == chosenCategoryPosts.last && model.isLoading
                            ? CircularProgressIndicator()
                            : SizedBox(),
                      ],
                    );
                  },
                  itemCount: chosenCategoryPosts.length,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
