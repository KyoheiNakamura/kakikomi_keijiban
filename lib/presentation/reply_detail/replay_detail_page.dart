import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_comment_add_bar/common_comment_add_bar.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card.dart';
import 'package:kakikomi_keijiban/common/components/reply_to_reply_card/reply_to_reply_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/presentation/reply_detail/reply_detail_model.dart';
import 'package:provider/provider.dart';

class ReplyDetailPage extends StatelessWidget {
  const ReplyDetailPage({
    required this.reply,
    required this.post,
    Key? key,
  }) : super(key: key);

  final Reply reply;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReplyDetailModel>(
      create: (context) => ReplyDetailModel(reply: reply)..init(),
      child: Scaffold(
        backgroundColor: kbackGroundWhite,
        appBar: commonAppBar(
          title: 'コメント',
          backgroundColor: kbackGroundWhite,
          // action: Padding(
          //   padding: const EdgeInsets.only(right: 2),
          //   child: CardMenuButton(reply: reply),
          // ),
        ),
        body: Consumer<ReplyDetailModel>(
          builder: (context, model, child) {
            return RefreshIndicator(
              onRefresh: () => model.reloadReplies(),
              child: Column(
                children: [
                  Flexible(
                    child: CustomScrollView(
                      controller: model.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      reverse: true,
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            children: [
                              /// 返信のカード
                              ReplyCard2(
                                reply: reply,
                                post: post,
                                isReplyDetailPage: true,
                              ),

                              /// 返信とコメントの境界線
                              Container(
                                height: 12,
                                color: kbackGroundGrey,
                              ),

                              /// コメントラベル
                              Container(
                                padding: const EdgeInsets.only(left: 16),
                                width: double.infinity,
                                height: 40,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: .5,
                                      color: kUltraLightGrey,
                                    ),
                                  ),
                                ),
                                child: const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'コメント',
                                    style: TextStyle(
                                      color: kDarkGrey,
                                    ),
                                  ),
                                ),
                              ),

                              /// 返信への返信一覧
                              reply.repliesToReply.isNotEmpty
                                  ? Column(
                                      children: reply.repliesToReply
                                          .map<ReplyToReplyCard>(
                                              (replyToreply) {
                                        return ReplyToReplyCard(
                                          replyToReply: replyToreply,
                                          post: post,
                                        );
                                      }).toList(),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 80,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'まだコメントがありません',
                                          style: TextStyle(
                                            color: kDarkGrey,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flexible(
                  //   child: SingleChildScrollView(
                  //     controller: model.scrollController,
                  //     physics: const AlwaysScrollableScrollPhysics(),
                  //     reverse: true,
                  //     child: Column(
                  //       children: [
                  //         /// 返信のカード
                  //         ReplyCard2(
                  //           reply: reply,
                  //           post: post,
                  //           isReplyDetailPage: true,
                  //         ),

                  //         /// 返信とコメントの境界線
                  //         Container(
                  //           height: 12,
                  //           color: kbackGroundGrey,
                  //         ),

                  //         /// コメントラベル
                  //         Container(
                  //           padding: const EdgeInsets.only(left: 16),
                  //           width: double.infinity,
                  //           height: 40,
                  //           decoration: const BoxDecoration(
                  //             border: Border(
                  //               bottom: BorderSide(
                  //                 width: .5,
                  //                 color: kUltraLightGrey,
                  //               ),
                  //             ),
                  //           ),
                  //           child: const Align(
                  //             alignment: Alignment.centerLeft,
                  //             child: Text(
                  //               'コメント',
                  //               style: TextStyle(
                  //                 color: kDarkGrey,
                  //               ),
                  //             ),
                  //           ),
                  //         ),

                  //         /// 返信への返信一覧
                  //         reply.repliesToReply.isNotEmpty
                  //             ? Column(
                  //                 children: reply.repliesToReply
                  //                     .map<ReplyToReplyCard>((replyToreply) {
                  //                   return ReplyToReplyCard(
                  //                     replyToReply: replyToreply,
                  //                     post: post,
                  //                   );
                  //                 }).toList(),
                  //               )
                  //             : const Padding(
                  //               padding: EdgeInsets.symmetric(
                  //                   vertical: 80,
                  //                 ),
                  //               child: Center(
                  //                 child: Text(
                  //                   'まだコメントがありません',
                  //                   style: TextStyle(
                  //                     color: kDarkGrey,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  CommonCommentAddBar(reply: reply),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
