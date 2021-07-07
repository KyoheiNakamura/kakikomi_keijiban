import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/common/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply/add_reply_page.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_model.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_page.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget with FormatPosterDataMixin {
  PostCard({
    required this.post,
    required this.indexOfPost,
    required this.passedModel,
    this.tabType,
  });

  final Post post;
  final int indexOfPost;
  final dynamic passedModel;
  final TabType? tabType;

  @override
  Widget build(BuildContext context) {
    return Consumer<PostCardModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      /// カテゴリーのActionChipを表示してる
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 4,
                            // runSpacing: 2,
                            // alignment: WrapAlignment.center,
                            children: post.categories != null
                                ? post.categories!.map<Widget>((category) {
                                    return ActionChip(
                                      label: Text(
                                        category,
                                        style:
                                            const TextStyle(color: kDarkPink),
                                      ),
                                      backgroundColor: kUltraLightPink,
                                      pressElevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(color: kPink),
                                      ),
                                      onPressed: () async {
                                        await Navigator.push<void>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SearchResultPostsPage(category),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList()
                                : [],
                          ),
                        ),
                      ),

                      /// title
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8, left: 8, right: 8),
                        child: Text(
                          post.title != null ? post.title! : '',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),

                      /// posterData
                      Text(
                        getFormattedPosterData(post),
                        style: const TextStyle(color: kGrey),
                      ),

                      /// body
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: post.body),
                              post.createdDate != post.updatedDate
                                  ? const TextSpan(
                                      text: '（編集済み）',
                                      style: TextStyle(
                                        color: kGrey,
                                        fontSize: 15,
                                      ),
                                    )
                                  : const TextSpan(),
                            ],
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.8,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      /// 作成日時
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          post.createdDate,
                          style: const TextStyle(color: kGrey),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 返信ボタン
                          passedModel is! DraftsModel
                              ? OutlinedButton(
                                  onPressed: () async {
                                    await Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddReplyPage(post),
                                      ),
                                    );
                                    await model.getAllRepliesToPost(post);
                                  },
                                  child: const Text(
                                    '返信する',
                                    style: TextStyle(
                                      color: kDarkPink,
                                      fontSize: 15,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: const BorderSide(color: kPink),
                                    primary: kDarkPink,
                                  ),
                                )
                              : const SizedBox(),

                          /// ワカルボタン
                          passedModel is! DraftsModel
                              ? post.isEmpathized
                                  ? TextButton.icon(
                                      onPressed: () async {
                                        // 下二行はワカル１回のみできるとき用
                                        model.turnOffEmpathyButton(post);
                                        await model.deleteEmpathizedPost(post);
                                      },
                                      icon: Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            color: Colors.pinkAccent,
                                          ),
                                          Image.asset(
                                            'lib/assets/images/anpanman_emoji.gif',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ],
                                      ),
                                      style: TextButton.styleFrom(
                                        primary: kDarkPink,
                                      ),
                                      label: Row(
                                        children: [
                                          post.empathyCount != 0
                                              ? Text(
                                                  '${post.empathyCount} ',
                                                  style: const TextStyle(
                                                    color: kDarkPink,
                                                  ),
                                                )
                                              : const SizedBox(),
                                          const Text(
                                            'ワカル',
                                            style: TextStyle(
                                              color: kDarkPink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: () async {
                                        model.turnOnEmpathyButton(post);
                                        await model.addEmpathizedPost(post);
                                      },
                                      icon: Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite_border_outlined,
                                            color: kGrey,
                                          ),
                                          Image.asset(
                                            'lib/assets/images/anpanman_emoji.gif',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ],
                                      ),
                                      style: TextButton.styleFrom(
                                        primary: kDarkPink,
                                      ),
                                      label: Row(
                                        children: [
                                          post.empathyCount != 0
                                              ? Text(
                                                  '${post.empathyCount} ',
                                                  style: const TextStyle(
                                                    color: kDarkPink,
                                                  ),
                                                )
                                              : const SizedBox(),
                                          const Text(
                                            'ワカル',
                                            style: TextStyle(
                                              color: kDarkPink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                              : const SizedBox(),
                        ],
                      ),

                      /// 返信
                      Column(
                        children: [
                          /// 返信一覧
                          Column(
                            children: post.replies.isNotEmpty
                                // children: post.isReplyShown && replies != null
                                ? post.replies.map((reply) {
                                    return ReplyCard(
                                      reply: reply,
                                      post: post,
                                      passedModel: passedModel,
                                    );
                                  }).toList()
                                : [],
                          ),

                          /// 返信数
                          // replies != null
                          //     ? replies!.isNotEmpty
                          //         ? post.isReplyShown
                          //             ? TextButton(
                          //                 onPressed: () async {
                          //                   model.closeReplies(post);
                          //                 },
                          //                 child: Text(
                          //                   '返信を閉じる',
                          //                   style: TextStyle(
                          //                     color: Colors.blueAccent,
                          //                   ),
                          //                 ),
                          //               )
                          //             : TextButton(
                          //                 onPressed: () async {
                          //                   model.openReplies(post);
                          //                 },
                          //                 child: Text(
                          //                   '${post.replyCount}件の返信',
                          //                   style: TextStyle(
                          //                     color: Colors.blueAccent,
                          //                   ),
                          //                 ),
                          //               )
                          //         : const SizedBox()
                          //     : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// EditIconButton
            post.isMe() == true && passedModel is! DraftsModel
                ? Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: 30,
                    end: 10,
                    // child: PopupMenuOnPostCard(
                    //   post: post,
                    //   indexOfPost: indexOfPost,
                    //   passedModel: passedModel,
                    //   tabName: tabName,
                    // ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: kGrey,
                      ),
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return UpdatePostPage(
                              existingPost: post,
                              passedModel: passedModel,
                            );
                          }),
                        );
                        tabType != null
                            ? passedModel.refreshThePostOfPostsAfterUpdated(
                                tabType: tabType,
                                oldPost: post,
                                indexOfPost: indexOfPost,
                              )
                            : passedModel != PostDetailModel
                                ? passedModel.refreshThePostOfPostsAfterUpdated(
                                    oldPost: post,
                                    indexOfPost: indexOfPost,
                                  )
                                : passedModel.getPost();
                      },
                    ),
                  )
                : const SizedBox(),

            /// EditIconButton
            post.isMe() == true &&
                    passedModel is DraftsModel &&
                    post.isDraft == true
                ? Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: 30,
                    end: 10,
                    // child: PopupMenuOnPostCard(
                    //   post: post,
                    //   indexOfPost: indexOfPost,
                    //   passedModel: passedModel,
                    //   tabName: tabName,
                    // ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: kGrey,
                      ),
                      onPressed: () async {
                        final resultForDraftButton =
                            await Navigator.push<ResultForDraftButton>(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return UpdatePostPage(
                              existingPost: post,
                              passedModel: passedModel,
                            );
                          }),
                        );
                        if (resultForDraftButton ==
                            ResultForDraftButton.updateDraft) {
                          await passedModel.getDrafts();
                          print('aaaa');
                        } else if (resultForDraftButton ==
                            ResultForDraftButton.addPostFromDraft) {
                          await passedModel.removeDraft(post: post);
                        }
                      },
                    ),
                  )
                : const SizedBox(),

            /// EmotionImageButton
            Positioned(
              // top: 20,
              width: 70,
              height: 70,
              child: GestureDetector(
                child: kEmotionIcons[post.emotion] != null ||
                        kEmotionIcons[post.emotion] != ''
                    ? Image.asset(kEmotionIcons[post.emotion]!)
                    : const FlutterLogo(),
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchResultPostsPage(post.emotion!),
                    ),
                  );
                },
              ),
            ),

            /// ブックマークを切り替えるスターアイコン
            passedModel is! DraftsModel
                ? Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: 64,
                    end: 10,
                    child: post.isBookmarked
                        ? IconButton(
                            icon: const Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                            onPressed: () async {
                              model.turnOffStar(post);
                              await model.deleteBookmarkedPost(post);
                            },
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.star_border_outlined,
                              color: kGrey,
                            ),
                            onPressed: () async {
                              model.turnOnStar(post);
                              await model.addBookmarkedPost(post);
                              if (tabType != null) {
                                await passedModel.getPostsWithReplies(
                                    TabType.bookmarkedPostsTab);
                              }
                            },
                          ),
                  )
                : const SizedBox(),
          ],
        ),
      );
    });
  }
}

