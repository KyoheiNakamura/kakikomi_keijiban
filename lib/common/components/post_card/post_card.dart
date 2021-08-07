import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_posts/common_posts_page.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/common/components/reply_card/reply_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/common/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/manager/firestore_manager.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_page.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_page.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget with FormatPosterDataMixin {
  const PostCard({
    required this.post,
    required this.indexOfPost,
    required this.passedModel,
    Key? key,
  }) : super(key: key);

  final Post post;
  final int indexOfPost;
  final dynamic passedModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostCardModel>(
      create: (context) => PostCardModel(),
      child: Consumer<PostCardModel>(
        builder: (context, model, child) {
          return Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

                /// カード
                child: GestureDetector(
                  onTap: () {
                    // カードをタップで投稿詳細画面へ遷移する
                    if (post.userId != null || post.id != null) {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(
                            posterId: post.userId!,
                            postId: post.id!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Column(
                        children: [
                          /// カテゴリーのタグリスト
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              children: post.categories != null
                                  ? post.categories!.map<Widget>(
                                      (category) {
                                        return CategoryChip(
                                          category: category,
                                        );
                                      },
                                    ).toList()
                                  : [],
                            ),
                          ),
                          const SizedBox(height: 8),

                          /// 気持ちアイコン・ニックネーム・投稿日時
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              /// 気持ちボタン
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CommonPostsPage(
                                          title: post.emotion,
                                          type:
                                              CommonPostsType.searchResultPosts,
                                          searchWord: post.emotion,
                                        ),
                                      ),
                                    );
                                  },
                                  child: post.emotion != null &&
                                          kEmotionIcons[post.emotion] != null
                                      ? Image.asset(
                                          kEmotionIcons[post.emotion]!)
                                      : const FlutterLogo(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const SizedBox(height: 8),
                                  Text(
                                    post.nickname ?? '',
                                    style: const TextStyle(
                                      color: kGrey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    post.createdDate,
                                    style: const TextStyle(
                                      color: kUltraLightGrey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          /// 本文
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: post.body,
                                    style: const TextStyle(
                                      color: kDarkGrey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  post.createdDate != post.updatedDate
                                      ? const TextSpan(
                                          text: '（編集済み）',
                                          style: TextStyle(
                                            color: kGrey,
                                            fontSize: 14,
                                          ),
                                        )
                                      : const TextSpan(),
                                ],
                                style: kBodyTextStyle,
                              ),
                            ),
                          ),

                          /// 返信数とワカルボタン
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              /// 返信数
                              passedModel is! DraftsModel
                                  ? Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Icon(
                                            Icons.message_outlined,
                                            color: kGrey,
                                          ),
                                        ),
                                        Text(
                                          '${post.replyCount}',
                                          style: const TextStyle(
                                            color: kGrey,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),

                              /// ワカルボタン
                              passedModel is! DraftsModel
                                  ? Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            post.isEmpathized
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border_outlined,
                                            color: post.isEmpathized
                                                ? Colors.pinkAccent
                                                : kGrey,
                                          ),
                                          onPressed: () async {
                                            if (post.isEmpathized) {
                                              // 下二行はワカル１回のみできるとき用
                                              model.turnOffEmpathyButton(post);
                                              await model
                                                  .deleteEmpathizedPost(post);
                                            } else {
                                              model.turnOnEmpathyButton(post);
                                              await model
                                                  .addEmpathizedPost(post);
                                            }
                                          },
                                        ),
                                        Text(
                                          '${post.empathyCount}',
                                          style: const TextStyle(
                                            color: kGrey,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
                          ),

                          /// 返信一覧
                          // Column(
                          //   children: post.replies.isNotEmpty
                          //       ? post.replies.map((reply) {
                          //           return ReplyCard(
                          //             reply: reply,
                          //             post: post,
                          //             passedModel: passedModel,
                          //           );
                          //         }).toList()
                          //       : [],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// メニューボタン
              Positioned(
                top: 4,
                right: 24,
                child: CardMenuButton(
                  post: post,
                  model: model,
                  passedModel: passedModel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<PostCardModel>(
  //     builder: (context, model, child) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 8),
  //         child: Stack(
  //           alignment: AlignmentDirectional.topCenter,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(0, 40, 0, 8),
  //               child: Card(
  //                 color: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                     vertical: 32,
  //                     horizontal: 20,
  //                   ),
  //                   child: Column(
  //                     children: [
  //                       /// カテゴリーのActionChipを表示してる
  //                       Padding(
  //                         padding: const EdgeInsets.only(right: 24),
  //                         child: Align(
  //                           alignment: Alignment.centerLeft,
  //                           child: Wrap(
  //                             spacing: 4,
  //                             children: post.categories != null
  //                                 ? post.categories!.map<Widget>(
  //                                     (category) {
  //                                       return CategoryChip(
  //                                         category: category,
  //                                         onPressed: () async {
  //                                           await Navigator.push<void>(
  //                                             context,
  //                                             MaterialPageRoute(
  //                                               builder: (context) =>
  //                                                   SearchResultPostsPage(
  //                                                       searchWord: category),
  //                                             ),
  //                                           );
  //                                         },
  //                                       );
  //                                     },
  //                                   ).toList()
  //                                 : [],
  //                           ),
  //                         ),
  //                       ),

  //                       /// title
  //                       Padding(
  //                         padding:
  //                             const EdgeInsets.only(top: 8, left: 8, right: 8),
  //                         child: Text(
  //                           post.title != null ? post.title! : '',
  //                           style: const TextStyle(fontSize: 17),
  //                         ),
  //                       ),

  //                       /// posterData
  //                       Text(
  //                         getFormattedPosterData(post),
  //                         style: const TextStyle(color: kGrey),
  //                       ),

  //                       /// body
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 15),
  //                         child: RichText(
  //                           text: TextSpan(
  //                             children: [
  //                               TextSpan(text: post.body),
  //                               post.createdDate != post.updatedDate
  //                                   ? const TextSpan(
  //                                       text: '（編集済み）',
  //                                       style: TextStyle(
  //                                         color: kGrey,
  //                                         fontSize: 15,
  //                                       ),
  //                                     )
  //                                   : const TextSpan(),
  //                             ],
  //                             style: kBodyTextStyle,
  //                           ),
  //                         ),
  //                       ),

  //                       /// 作成日時
  //                       Align(
  //                         alignment: Alignment.centerRight,
  //                         child: Text(
  //                           post.createdDate,
  //                           style: const TextStyle(color: kGrey),
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: EdgeInsets.symmetric(
  //                           horizontal: MediaQuery.of(context).size.width * .1,
  //                         ),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                           children: [
  //                             /// 返信ボタン
  //                             // passedModel is! DraftsModel
  //                             //     ? OutlinedButton(
  //                             //         onPressed: () async {
  //                             //           await Navigator.push<void>(
  //                             //             context,
  //                             //             MaterialPageRoute(
  //                             //               builder: (context) =>
  //                             //                   AddReplyPage(post),
  //                             //             ),
  //                             //           );
  //                             //           await model.getAllRepliesToPost(post);
  //                             //         },
  //                             //         child: const Text(
  //                             //           '返信する',
  //                             //           style: TextStyle(
  //                             //             color: kDarkPink,
  //                             //             fontSize: 15,
  //                             //           ),
  //                             //         ),
  //                             //         style: OutlinedButton.styleFrom(
  //                             //           shape: RoundedRectangleBorder(
  //                             //             borderRadius: BorderRadius.circular(16),
  //                             //           ),
  //                             //           side: const BorderSide(color: kPink),
  //                             //           primary: kDarkPink,
  //                             //         ),
  //                             //       )
  //                             //     : const SizedBox(),

  //                             /// 返信数
  //                             passedModel is! DraftsModel
  //                                 ? Row(
  //                                     children: [
  //                                       const Padding(
  //                                         padding: EdgeInsets.all(12),
  //                                         child: Icon(
  //                                           Icons.message_outlined,
  //                                           color: kGrey,
  //                                         ),
  //                                       ),
  //                                       Text(
  //                                         '${post.replyCount}',
  //                                         style: const TextStyle(
  //                                           color: kGrey,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   )
  //                                 : const SizedBox(),

  //                             /// ワカルボタン
  //                             passedModel is! DraftsModel
  //                                 ? Row(
  //                                     children: [
  //                                       IconButton(
  //                                         icon: Icon(
  //                                           post.isEmpathized
  //                                               ? Icons.favorite
  //                                               : Icons
  //                                                   .favorite_border_outlined,
  //                                           color: post.isEmpathized
  //                                               ? Colors.pinkAccent
  //                                               : kGrey,
  //                                         ),
  //                                         onPressed: () async {
  //                                           if (post.isEmpathized) {
  //                                             // 下二行はワカル１回のみできるとき用
  //                                             model.turnOffEmpathyButton(post);
  //                                             await model
  //                                                 .deleteEmpathizedPost(post);
  //                                           } else {
  //                                             model.turnOnEmpathyButton(post);
  //                                             await model
  //                                                 .addEmpathizedPost(post);
  //                                           }
  //                                         },
  //                                       ),
  //                                       Text(
  //                                         '${post.empathyCount}',
  //                                         style: const TextStyle(
  //                                           color: kGrey,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   )
  //                                 : const SizedBox(),
  //                           ],
  //                         ),
  //                       ),

  //                       /// 返信
  //                       Column(
  //                         children: [
  //                           /// 返信一覧
  //                           Column(
  //                             children: post.replies.isNotEmpty
  //                                 // children: post.isReplyShown && replies != null
  //                                 ? post.replies.map((reply) {
  //                                     return ReplyCard(
  //                                       reply: reply,
  //                                       post: post,
  //                                       passedModel: passedModel,
  //                                     );
  //                                   }).toList()
  //                                 : [],
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),

  //             /// メニューボタン
  //             Positioned(
  //               top: 48,
  //               right: 8,
  //               child: CardMenuButton(
  //                 post: post,
  //                 model: model,
  //                 passedModel: passedModel,
  //               ),
  //             ),

  //             /// 気持ちボタン
  //             Positioned(
  //               width: 80,
  //               height: 80,
  //               child: GestureDetector(
  //                 onTap: () async {
  //                   await Navigator.push<void>(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => CommonPostsPage(
  //                         title: post.emotion,
  //                         type: CommonPostsType.searchResultPosts,
  //                         searchWord: post.emotion,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 child: kEmotionIcons[post.emotion] != null ||
  //                         kEmotionIcons[post.emotion] != ''
  //                     ? Image.asset(kEmotionIcons[post.emotion]!)
  //                     : const FlutterLogo(),
  //               ),
  //             ),

  //             // /// EditIconButton
  //             // post.isMe() == true && passedModel is! DraftsModel
  //             //     ? Positioned.directional(
  //             //         textDirection: TextDirection.ltr,
  //             //         top: 30,
  //             //         end: 10,
  //             //         // child: PopupMenuOnPostCard(
  //             //         //   post: post,
  //             //         //   indexOfPost: indexOfPost,
  //             //         //   passedModel: passedModel,
  //             //         //   tabName: tabName,
  //             //         // ),
  //             //         child: IconButton(
  //             //           icon: const Icon(
  //             //             Icons.edit,
  //             //             color: kGrey,
  //             //           ),
  //             //           onPressed: () async {
  //             //             await Navigator.push<void>(
  //             //               context,
  //             //               MaterialPageRoute(builder: (context) {
  //             //                 return UpdatePostPage(
  //             //                   existingPost: post,
  //             //                   passedModel: passedModel,
  //             //                 );
  //             //               }),
  //             //             );
  //             //             passedModel != PostDetailModel
  //             //                     ? passedModel
  //             //                         .refreshThePostOfPostsAfterUpdated(
  //             //                         oldPost: post,
  //             //                         indexOfPost: indexOfPost,
  //             //                       )
  //             //                     : passedModel.getPost();
  //             //           },
  //             //         ),
  //             //       )
  //             //     : const SizedBox(),

  //             // /// EditIconButton
  //             // post.isMe() == true &&
  //             //         passedModel is DraftsModel &&
  //             //         post.isDraft == true
  //             //     ? Positioned.directional(
  //             //         textDirection: TextDirection.ltr,
  //             //         top: 30,
  //             //         end: 10,
  //             //         // child: PopupMenuOnPostCard(
  //             //         //   post: post,
  //             //         //   indexOfPost: indexOfPost,
  //             //         //   passedModel: passedModel,
  //             //         //   tabName: tabName,
  //             //         // ),
  //             //         child: IconButton(
  //             //           icon: const Icon(
  //             //             Icons.edit,
  //             //             color: kGrey,
  //             //           ),
  //             //           onPressed: () async {
  //             //             final resultForDraftButton =
  //             //                 await Navigator.push<ResultForDraftButton>(
  //             //               context,
  //             //               MaterialPageRoute(builder: (context) {
  //             //                 return UpdatePostPage(
  //             //                   existingPost: post,
  //             //                   passedModel: passedModel,
  //             //                 );
  //             //               }),
  //             //             );
  //             //             if (resultForDraftButton ==
  //             //                 ResultForDraftButton.updateDraft) {
  //             //               await passedModel.getDrafts();
  //             //             } else if (resultForDraftButton ==
  //             //                 ResultForDraftButton.addPostFromDraft) {
  //             //               await passedModel.removeDraft(post: post);
  //             //             }
  //             //           },
  //             //         ),
  //             //       )
  //             //     : const SizedBox(),

  //             // /// ブックマークを切り替えるスターアイコン
  //             // passedModel is! DraftsModel
  //             //     ? Positioned.directional(
  //             //         textDirection: TextDirection.ltr,
  //             //         top: 64,
  //             //         end: 10,
  //             //         child: post.isBookmarked
  //             //             ? IconButton(
  //             //                 icon: const Icon(
  //             //                   Icons.star,
  //             //                   color: Colors.yellow,
  //             //                 ),
  //             //                 onPressed: () async {
  //             //                   model.turnOffStar(post);
  //             //                   await model.deleteBookmarkedPost(post);
  //             //                 },
  //             //               )
  //             //             : IconButton(
  //             //                 icon: const Icon(
  //             //                   Icons.star_border_outlined,
  //             //                   color: kGrey,
  //             //                 ),
  //             //                 onPressed: () async {
  //             //                   model.turnOnStar(post);
  //             //                   await model.addBookmarkedPost(post);
  //             //                 },
  //             //               ),
  //             //       )
  //             //     : const SizedBox(),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    Key? key,
  }) : super(key: key);

  final String category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CommonPostsPage(
                title: category,
                type: CommonPostsType.searchResultPosts,
                searchWord: category,
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 12,
        ),
        decoration: const BoxDecoration(
          // color: kLightPink2,
          color: kUltraLightPink,
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        child: Text(
          category,
          style: const TextStyle(
            color: kDarkPink,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class CardMenuButton extends StatelessWidget {
  const CardMenuButton({
    required this.post,
    required this.model,
    required this.passedModel,
    Key? key,
  }) : super(key: key);

  final Post post;
  final PostCardModel model;
  final dynamic passedModel;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.more_horiz,
        color: kLightGrey,
      ),
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          // barrierColor: Colors.black.withOpacity(0.8),
          pageBuilder: (_, __, ___) {
            return SafeArea(
              child: Material(
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// メニューの中身
                    CardMenuItemButtonList(
                      post: post,
                      model: model,
                      passedModel: passedModel,
                    ),
                    const SizedBox(height: 8),

                    /// キャンセルボタン
                    const CardMenuCancelButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// メニューで行えること一覧
class CardMenuItemButtonList extends StatelessWidget {
  const CardMenuItemButtonList({
    required this.post,
    required this.model,
    required this.passedModel,
    Key? key,
  }) : super(key: key);

  final Post post;
  final PostCardModel model;
  final dynamic passedModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CardMenuItemButton(
            iconData: Icons.report_outlined,
            iconName: '通報',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          if (post.isMe() == true)
            CardMenuItemButton(
              iconData: Icons.edit_outlined,
              iconName: '編集',
              onPressed: () async {
                Navigator.pop(context);
                // final resultForDraftButton =
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return UpdatePostPage(
                      existingPost: post,
                      passedModel: passedModel,
                    );
                  }),
                );
                // if (resultForDraftButton == ResultForDraftButton.updateDraft) {
                //   await passedModel.getDrafts();
                // } else if (resultForDraftButton ==
                //     ResultForDraftButton.addPostFromDraft) {
                //   await passedModel.removeDraft(post: post);
                // }
              },
            ),
          CardMenuItemButton(
            iconData: post.isBookmarked ? Icons.star : Icons.star_outline,
            iconColor: post.isBookmarked ? Colors.yellow : null,
            iconName: 'ブックマーク',
            onPressed: () async {
              if (post.isBookmarked) {
                model.turnOffStar(post);
                await model.deleteBookmarkedPost(post);
              } else {
                model.turnOnStar(post);
                await model.addBookmarkedPost(post);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// メニューの各ボタン
class CardMenuItemButton extends StatelessWidget {
  const CardMenuItemButton({
    required this.iconData,
    required this.iconName,
    required this.onPressed,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  final IconData iconData;
  final String iconName;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kUltraLightGrey,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            IconButton(
              icon: Icon(
                iconData,
                size: 32,
                color: iconColor ?? kDarkGrey,
              ),
              onPressed: onPressed,
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          iconName,
          style: const TextStyle(
            color: kGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// メニューを閉じるボタン
class CardMenuCancelButton extends StatelessWidget {
  const CardMenuCancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * .9,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'キャンセル',
            style: TextStyle(
              color: kDarkGrey,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
