import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_model.dart';
import 'package:provider/provider.dart';

class SearchResultPostsPage extends StatelessWidget {
  SearchResultPostsPage(this.searchWord);
  final String searchWord;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchResultPostsModel>(
      create: (context) => SearchResultPostsModel()..init(searchWord),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kLightPink,
          appBar: AppBar(
            toolbarHeight: 50,
            title: Text('$searchWord の検索結果'),
          ),
          body: Consumer<SearchResultPostsModel>(
              builder: (context, model, child) {
            final List<Post> chosenCategoryPosts = model.posts;
            return SafeArea(
              child: LoadingSpinner(
                inAsyncCall: model.isModalLoading,
                child: RefreshIndicator(
                  onRefresh: () => model.getPostsWithRepliesChosenField(),
                  child: ScrollBottomNotificationListener(
                    model: model,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 30.0),
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
              ),
            );
          }),
        ),
      ),
    );
  }
}
