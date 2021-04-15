import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/common/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply/add_reply_page.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_page.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_page.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget with FormatPosterDataMixin {
  PostCard({
    required this.post,
    required this.indexOfPost,
    required this.passedModel,
    this.tabName,
  });

  final Post post;
  final int indexOfPost;
  final passedModel;
  final String? tabName;

  @override
  Widget build(BuildContext context) {
    final bool isMe = context.read<AppModel>().loggedInUser != null
        ? context.read<AppModel>().loggedInUser!.uid == post.userId
        : false;
    return Consumer<PostCardModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 24.0, left: 20.0, right: 20.0, bottom: 32.0
                      // top: 24.0,
                      // left: 20.0,
                      // right: 20.0,
                      // bottom: replies == null || replies!.isEmpty ? 32.0 : 0,
                      ),
                  child: Column(
                    children: [
                      /// カテゴリーのActionChipを表示してる
                      Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 4.0,
                            // runSpacing: 2.0,
                            // alignment: WrapAlignment.center,
                            children: post.categories.map<Widget>((category) {
                              return ActionChip(
                                label: Text(
                                  category,
                                  style: TextStyle(color: kDarkPink),
                                ),
                                backgroundColor: kUltraLightPink,
                                pressElevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: kPink),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchResultPostsPage(category),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      /// title
                      Padding(
                        padding:
                            EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        child: Text(
                          post.title,
                          style: TextStyle(fontSize: 17.0),
                        ),
                      ),

                      /// posterData
                      Text(
                        getFormattedPosterData(post),
                        style: TextStyle(color: kLightGrey),
                      ),

                      /// body
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        // child: SizedBox(
                        //   width: double.infinity,
                        child: Text(
                          post.body,
                          style: TextStyle(fontSize: 16.0, height: 1.8),
                        ),
                        // ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 返信ボタン
                          passedModel is! DraftsModel
                              ? OutlinedButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddReplyPage(post),
                                      ),
                                    );
                                    await model.getAllRepliesToPost(post);
                                  },
                                  child: Text(
                                    '返信する',
                                    style: TextStyle(
                                        color: kDarkPink, fontSize: 15.0),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    side: BorderSide(color: kPink),
                                  ),
                                )
                              : SizedBox(),

                          /// 更新日時
                          Text(
                            post.updatedAt,
                            style: TextStyle(color: kLightGrey),
                          ),
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
                          //         : SizedBox()
                          //     : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// PopupMenu
            isMe == true
                ? Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: 30.0,
                    end: 10.0,
                    // child: PopupMenuOnPostCard(
                    //   post: post,
                    //   indexOfPost: indexOfPost,
                    //   passedModel: passedModel,
                    //   tabName: tabName,
                    // ),
                    child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: kLightGrey,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return UpdatePostPage(post);
                            }),
                          );
                          tabName != null
                              ? passedModel.refreshThePostOfPostsAfterUpdated(
                                  tabName: tabName,
                                  oldPost: post,
                                  indexOfPost: indexOfPost,
                                )
                              : passedModel.refreshThePostOfPostsAfterUpdated(
                                  oldPost: post,
                                  indexOfPost: indexOfPost,
                                );
                          // Todo refreshThePostOfPostsAfterUpdatedメソッドで返信たちも全部取得するようにする
                        }),
                  )
                : Container(),

            /// EmotionImageButton
            Positioned(
              // top: 20,
              width: 60.0,
              height: 60.0,
              child: GestureDetector(
                child: Image.asset(
                  kEmotionIcons[post.emotion]!,
                  // fit: BoxFit.cover,
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SearchResultPostsPage(post.emotion)),
                  );
                },
              ),
            ),

            /// ブックマークを切り替えるスターアイコン
            Positioned.directional(
              textDirection: TextDirection.ltr,
              top: 55.0,
              end: 10.0,
              child: post.isBookmarked
                  ? IconButton(
                      icon: Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                      onPressed: () async {
                        model.turnOffStar(post);
                        // Todo 後で修正する
                        await model.deleteBookmarkedPost(post);
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.star_border_outlined,
                        color: kLightGrey,
                      ),
                      onPressed: () async {
                        model.turnOnStar(post);
                        // Todo 後で修正する
                        await model.addBookmarkedPost(post);
                        if (tabName != null) {
                          await passedModel
                              .getPostsWithReplies(kBookmarkedPostsTab);
                        }
                      },
                    ),
            ),
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
//     //               borderRadius: BorderRadius.circular(16.0),
//     //             ),
//     //             title: Text('投稿の削除'),
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
//           borderRadius: BorderRadius.circular(15.0),
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
