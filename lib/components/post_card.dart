import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home/home_model.dart';
import 'package:kakikomi_keijiban/presentation/my_posts/my_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/search_result/search_result_model.dart';
import 'package:kakikomi_keijiban/presentation/search_result/search_result_page.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  PostCard({required this.post, required this.pageName});

  final Post post;
  final String pageName;

  String _getFormattedPosterData(post) {
    String posterInfo = '';
    String formattedPosterInfo = '';

    List<String> posterData = [
      '${post.nickname}さん',
      post.gender,
      post.age,
      post.area,
      post.position,
    ];

    for (var data in posterData) {
      data.isNotEmpty ? posterInfo += '$data/' : posterInfo += '';
      int lastSlashIndex = posterInfo.length - 1;
      formattedPosterInfo = posterInfo.substring(0, lastSlashIndex);
    }
    return formattedPosterInfo;
  }

  // Future<void> _showCardDeleteConfirmDialog(
  //     BuildContext context, HomeModel model) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15.0),
  //         ),
  //         title: Text('ブックマークの削除'),
  //         content: Text('本当に削除しますか？'),
  //         contentPadding:
  //             EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(
  //               'キャンセル',
  //               style: TextStyle(color: kDarkPink),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop(true);
  //             },
  //           ),
  //           TextButton(
  //             child: Text(
  //               '削除',
  //               style: TextStyle(color: kDarkPink),
  //             ),
  //             onPressed: () async {
  //               await model.deleteBookmarkedPost(post);
  //               Navigator.of(context).pop(false);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer4<HomeModel, BookmarkedPostsModel, SearchResultModel,
            MyPostsModel>(
        builder: (context, homeModel, bookmarkedPostsModel, searchResultModel,
            myPostsModel, child) {
      final List<Reply>? replies;
      if (pageName == HomeModel.homePage) {
        replies = homeModel.replies[post.id];
      } else if (pageName == BookmarkedPostsModel.bookmarkedPostsPage) {
        replies = bookmarkedPostsModel.repliesToBookmarkedPosts[post.id];
      } else if (pageName == SearchResultModel.searchPage) {
        replies = searchResultModel.repliesToSearchedPosts[post.id];
      } else if (pageName == MyPostsModel.myPostsPage) {
        replies = myPostsModel.repliesToMyPosts[post.id];
      } else {
        replies = [];
      }

      bool isMe = false;
      if (homeModel.loggedInUser != null) {
        isMe = homeModel.loggedInUser!.uid == post.uid;
      } else if (bookmarkedPostsModel.loggedInUser != null) {
        isMe = bookmarkedPostsModel.loggedInUser!.uid == post.uid;
      } else if (searchResultModel.loggedInUser != null) {
        isMe = searchResultModel.loggedInUser!.uid == post.uid;
      } else if (myPostsModel.loggedInUser != null) {
        isMe = myPostsModel.loggedInUser!.uid == post.uid;
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
                // margin: EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 24.0, left: 20.0, right: 20.0, bottom: 32.0),
                  child: Column(
                    children: [
                      // カテゴリーのActionChipを表示してる
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
                                  style: TextStyle(
                                    color: kDarkPink,
                                  ),
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
                                            SearchResultPage(category)),
                                  );
                                  // await homeModel.getPostsWithReplies();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        child: Text(
                          post.title,
                          style: TextStyle(fontSize: 17.0),
                        ),
                      ),
                      Text(
                        _getFormattedPosterData(post),
                        style: TextStyle(color: kLightGrey),
                      ),
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
                          OutlinedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddReplyToPostPage(repliedPost: post),
                                ),
                              );
                              await homeModel.getPostsWithReplies();
                            },
                            child: Text(
                              '返信する',
                              style:
                                  TextStyle(color: kDarkPink, fontSize: 15.0),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              side: BorderSide(color: kPink),
                            ),
                          ),
                          Text(
                            post.updatedAt,
                            style: TextStyle(color: kLightGrey),
                          ),
                        ],
                      ),
                      Column(
                        children: replies != null
                            ? replies.map((reply) {
                                // return ReplyCard(reply);
                                return ReplyCard(reply);
                              }).toList()
                            : [],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            isMe
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
                        builder: (context) => SearchResultPage(post.emotion)),
                  );
                  await homeModel.getPostsWithReplies();
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
                        // Todo 削除するときにAlertDialog出そう
                        await homeModel.deleteBookmarkedPost(post);
                        post.isBookmarked = false;
                        await bookmarkedPostsModel
                            .getBookmarkedPostsWithReplies();
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.star_border_outlined,
                      ),
                      onPressed: () async {
                        await homeModel.addBookmarkedPost(post);
                        post.isBookmarked = true;
                        // await model.getBookmarkedPosts();
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
            //           print('そのチップ($category)の検索結果ページに飛ぶ予定だよ！');
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
