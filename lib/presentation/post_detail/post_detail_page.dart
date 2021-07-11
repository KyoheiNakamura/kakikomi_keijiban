import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/entity/notice.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_model.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage(this.entity);
  final dynamic entity;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailModel>(
      create: (context) => PostDetailModel()..init(entity),
      child: Scaffold(
        // backgroundColor: kLightPink,
        appBar: commonAppBar(title: '投稿'),
        body: Consumer<PostDetailModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              isModalLoading: model.isModalLoading,
              child: SingleChildScrollView(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