// class PopupMenuOnPostCard extends StatelessWidget {
//   PopupMenuOnPostCard({
//     required this.post,
//     required this.indexOfPost,
//     required this.passedModel,
//     this.tabName,
//   });
//
//   final Post post;
//   final int indexOfPost;
//   final passedModel;
//   final String? tabName;
//
//   @override
//   Widget build(BuildContext context) {
//     // Future<void> _showCardDeleteConfirmDialog() async {
//     //   return showDialog<void>(
//     //     context: context,
//     //     barrierDismissible: false, // user must tap button!
//     //     builder: (BuildContext context) {
//     //       return Consumer<PostCardModel>(builder: (context, model, child) {
//     //         return LoadingSpinner(
//     //           inAsyncCall: model.isLoading,
//     //           child: AlertDialog(
//     //             shape: RoundedRectangleBorder(
//     //               borderRadius: BorderRadius.circular(16),
//     //             ),
//     //             title: const Text('投稿の削除'),
//     //             content: Text('本当に削除しますか？'),
//     //             contentPadding:
//     //                 EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
//     //                   await model.deletePostAndReplies(post);
//     //                   tabName != null
//     //                       ? passedModel.removeThePostOfPostsAfterDeleted(
//     //                           tabName: tabName,
//     //                           post: post,
//     //                         )
//     //                       : passedModel.removeThePostOfPostsAfterDeleted(post);
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
//     return Consumer<PostCardModel>(builder: (context, model, child) {
//       return PopupMenuButton<PopupMenuItemsOnCard>(
//         icon: Icon(
//           Icons.more_horiz,
//           color: kLightGrey,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         elevation: 1,
//         onSelected: (result) async {
//           if (result == PopupMenuItemsOnCard.update) {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) {
//                 return UpdatePostPage(post);
//               }),
//             );
//             tabName != null
//                 ? passedModel.refreshThePostOfPostsAfterUpdated(
//                     tabName: tabName,
//                     oldPost: post,
//                     indexOfPost: indexOfPost,
//                   )
//                 : passedModel.refreshThePostOfPostsAfterUpdated(
//                     oldPost: post,
//                     indexOfPost: indexOfPost,
//                   );
//           }
//           // else if (result == PopupMenuItemsOnCard.delete) {
//           //   await _showCardDeleteConfirmDialog();
//           // }
//         },
//         itemBuilder: (BuildContext context) => [
//           PopupMenuItem<PopupMenuItemsOnCard>(
//             value: PopupMenuItemsOnCard.update,
//             child: Container(
//               width: 100,
//               child: Row(
//                 children: [
//                   Icon(Icons.update, color: kLightGrey),
//                   SizedBox(width: 8),
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
//           //     width: 100,
//           //     child: Row(
//           //       children: [
//           //         Icon(Icons.delete, color: kLightGrey),
//           //         SizedBox(width: 8),
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
