import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';

class ReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyCard({required this.reply, required this.isMe, this.isMyPostsPage});

  final Reply reply;
  final bool isMe;
  final bool? isMyPostsPage;

  @override
  Widget build(BuildContext context) {
    // return Consumer<HomeModel>(builder: (context, model, child) {
    // bool isMe = false;
    // if (model.loggedInUser != null) {
    //   isMe = model.loggedInUser!.uid == reply.replierId;
    // }
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        SizedBox(height: 20.0),
        Card(
          elevation: 0,
          color: kLightPink,
          margin: EdgeInsets.only(top: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  getFormattedPosterData(reply),
                  style: TextStyle(color: kLightGrey),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    reply.body,
                    style: TextStyle(fontSize: 16.0, height: 1.8),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    reply.createdAt,
                    style: TextStyle(color: kLightGrey),
                  ),
                ),
              ],
            ),
          ),
        ),
        isMe && isMyPostsPage == true
            ? Positioned.directional(
                textDirection: TextDirection.ltr,
                top: 26.0,
                end: -6.0,
                child: PopupMenuOnCard(reply: reply),
              )
            : Container(),
      ],
    );
    // });
  }
}
