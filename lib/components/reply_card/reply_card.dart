import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_reply_card.dart';
import 'package:kakikomi_keijiban/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/components/reply_to_reply_card/reply_to_reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply/add_reply_page.dart';
import 'package:provider/provider.dart';

class ReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyCard({
    required this.post,
    required this.reply,
    required this.passedModel,
    this.tabName,
  });

  final Post post;
  final Reply reply;
  final passedModel;
  final String? tabName;

  @override
  Widget build(BuildContext context) {
    reply.repliesToReply = tabName != null
        ? passedModel.getRepliesToReply(tabName)[reply.id]
        : passedModel.repliesToReply[reply.id];
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
                                  builder: (context) => AddReplyPage(
                                    repliedReply: reply,
                                    userProfile:
                                        context.read<AppModel>().userProfile,
                                  ),
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
                  children: reply.repliesToReply != null
                      ? reply.repliesToReply!.map((replyToReply) {
                          return Column(
                            children: [
                              ReplyToReplyCard(
                                replyToReply: replyToReply,
                                reply: reply,
                              ),
                              reply.repliesToReply!.isNotEmpty &&
                                      reply.repliesToReply!.last == replyToReply
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
