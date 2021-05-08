import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/ui/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/ui/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/entity/notice.dart';
import 'package:kakikomi_keijiban/ui/post/view_post_model.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatelessWidget {
  PostDetailPage(this.notice);
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailModel>(
      create: (context) => PostDetailModel()..init(notice),
      child: Scaffold(
        backgroundColor: kLightPink,
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text('投稿'),
        ),
        body: Consumer<PostDetailModel>(builder: (context, model, child) {
          return LoadingSpinner(
            inAsyncCall: model.isModalLoading,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 30, bottom: 60),
                child: model.post != null
                    ? PostCard(
                        post: model.post!,
                        indexOfPost: 0,
                        passedModel: model,
                      )
                    : SizedBox(),
              ),
            ),
          );
        }),
      ),
    );
  }
}
