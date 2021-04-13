import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_model.dart';
import 'package:provider/provider.dart';

class SearchResultPostsPage extends StatelessWidget {
  SearchResultPostsPage(this.searchWord);

  final String searchWord;

  @override
  Widget build(BuildContext context) {
    final String postField;
    if (kCategoryList.contains(searchWord)) {
      postField = 'categories';
    } else if (kEmotionList.contains(searchWord)) {
      postField = 'emotion';
    } else if (kPositionList.contains(searchWord)) {
      postField = 'position';
    } else if (kGenderList.contains(searchWord)) {
      postField = 'gender';
    } else if (kAgeList.contains(searchWord)) {
      postField = 'age';
    } else if (kAreaList.contains(searchWord)) {
      postField = 'area';
    } else {
      postField = '';
    }
    return ChangeNotifierProvider<SearchResultPostsModel>(
      create: (context) => SearchResultPostsModel()
        ..getPostsWithRepliesChosenField(
          postField: postField,
          value: searchWord,
        ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            elevation: 0,
            centerTitle: true,
            title: Text(
              '$searchWord の検索結果',
              style: kAppBarTextStyle,
            ),
          ),
          body: Consumer<SearchResultPostsModel>(
              builder: (context, model, child) {
            final List<Post> chosenCategoryPosts = model.posts;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
              child: SafeArea(
                child: Container(
                  color: kLightPink,
                  child: RefreshIndicator(
                    onRefresh: () => model.getPostsWithRepliesChosenField(
                      postField: postField,
                      value: searchWord,
                    ),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels ==
                            notification.metrics.maxScrollExtent) {
                          if (model.isLoading) {
                            return false;
                          } else {
                            if (model.canLoadMore) {
                              model.loadPostsWithRepliesChosenField(
                                postField: postField,
                                value: searchWord,
                              );
                            }
                          }
                        } else {
                          return false;
                        }
                        return false;
                      },
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
                              post == chosenCategoryPosts.last &&
                                      model.isLoading
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
              ),
            );
          }),
        ),
      ),
    );
  }
}
