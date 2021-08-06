import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_model.dart';
import 'package:provider/provider.dart';

class SearchResultPostsPage extends StatelessWidget {
  const SearchResultPostsPage({
    required this.searchWord,
    Key? key,
  }) : super(key: key);
  final String searchWord;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchResultPostsModel>(
      create: (context) => SearchResultPostsModel()..init(searchWord),
      child: Scaffold(
        backgroundColor: kLightPink,
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text('$searchWord の検索結果'),
        ),
        body: Consumer<SearchResultPostsModel>(
          builder: (context, model, child) {
            final chosenCategoryPosts = model.posts;
            return LoadingSpinner(
              isModalLoading: model.isModalLoading,
              child: RefreshIndicator(
                onRefresh: () => model.getPostsWithRepliesChosenField(),
                child: CommonScrollBottomNotificationListener(
                  model: model,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 30, bottom: 60),
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
                              ? const CircularProgressIndicator()
                              : const SizedBox(),
                        ],
                      );
                    },
                    itemCount: chosenCategoryPosts.length,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
