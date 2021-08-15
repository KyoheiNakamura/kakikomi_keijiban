import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_model.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:provider/provider.dart';

class CommonPostsPage extends StatelessWidget {
  const CommonPostsPage({
    this.title,
    required this.type,
    this.searchWord,
    Key? key,
  }) : super(key: key);

  final String? title;
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
        appBar: title != null
            ? commonAppBar(title: searchWord == null ? title! : searchWord!)
            : null,
        body: Consumer<CommonPostsModel>(
          builder: (context, model, child) {
            final posts = model.posts;
            return posts.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: () => model.getPostsWithReplies(),
                    child: CommonScrollBottomNotificationListener(
                      model: model,
                      child: ListView.builder(
                        key: key,
                        padding: const EdgeInsets.only(bottom: 32),
                        itemBuilder: (BuildContext context, int index) {
                          final post = posts[index];
                          return Column(
                            children: [
                              if (post == posts.first)
                                const SizedBox(height: 16),
                              PostCard(
                                post: post,
                                indexOfPost: index,
                                passedModel: model,
                              ),
                              if (post == posts.last && model.isLoading)
                                const CircularProgressIndicator(),
                            ],
                          );
                        },
                        itemCount: posts.length,
                      ),
                    ),
                  )
                : const Center(
                    child: Text('投稿はありません'),
                  );
          },
        ),
      ),
    );
  }
}
