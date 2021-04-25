import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/my_replies/my_replies_model.dart';
import 'package:provider/provider.dart';

class MyRepliesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).popUntil(
          ModalRoute.withName('/'),
        );
        return Future.value(true);
      },
      child: ChangeNotifierProvider<MyRepliesModel>(
        create: (context) => MyRepliesModel()..init(),
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              title: Text(
                '自分の返信',
                style: kAppBarTextStyle,
              ),
            ),
            body: Consumer<MyRepliesModel>(builder: (context, model, child) {
              final List<Post> postsWithMyReplies = model.posts;
              // return AnnotatedRegion<SystemUiOverlayStyle>(
              //   value: SystemUiOverlayStyle.light
              //       .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
              return SafeArea(
                child: LoadingSpinner(
                  inAsyncCall: model.isModalLoading,
                  child: Container(
                    color: kLightPink,
                    child: RefreshIndicator(
                      onRefresh: () => model.getPostsWithReplies,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels ==
                              notification.metrics.maxScrollExtent) {
                            if (model.isLoading) {
                              return false;
                            } else {
                              if (model.canLoadMore) {
                                // ignore: unnecessary_statements
                                model.loadPostsWithReplies;
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
                            final post = postsWithMyReplies[index];
                            return Column(
                              children: [
                                PostCard(
                                  post: post,
                                  indexOfPost: index,
                                  passedModel: model,
                                ),
                                post == postsWithMyReplies.last &&
                                        model.isLoading
                                    ? CircularProgressIndicator()
                                    : SizedBox(),
                              ],
                            );
                          },
                          itemCount: postsWithMyReplies.length,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              // );
            }),
          ),
        ),
      ),
    );
  }
}
