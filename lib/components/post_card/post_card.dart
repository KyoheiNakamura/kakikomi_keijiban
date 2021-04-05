import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/post_card/post_card_model.dart';
import 'package:kakikomi_keijiban/components/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home_posts/home_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/search_result_posts/search_result_posts_page.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget with FormatPosterDataMixin {
  PostCard({required this.post, required this.replies, this.isMyPostsPage});

  final Post post;
  final List<Reply>? replies;
  final bool? isMyPostsPage;

  @override
  Widget build(BuildContext context) {
    return Consumer<PostCardModel>(builder: (context, model, child) {
      bool isMe = false;
      if (FirebaseAuth.instance.currentUser != null) {
        isMe = FirebaseAuth.instance.currentUser!.uid == post.uid;
      }

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
                      top: 24.0, left: 20.0, right: 20.0, bottom: 32.0),
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
                                backgroundColor: kLightPink,
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
                        child: Text(
                          post.body,
                          // maxLines: 3,
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
                                  builder: (context) => AddReplyToPostPage(
                                      userProfile: Provider.of<HomePostsModel>(
                                              context,
                                              listen: false)
                                          .userProfile,
                                      repliedPost: post),
                                ),
                              );
                              await Provider.of<HomePostsModel>(context,
                                      listen: false)
                                  .getPostsWithReplies;
                              await Provider.of<MyPostsModel>(context,
                                      listen: false)
                                  .getPostsWithReplies;
                              await Provider.of<BookmarkedPostsModel>(context,
                                      listen: false)
                                  .getPostsWithReplies;
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

                      /// 返信一覧
                      Column(
                        children: replies != null
                            ? replies!.map((reply) {
                                // return ReplyCard(reply);
                                return ReplyCard(
                                  reply: reply,
                                  isMe: isMe,
                                  isMyPostsPage: isMyPostsPage,
                                );
                              }).toList()
                            : [],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            isMe && isMyPostsPage == true
                ? Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: 30.0,
                    end: 10.0,
                    child: PopupMenuOnCard(post: post),
                  )
                : Container(),
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
                        post.isBookmarked = false;
                        await model.deleteBookmarkedPost(post);
                        await Provider.of<BookmarkedPostsModel>(context,
                                listen: false)
                            .getPostsWithReplies;
                        await Provider.of<HomePostsModel>(context,
                                listen: false)
                            .getPostsWithReplies;
                        await Provider.of<MyPostsModel>(context, listen: false)
                            .getPostsWithReplies;
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.star_border_outlined,
                      ),
                      onPressed: () async {
                        post.isBookmarked = true;
                        await model.addBookmarkedPost(post);
                        await Provider.of<BookmarkedPostsModel>(context,
                                listen: false)
                            .getPostsWithReplies;
                        await Provider.of<HomePostsModel>(context,
                                listen: false)
                            .getPostsWithReplies;
                        await Provider.of<MyPostsModel>(context, listen: false)
                            .getPostsWithReplies;
                      },
                    ),
            ),
            // Positioned.directional(
            //   textDirection: TextDirection.ltr,
            //   top: 26.0,
            //   start: 0,
            //   child: Wrap(
            //     spacing: 2.0,
            //     runSpacing: 2.0,
            //     // alignment: WrapAlignment.center,
            //     children: post.categories.map<Widget>((category) {
            //       return ActionChip(
            //         label: Text(
            //           category,
            //           style: TextStyle(color: kDarkPink),
            //         ),
            //         backgroundColor: kLightPink,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(20),
            //           side: BorderSide(color: kPink),
            //         ),
            //         onPressed: () {
            //           print('そのチップ($category)の検索結果ページに飛ぶ予定やで。');
            //         },
            //       );
            //     }).toList(),
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}
