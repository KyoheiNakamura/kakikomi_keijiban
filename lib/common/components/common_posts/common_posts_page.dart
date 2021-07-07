import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_model.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:provider/provider.dart';

class CommonPostsPage extends StatelessWidget {
  const CommonPostsPage({
    required this.title,
    required this.type,
    this.searchWord,
  });
  final String title;
  final CommonPostsType type;
  final String? searchWord;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CommonPostsModel>(
      create: (context) => CommonPostsModel(
        type: type,
        searchWord: searchWord,
      )..init(),
      child: Scaffold(
        backgroundColor: kLightPink,
        appBar: commonAppBar(
            title: searchWord == null ? title : '$searchWord の検索結果'),
        body: Consumer<CommonPostsModel>(
          builder: (context, model, child) {
            final posts = model.posts;
            return LoadingSpinner(
              isModalLoading: model.isModalLoading,
              child: RefreshIndicator(
                onRefresh: () => model.getPostsWithReplies(),
                child: CommonScrollBottomNotificationListener(
                  model: model,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 30, bottom: 60),
                    itemBuilder: (BuildContext context, int index) {
                      final post = posts[index];
                      return Column(
                        children: [
                          PostCard(
                            post: post,
                            indexOfPost: index,
                            passedModel: model,
                          ),
                          post == posts.last && model.isLoading
                              ? const CircularProgressIndicator()
                              : const SizedBox(),
                        ],
                      );
                    },
                    itemCount: posts.length,
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
