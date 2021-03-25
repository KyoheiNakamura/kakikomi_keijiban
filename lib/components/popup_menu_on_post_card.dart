import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/add_post/add_post_page.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:provider/provider.dart';

enum PopupMenuItemsOnPostCard { update, delete }

class PopupMenuOnPostCard extends StatelessWidget {
  PopupMenuOnPostCard(this.post);

  final Post post;

  @override
  Widget build(BuildContext context) {
    Future<void> _showPostDeleteConfirmDialog(HomeModel model) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
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
                  await model.deletePost(post);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Consumer<HomeModel>(builder: (context, model, child) {
      return PopupMenuButton<PopupMenuItemsOnPostCard>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1,
        onSelected: (result) async {
          if (result == PopupMenuItemsOnPostCard.update) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddPostPage(existingPost: post)),
            );
            await model.getPostsWithReplies();
          } else if (result == PopupMenuItemsOnPostCard.delete) {
            await _showPostDeleteConfirmDialog(model);
            await model.getPostsWithReplies();
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<PopupMenuItemsOnPostCard>(
            value: PopupMenuItemsOnPostCard.update,
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
          PopupMenuItem<PopupMenuItemsOnPostCard>(
            value: PopupMenuItemsOnPostCard.delete,
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
