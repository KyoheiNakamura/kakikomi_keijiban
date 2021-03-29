import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/reply_to_post/reply_to_post_page.dart';
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

  @override
  Widget build(BuildContext context) {
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
                      post.textBody,
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
                                  ReplyToPostPage(repliedPost: post),
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
        ],
      );
    });
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
//                         post.textBody,
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
