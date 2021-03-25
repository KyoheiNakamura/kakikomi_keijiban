import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_post_card.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:kakikomi_keijiban/reply.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  PostCard({required this.post, required this.index});

  final Post post;
  final int index;

  @override
  Widget build(BuildContext context) {
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

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: kLightPink,
              padding: EdgeInsets.only(
                  top: 40.0, left: 20.0, right: 20.0, bottom: 30.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 8.0, right: 8.0, bottom: 0.0),
                    child: Text(
                      post.title,
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                  Text(
                    formattedPosterInfo,
                    style: TextStyle(color: kLightGrey),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      post.textBody,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
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
                        post.updatedAt != null
                            ? post.updatedAt!
                            : post.createdAt,
                        style: TextStyle(color: kLightGrey),
                      ),
                    ],
                  ),
                  Consumer<HomeModel>(builder: (context, model, child) {
                    final List<Reply> replies = model.replies[index];
                    return Column(
                      children: replies.map((reply) {
                        return ReplyCard(reply);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          top: 30.0,
          end: 20.0,
          child: PopupMenuOnPostCard(post),
        ),
        Positioned(
          width: 50.0,
          height: 50.0,
          child: Image.asset('images/anpanman.png'),
        ),
      ],
    );
  }
}
