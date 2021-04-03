import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/search_result/search_result_model.dart';
import 'package:provider/provider.dart';

class SearchResultPage extends StatelessWidget {
  SearchResultPage(this.searchWord);

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
    return ChangeNotifierProvider<SearchResultModel>(
      create: (context) => SearchResultModel()
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
              '$searchWordの検索結果',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Consumer<SearchResultModel>(builder: (context, model, child) {
            final List<Post> chosenCategoryPosts = model.searchedPosts;
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
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 30.0),
                      itemBuilder: (BuildContext context, int index) {
                        final post = chosenCategoryPosts[index];
                        return PostCard(
                            post: post, pageName: SearchResultModel.searchPage);
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
