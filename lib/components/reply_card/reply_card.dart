import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/components/reply_card/reply_card_model.dart';
import 'package:kakikomi_keijiban/components/reply_to_reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply/add_reply_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:provider/provider.dart';

class ReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyCard({
    required this.reply,
    required this.passedModel,
    this.tabName,
  });

  final Reply reply;
  final passedModel;
  final String? tabName;

  @override
  Widget build(BuildContext context) {
    // Todo 返信後のrepliesToReplyはreplyCardModelでquery出してとってきたら良き？
    // Todo postと同じ要領でreplyドメインにrepliesToReply持たせよう。
    reply.repliesToReply = tabName != null
        ? passedModel.getRepliesToReply(tabName)[reply.id]
        : passedModel.repliesToReply[reply.id];
    final bool isMe = FirebaseAuth.instance.currentUser != null
        ? FirebaseAuth.instance.currentUser!.uid == reply.uid
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
                                    userProfile: Provider.of<HomePostsModel>(
                                      context,
                                      listen: false,
                                    ).userProfile,
                                  ),
                                ),
                              );
                              model.getRepliesToReply(reply);
                              // await context
                              //     .read<HomePostsModel>()
                              //     .getPostsWithReplies(kAllPostsTab);
                              // await context
                              //     .read<MyPostsModel>()
                              //     .getPostsWithReplies;
                              // await context
                              //     .read<BookmarkedPostsModel>()
                              //     .getPostsWithReplies;
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
                      ? reply.repliesToReply!.map((reply) {
                          return Column(
                            children: [
                              ReplyToReplyCard(replyToReply: reply),
                              reply.repliesToReply!.last == reply
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
                  child: PopupMenuOnCard(reply: reply),
                )
              : Container(),
        ],
      );
    });
  }
}
