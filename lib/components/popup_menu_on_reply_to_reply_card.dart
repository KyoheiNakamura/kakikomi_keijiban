import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';
import 'package:kakikomi_keijiban/presentation/update_reply_to_reply/update_reply_to_reply_page.dart';
import 'package:provider/provider.dart';

enum PopupMenuItemsOnCard { update, delete }

class PopupMenuOnReplyToReplyCard extends StatelessWidget {
  PopupMenuOnReplyToReplyCard({
    required this.replyToReply,
    required this.reply,
  });

  final ReplyToReply replyToReply;
  final Reply reply;

  @override
  Widget build(BuildContext context) {
    Future<void> _showCardDeleteConfirmDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return Consumer<ReplyCardModel>(builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text('返信の削除'),
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
                      await model.deleteReplyToReply(replyToReply);
                      await context
                          .read<ReplyCardModel>()
                          .getRepliesToReply(reply);

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

    return Consumer<ReplyCardModel>(builder: (context, model, child) {
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
                return UpdateReplyToReplyPage(
                  replyToReply,
                  userProfile: context.read<AppModel>().userProfile,
                );
              }),
            );
            await context.read<ReplyCardModel>().getRepliesToReply(reply);
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
