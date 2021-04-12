import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_page.dart';
import 'package:provider/provider.dart';

enum PopupMenuItemsOnCard { update, delete }

class PopupMenuOnPostCard extends StatelessWidget {
  PopupMenuOnPostCard({
    required this.post,
    required this.passedModel,
    this.tabName,
  });

  final Post post;
  final passedModel;
  final String? tabName;

  @override
  Widget build(BuildContext context) {
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
                title: Text('投稿の削除'),
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
                      await model.deletePostAndReplies(post);
                      // await context
                      //     .read<PostCardModel>()
                      //     .getRepliesToPost(post);
                      if (tabName != null) {
                        passedModel.getPostsWithReplies(tabName!);
                      }

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
        icon: Icon(
          Icons.more_horiz,
          color: kLightGrey,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1,
        onSelected: (result) async {
          if (result == PopupMenuItemsOnCard.update) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return UpdatePostPage(
                  post,
                  userProfile: context.read<AppModel>().userProfile,
                );
              }),
            );
            // await context.read<PostCardModel>().getRepliesToPost(post);
            if (tabName != null) {
              passedModel.getPostsWithReplies(tabName!);
            }
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
