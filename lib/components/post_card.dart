import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/reply_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/home/home_model.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:kakikomi_keijiban/reply.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  PostCard({this.post, this.index});

  final Post post;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Color(0xFFFDF3E1),
              padding: EdgeInsets.only(
                  top: 40.0, left: 20.0, right: 20.0, bottom: 30.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      post.title,
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                  Text(
                    '名前/性別/年齢/地域/立場',
                    style: TextStyle(color: kLightGrey),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      post.bodyText,
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
                          style: TextStyle(color: kDarkPink),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: kLightPink),
                        ),
                      ),
                      Text(
                        post.createdAt,
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
        Positioned(
          width: 40.0,
          height: 40.0,
          child: Image.asset('images/anpanman.png'),
        ),
      ],
    );
  }
}
