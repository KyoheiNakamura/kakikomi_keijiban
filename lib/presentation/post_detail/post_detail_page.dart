import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_card_menu_button/common_card_menu_button.dart';
import 'package:kakikomi_keijiban/common/components/common_comment_add_bar/common_comment_add_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_model.dart';
import 'package:provider/provider.dart';

class PostDetailPage2 extends StatelessWidget {
  const PostDetailPage2({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailModel2>(
      create: (context) => PostDetailModel2(post: post)..getLimitedReplies(),
      child: Scaffold(
        backgroundColor: kbackGroundWhite,
        appBar: commonAppBar(
          title: '投稿',
          backgroundColor: kbackGroundWhite,
          action: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: CardMenuButton(post: post),
          ),
        ),
        body: Consumer<PostDetailModel2>(
          builder: (context, model, child) {
            final replies = model.post.replies;
            return RefreshIndicator(
              onRefresh: () => model.getLimitedReplies(),
              child: CommonScrollBottomNotificationListener(
                model: model,
                child: Column(
                  children: [
                    Flexible(
                      child: CustomScrollView(
                        // controller: model.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        // reverse: true,
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// 投稿のカード
                                PostCard(
                                  post: model.post,
                                  indexOfPost: 0,
                                  passedModel: model,
                                  isPostDetailPage: true,
                                ),

                                /// 投稿とコメントの境界線
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

                                /// 返信一覧
                                model.post.replies.isNotEmpty
                                    ? Column(
                                        children: List.generate(
                                          replies.length,
                                          (index) {
                                            return Column(
                                              children: [
                                                ReplyCard2(
                                                  reply: replies[index],
                                                  post: model.post,
                                                ),
                                                if (replies[index] ==
                                                        replies.last &&
                                                    model.isLoading)
                                                  const CircularProgressIndicator(),
                                              ],
                                            );
                                          },
                                        ),

                                        //     model.post.replies.map<ReplyCard2>(
                                        //   (reply) {
                                        //     return ReplyCard2(
                                        //       reply: reply,
                                        //       post: model.post,
                                        //     );
                                        //   },
                                        // ).toList(),
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
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         /// 投稿のカード
                    //         PostCard(
                    //           post: model.post,
                    //           indexOfPost: 0,
                    //           passedModel: model,
                    //           isPostDetailPage: true,
                    //         ),

                    //         /// 投稿とコメントの境界線
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

                    //         /// 返信一覧2
                    //         post.replies.isNotEmpty
                    //             ? Column(
                    //                 children:
                    //                     post.replies.map<ReplyCard2>((reply) {
                    //                   return ReplyCard2(
                    //                     reply: reply,
                    //                     post: post,
                    //                   );
                    //                 }).toList(),
                    //               )
                    //             : Center(
                    //               child: Text(
                    //                 'まだコメントがありません',
                    //                 style: TextStyle(
                    //                   color: kDarkGrey,
                    //                 ),
                    //               ),
                    //             ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    CommonCommentAddBar(post: model.post),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 削除予定ンゴおおおおおおおおおおおおおおおおおおおおおおおお
class PostDetailPage extends StatelessWidget {
  const PostDetailPage({
    required this.posterId,
    required this.postId,
    Key? key,
  }) : super(key: key);

  final String posterId;
  final String postId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailModel>(
      create: (context) => PostDetailModel(
        posterId: posterId,
        postId: postId,
      )..init(),
      child: Scaffold(
        // backgroundColor: kLightPink,
        appBar: commonAppBar(title: '投稿'),
        body: Consumer<PostDetailModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                child: model.post != null
                    ? PostCard(
                        post: model.post!,
                        indexOfPost: 0,
                        passedModel: model,
                      )
                    : const Center(
                        child: Text('読み込み中です'),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
