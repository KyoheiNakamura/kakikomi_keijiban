import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_to_reply_card/reply_to_reply_card_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';
import 'package:kakikomi_keijiban/common/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/update_reply_to_reply/update_reply_to_reply_page.dart';
import 'package:provider/provider.dart';

class ReplyToReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyToReplyCard({
    required this.replyToReply,
    required this.reply,
    required this.post,
    required this.passedModel,
  });

  final ReplyToReply replyToReply;
  final Reply reply;
  final Post post;
  final passedModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplyToReplyCardModel>(builder: (context, model, child) {
      return Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          SizedBox(height: 20.0),
          Card(
            elevation: 0,
            color: Colors.white,
            // margin: EdgeInsets.only(bottom: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              // side: BorderSide(
              //   color: kLightPink,
              //   width: 2.0,
              // ),
            ),
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      /// replyToReplyIcon
                      Transform(
                        alignment: Alignment.topCenter,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(
                          Icons.reply_all,
                          color: kLightGrey,
                        ),
                      ),

                      /// replierData
                      Flexible(
                        child: Center(
                          child: Text(
                            getFormattedPosterData(replyToReply),
                            style: TextStyle(color: kLightGrey),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// body
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: SelectableText.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: replyToReply.body),
                          replyToReply.createdDate != replyToReply.updatedDate
                              ? TextSpan(
                                  text: '（編集済み）',
                                  style: TextStyle(
                                    color: kLightGrey,
                                    fontSize: 15.0,
                                  ),
                                )
                              : TextSpan(),
                        ],
                      ),
                      style: TextStyle(fontSize: 16.0, height: 1.8),
                    ),
                  ),

                  /// 作成日時
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      replyToReply.createdAt,
                      style: TextStyle(color: kLightGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// EditIconButton
          replyToReply.isMe() == true && passedModel is! DraftsModel
              ? Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: -6.0,
                  end: -4.0,
                  // child: PopupMenuOnReplyToReplyCard(
                  //   replyToReply: replyToReply,
                  //   reply: reply,
                  // ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: kLightGrey,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return UpdateReplyToReplyPage(
                              existingReplyToReply: replyToReply,
                              passedModel: passedModel,
                            );
                          },
                        ),
                      );
                      await context
                          .read<ReplyCardModel>()
                          .getRepliesToReply(reply);
                    },
                  ),
                )
              : SizedBox(),

          /// EditIconButton
          replyToReply.isMe() == true &&
                  passedModel is DraftsModel &&
                  replyToReply.isDraft == true
              ? Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: -6.0,
                  end: -4.0,
                  // child: PopupMenuOnReplyToReplyCard(
                  //   replyToReply: replyToReply,
                  //   reply: reply,
                  // ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: kLightGrey,
                    ),
                    onPressed: () async {
                      final resultForDraftButton = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return UpdateReplyToReplyPage(
                              existingReplyToReply: replyToReply,
                              passedModel: passedModel,
                            );
                          },
                        ),
                      );
                      if (resultForDraftButton ==
                          ResultForDraftButton.updateDraft) {
                        await passedModel.getDrafts();
                      } else if (resultForDraftButton ==
                          ResultForDraftButton.addPostFromDraft) {
                        await passedModel.removeDraft(
                          post: post,
                          replyToReply: replyToReply,
                        );
                      }
                    },
                  ),
                )
              : SizedBox(),
        ],
      );
    });
  }
}

// class PopupMenuOnReplyToReplyCard extends StatelessWidget {
//   PopupMenuOnReplyToReplyCard({
//     required this.replyToReply,
//     required this.reply,
//   });
//
//   final ReplyToReply replyToReply;
//   final Reply reply;
//
//   @override
//   Widget build(BuildContext context) {
//     // Future<void> _showCardDeleteConfirmDialog() async {
//     //   return showDialog<void>(
//     //     context: context,
//     //     barrierDismissible: false, // user must tap button!
//     //     builder: (BuildContext context) {
//     //       return Consumer<ReplyCardModel>(builder: (context, model, child) {
//     //         return LoadingSpinner(
//     //           inAsyncCall: model.isLoading,
//     //           child: AlertDialog(
//     //             shape: RoundedRectangleBorder(
//     //               borderRadius: BorderRadius.circular(16.0),
//     //             ),
//     //             title: Text('返信の削除'),
//     //             content: Text('本当に削除しますか？'),
//     //             contentPadding:
//     //                 EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//     //             actions: <Widget>[
//     //               TextButton(
//     //                 child: Text(
//     //                   'キャンセル',
//     //                   style: TextStyle(color: kDarkPink),
//     //                 ),
//     //                 onPressed: () {
//     //                   Navigator.of(context).pop();
//     //                 },
//     //               ),
//     //               TextButton(
//     //                 child: Text(
//     //                   '削除',
//     //                   style: TextStyle(color: kDarkPink),
//     //                 ),
//     //                 onPressed: () async {
//     //                   model.startLoading();
//     //                   await model.deleteReplyToReply(replyToReply);
//     //                   await context
//     //                       .read<ReplyCardModel>()
//     //                       .getRepliesToReply(reply);
//     //
//     //                   model.stopLoading();
//     //                   Navigator.of(context).pop();
//     //                   // Navigator.of(context).popUntil(
//     //                   //   ModalRoute.withName('/'),
//     //                   // );
//     //                 },
//     //               ),
//     //             ],
//     //           ),
//     //         );
//     //       });
//     //     },
//     //   );
//     // }
//
//     return Consumer<ReplyCardModel>(builder: (context, model, child) {
//       return PopupMenuButton<PopupMenuItemsOnCard>(
//         icon: Icon(
//           Icons.more_horiz,
//           color: kLightGrey,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         elevation: 1,
//         onSelected: (result) async {
//           if (result == PopupMenuItemsOnCard.update) {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) {
//                 return UpdateReplyToReplyPage(replyToReply);
//               }),
//             );
//             await context.read<ReplyCardModel>().getRepliesToReply(reply);
//           }
//           // else if (result == PopupMenuItemsOnCard.delete) {
//           //   await _showCardDeleteConfirmDialog();
//           // }
//         },
//         itemBuilder: (BuildContext context) => [
//           PopupMenuItem<PopupMenuItemsOnCard>(
//             value: PopupMenuItemsOnCard.update,
//             child: Container(
//               width: 100.0,
//               child: Row(
//                 children: [
//                   Icon(Icons.update, color: kLightGrey),
//                   SizedBox(width: 8.0),
//                   Text(
//                     '編集する',
//                     style: TextStyle(color: kLightGrey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // PopupMenuDivider(),
//           // PopupMenuItem<PopupMenuItemsOnCard>(
//           //   value: PopupMenuItemsOnCard.delete,
//           //   child: Container(
//           //     width: 100.0,
//           //     child: Row(
//           //       children: [
//           //         Icon(Icons.delete, color: kLightGrey),
//           //         SizedBox(width: 8.0),
//           //         Text(
//           //           '削除する',
//           //           style: TextStyle(color: kLightGrey),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//         ],
//       );
//     });
//   }
// }
