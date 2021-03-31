import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_page.dart';
import 'package:kakikomi_keijiban/presentation/bookmarked_posts/bookmarked_posts_model.dart';
import 'package:kakikomi_keijiban/presentation/home/home_model.dart';
import 'package:provider/provider.dart';

class PostCardByCard extends StatelessWidget {
  PostCardByCard(this.post);

  final Post post;

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

  Future<void> _showCardDeleteConfirmDialog(
      BuildContext context, HomeModel model) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('ブックマークの削除'),
          content: Text('本当に削除しますか？'),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(
                '削除',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () async {
                await model.deleteBookmarkedPost(post);
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer<BookmarkedPostsModel>(
    //     builder: (context, bookmarkedPostModel, child) {
    return Consumer<HomeModel>(builder: (context, model, child) {
      final List<Reply>? replies = model.replies[post.id];
      bool isMe = false;
      if (model.loggedInUser != null) {
        isMe = model.loggedInUser!.uid == post.uid;
      }
      return Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Card(
            color: Colors.white,
            margin: EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              padding: EdgeInsets.only(
                  top: 40.0, left: 20.0, right: 20.0, bottom: 24.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 8.0, top: 8.0, right: 8.0, bottom: 0.0),
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
                          await model.getPostsWithReplies();
                        },
                        child: Text(
                          '返信する',
                          style: TextStyle(color: kDarkPink, fontSize: 15.0),
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
                            return ReplyCardByCard(reply);
                          }).toList()
                        : [],
                  ),
                ],
              ),
            ),
          ),
          isMe
              ? Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: 30.0,
                  end: 20.0,
                  child: PopupMenuOnCard(post: post),
                )
              : Container(),
          Positioned(
            width: 50.0,
            height: 50.0,
            child: Image.asset('images/anpanman.png'),
          ),
          Positioned(
            top: 30.0,
            left: 28.0,
            child: post.isBookmarked
                ? IconButton(
                    icon: Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    onPressed: () async {
                      // Todo 削除するときにAlertDialog出そう
                      await model.deleteBookmarkedPost(post);
                      post.isBookmarked = false;
                      await model.getBookmarkedPosts();
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.star_border_outlined,
                    ),
                    onPressed: () async {
                      await model.addBookmarkedPost(post);
                      post.isBookmarked = true;
                      // await model.getBookmarkedPosts();
                    },
                  ),
          ),
        ],
      );
    });
    // });
  }
}

// class PostCard extends StatelessWidget {
//   PostCard(this.post);
//
//   final Post post;
//
//   String _getFormattedPosterData(post) {
//     String posterInfo = '';
//     String formattedPosterInfo = '';
//
//     List<String> posterData = [
//       '${post.nickname}さん',
//       post.gender,
//       post.age,
//       post.area,
//       post.position,
//     ];
//
//     for (var data in posterData) {
//       data.isNotEmpty ? posterInfo += '$data/' : posterInfo += '';
//       int lastSlashIndex = posterInfo.length - 1;
//       formattedPosterInfo = posterInfo.substring(0, lastSlashIndex);
//     }
//     return formattedPosterInfo;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeModel>(builder: (context, model, child) {
//       final List<Reply>? replies = model.replies[post.id];
//       bool isMe = false;
//       if (model.loggedInUser != null) {
//         isMe = model.loggedInUser!.uid == post.uid;
//       }
//       return Stack(
//         alignment: AlignmentDirectional.topCenter,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20.0),
//               child: Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.only(
//                     top: 40.0, left: 20.0, right: 20.0, bottom: 30.0),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(
//                           left: 8.0, top: 8.0, right: 8.0, bottom: 0.0),
//                       child: Text(
//                         post.title,
//                         style: TextStyle(fontSize: 17.0),
//                       ),
//                     ),
//                     Text(
//                       _getFormattedPosterData(post),
//                       style: TextStyle(color: kLightGrey),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(vertical: 15.0),
//                       child: Text(
//                         post.body,
//                         // maxLines: 3,
//                         style: TextStyle(fontSize: 16.0, height: 1.8),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         OutlinedButton(
//                           onPressed: () async {
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ReplyToPostPage(repliedPost: post),
//                               ),
//                             );
//                             await model.getPostsWithReplies();
//                           },
//                           child: Text(
//                             '返信する',
//                             style: TextStyle(color: kDarkPink, fontSize: 15.0),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                             ),
//                             side: BorderSide(color: kPink),
//                           ),
//                         ),
//                         Text(
//                           post.updatedAt,
//                           style: TextStyle(color: kLightGrey),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: replies != null
//                           ? replies.map((reply) {
//                               return ReplyCardByCard(reply);
//                             }).toList()
//                           : [],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           isMe
//               ? Positioned.directional(
//                   textDirection: TextDirection.ltr,
//                   top: 30.0,
//                   end: 20.0,
//                   child: PopupMenuOnCard(post: post),
//                 )
//               : Container(),
//           Positioned(
//             width: 50.0,
//             height: 50.0,
//             child: Image.asset('images/anpanman.png'),
//           ),
//         ],
//       );
//     });
//   }
// }
