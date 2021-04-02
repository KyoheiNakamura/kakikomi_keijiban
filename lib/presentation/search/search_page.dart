import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/components/post_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/search/search_model.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  SearchPage(this.category);

  final String category;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchModel>(
      create: (context) =>
          SearchModel()..getPostsWithRepliesChosenCategory(category),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            elevation: 0,
            centerTitle: true,
            title: Text(
              '$categoryの検索結果',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Consumer<SearchModel>(builder: (context, model, child) {
            final List<Post> chosenCategoryPosts = model.chosenCategoryPosts;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
              child: SafeArea(
                child: Container(
                  color: kLightPink,
                  child: RefreshIndicator(
                    onRefresh: () =>
                        model.getPostsWithRepliesChosenCategory(category),
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 30.0),
                      itemBuilder: (BuildContext context, int index) {
                        final post = chosenCategoryPosts[index];
                        return PostCard(
                            post: post, pageName: SearchModel.searchPage);
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
