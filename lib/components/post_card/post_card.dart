import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/components/reply_card/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply/add_reply_page.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_page.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget with FormatPosterDataMixin {
  PostCard({
    required this.post,
    required this.passedModel,
    this.tabName,
  });

  final Post post;
  final passedModel;
  final String? tabName;

  @override
  Widget build(BuildContext context) {
    post.replies = tabName != null
        ? passedModel.getReplies(tabName)[post.id]
        : passedModel.replies[post.id];
    final bool isMe = FirebaseAuth.instance.currentUser != null
        ? FirebaseAuth.instance.currentUser!.uid == post.uid
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
                                            SearchResultPostsPage(category)),
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
                          OutlinedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddReplyPage(
                                    repliedPost: post,
                                    userProfile: context
                                        .read<HomePostsModel>()
                                        .userProfile,
                                  ),
                                ),
                              );
                              model.getRepliesToPost(post);
                              // if (tabName != null) {
                              //   await context
                              //       .read<HomePostsModel>()
                              //       .getPostsWithReplies(kAllPostsTab);
                              //   await context
                              //       .read<HomePostsModel>()
                              //       .getPostsWithReplies(kMyPostsTab);
                              //   await context
                              //       .read<HomePostsModel>()
                              //       .getPostsWithReplies(kBookmarkedPostsTab);
                              // }
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
                            children: post.replies != null
                                // children: post.isReplyShown && replies != null
                                ? post.replies!.map((reply) {
                                    return ReplyCard(
                                      reply: reply,
                                      passedModel: passedModel,
                                      tabName: tabName,
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
                    child: PopupMenuOnCard(post: post),
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
                        await context
                            .read<HomePostsModel>()
                            .getPostsWithReplies(kAllPostsTab);
                        await context
                            .read<HomePostsModel>()
                            .getPostsWithReplies(kMyPostsTab);
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.star_border_outlined,
                      ),
                      onPressed: () async {
                        model.turnOnStar(post);
                        // Todo 後で修正する
                        await model.addBookmarkedPost(post);
                        await context
                            .read<HomePostsModel>()
                            .getPostsWithReplies(kBookmarkedPostsTab);
                        await context
                            .read<HomePostsModel>()
                            .getPostsWithReplies(kAllPostsTab);
                        await context
                            .read<HomePostsModel>()
                            .getPostsWithReplies(kMyPostsTab);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}
