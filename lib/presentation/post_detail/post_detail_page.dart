import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_model.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({
    required this.posterId,
    required this.postId,
    Key? key,
  }) : super(key: key);

  final String posterId;
  final String postId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailModel>(
      create: (context) => PostDetailModel(
        posterId: posterId,
        postId: postId,
      ),
      child: Scaffold(
        // backgroundColor: kLightPink,
        appBar: commonAppBar(title: '投稿'),
        body: Consumer<PostDetailModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                child: model.post != null
                    ? PostCard(
                        post: model.post!,
                        indexOfPost: 0,
                        passedModel: model,
                      )
                    : const Center(
                        child: Text('読み込み中です'),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
