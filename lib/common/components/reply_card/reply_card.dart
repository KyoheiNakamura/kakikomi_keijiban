import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
// import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_to_reply_card/reply_to_reply_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/common/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_reply/add_reply_to_reply_page.dart';
import 'package:kakikomi_keijiban/presentation/update_reply/update_reply_page.dart';
import 'package:provider/provider.dart';

class ReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyCard({
    required this.reply,
    required this.post,
  });

  final Reply reply;
  final Post post;

  @override
  Widget build(BuildContext context) {
    final bool isMe = context.read<AppModel>().loggedInUser != null
        ? context.read<AppModel>().loggedInUser!.uid == reply.uid
        : false;
    return Consumer<ReplyCardModel>(builder: (context, model, child) {
      return Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          SizedBox(height: 20.0),
          Card(
            elevation: 0,
            color: kUltraLightPink,
            margin: EdgeInsets.only(top: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              // side: BorderSide(
              //   color: kLightPink,
              //   width: 2.0,
              // ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        getFormattedPosterData(reply),
                        style: TextStyle(color: kLightGrey),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                          reply.body,
                          style: TextStyle(fontSize: 16.0, height: 1.8),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 返信ボタン
                          OutlinedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddReplyToReplyPage(reply),
                                ),
                              );
                              await model.getRepliesToReply(reply);
                            },
                            child: Text(
                              '返信する',
                              style:
                                  TextStyle(color: kDarkPink, fontSize: 15.0),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              side: BorderSide(color: kPink),
                            ),
                          ),

                          /// 更新日時
                          Text(
                            reply.updatedAt,
                            style: TextStyle(color: kLightGrey),
                          ),
                        ],
                      ),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Text(
                      //     reply.createdAt,
                      //     style: TextStyle(color: kLightGrey),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                /// 返信一覧
                Column(
                  children: reply.repliesToReply.isNotEmpty
                      ? reply.repliesToReply.map((replyToReply) {
                          return Column(
                            children: [
                              ReplyToReplyCard(
                                replyToReply: replyToReply,
                                reply: reply,
                              ),
                              reply.repliesToReply.isNotEmpty &&
                                      reply.repliesToReply.last == replyToReply
                                  ? SizedBox(height: 24.0)
                                  : SizedBox(),
                            ],
                          );
                        }).toList()
                      : [],
                ),
              ],
            ),
          ),
          isMe == true
              ? Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: 10.0,
                  end: -6.0,
                  child: PopupMenuOnReplyCard(reply: reply, post: post),
                )
              : Container(),
        ],
      );
    });
  }
}

class PopupMenuOnReplyCard extends StatelessWidget {
  PopupMenuOnReplyCard({required this.reply, required this.post});

  final Reply reply;
  final Post post;

  @override
  Widget build(BuildContext context) {
    // Future<void> _showCardDeleteConfirmDialog() async {
    //   return showDialog<void>(
    //     context: context,
    //     barrierDismissible: false, // user must tap button!
    //     builder: (BuildContext context) {
    //       return Consumer<ReplyCardModel>(builder: (context, model, child) {
    //         return LoadingSpinner(
    //           inAsyncCall: model.isLoading,
    //           child: AlertDialog(
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(16.0),
    //             ),
    //             title: Text('返信の削除'),
    //             content: Text('本当に削除しますか？'),
    //             contentPadding:
    //                 EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
    //             actions: <Widget>[
    //               TextButton(
    //                 child: Text(
    //                   'キャンセル',
    //                   style: TextStyle(color: kDarkPink),
    //                 ),
    //                 onPressed: () {
    //                   Navigator.of(context).pop();
    //                 },
    //               ),
    //               TextButton(
    //                 child: Text(
    //                   '削除',
    //                   style: TextStyle(color: kDarkPink),
    //                 ),
    //                 onPressed: () async {
    //                   model.startLoading();
    //                   await model.deleteReplyAndRepliesToReply(reply);
    //                   await context
    //                       .read<PostCardModel>()
    //                       .getAllRepliesToPost(post);
    //                   // await context
    //                   //     .read<PostCardModel>()
    //                   //     .getRepliesToPost(post);
    //                   // await model.getRepliesToReply(reply);
    //
    //                   model.stopLoading();
    //                   Navigator.of(context).pop();
    //                   // Navigator.of(context).popUntil(
    //                   //   ModalRoute.withName('/'),
    //                   // );
    //                 },
    //               ),
    //             ],
    //           ),
    //         );
    //       });
    //     },
    //   );
    // }

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
                return UpdateReplyPage(reply);
              }),
            );
            await context.read<PostCardModel>().getAllRepliesToPost(post);
            // await context.read<PostCardModel>().getRepliesToPost(post);
            // await model.getRepliesToReply(reply);
          }
          // else if (result == PopupMenuItemsOnCard.delete) {
          //   await _showCardDeleteConfirmDialog();
          // }
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
          // PopupMenuDivider(),
          // PopupMenuItem<PopupMenuItemsOnCard>(
          //   value: PopupMenuItemsOnCard.delete,
          //   child: Container(
          //     width: 100.0,
          //     child: Row(
          //       children: [
          //         Icon(Icons.delete, color: kLightGrey),
          //         SizedBox(width: 8.0),
          //         Text(
          //           '削除する',
          //           style: TextStyle(color: kLightGrey),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      );
    });
  }
}
