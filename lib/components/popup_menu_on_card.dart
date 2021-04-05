import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:provider/provider.dart';

enum PopupMenuItemsOnCard { update, delete }

// postかreplyのどちらかを必ずコンストラクタの引数に取る
class PopupMenuOnCard extends StatelessWidget {
  PopupMenuOnCard({this.post, this.reply});

  final Post? post;
  final Reply? reply;

  @override
  Widget build(BuildContext context) {
    final bool isPostExisting = post != null;
    Future<void> _showCardDeleteConfirmDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Consumer<PostCardModel>(builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: isPostExisting ? Text('投稿の削除') : Text('返信の削除'),
                content: Text('本当に削除しますか？'),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'キャンセル',
                      style: TextStyle(color: kDarkPink),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      '削除',
                      style: TextStyle(color: kDarkPink),
                    ),
                    onPressed: () async {
                      model.startLoading();
                      isPostExisting
                          ? await model.deletePostAndReplies(post!)
                          : await model.deleteReply(reply!);
                      await Provider.of<MyPostsModel>(context, listen: false)
                          .getPostsWithReplies;
                      await Provider.of<HomePostsModel>(context, listen: false)
                          .getPostsWithReplies;
                      await Provider.of<BookmarkedPostsModel>(context,
                              listen: false)
                          .getPostsWithReplies;
                      model.stopLoading();
                      Navigator.of(context).pop();
                      // Navigator.of(context).popUntil(
                      //   ModalRoute.withName('/'),
                      // );
                    },
                  ),
                ],
              ),
            );
          });
        },
      );
    }

    return Consumer<PostCardModel>(builder: (context, model, child) {
      return PopupMenuButton<PopupMenuItemsOnCard>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1,
        onSelected: (result) async {
          if (result == PopupMenuItemsOnCard.update) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return isPostExisting
                    ? AddPostPage(
                        userProfile:
                            Provider.of<HomePostsModel>(context, listen: false)
                                .userProfile,
                        existingPost: post)
                    : AddReplyToPostPage(
                        userProfile:
                            Provider.of<HomePostsModel>(context, listen: false)
                                .userProfile,
                        existingReply: reply);
              }),
            );
            await Provider.of<MyPostsModel>(context, listen: false)
                .getPostsWithReplies;
          } else if (result == PopupMenuItemsOnCard.delete) {
            await _showCardDeleteConfirmDialog();
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<PopupMenuItemsOnCard>(
            value: PopupMenuItemsOnCard.update,
            child: Container(
              width: 100.0,
              child: Row(
                children: [
                  Icon(Icons.update, color: kLightGrey),
                  SizedBox(width: 8.0),
                  Text(
                    '編集する',
                    style: TextStyle(color: kLightGrey),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<PopupMenuItemsOnCard>(
            value: PopupMenuItemsOnCard.delete,
            child: Container(
              width: 100.0,
              child: Row(
                children: [
                  Icon(Icons.delete, color: kLightGrey),
                  SizedBox(width: 8.0),
                  Text(
                    '削除する',
                    style: TextStyle(color: kLightGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
