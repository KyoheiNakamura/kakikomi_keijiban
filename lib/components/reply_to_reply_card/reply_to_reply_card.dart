import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_reply_to_reply_card.dart';
import 'package:kakikomi_keijiban/components/reply_to_reply_card/reply_to_reply_card_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';
import 'package:provider/provider.dart';

class ReplyToReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyToReplyCard({
    required this.replyToReply,
    required this.reply,
  });

  final ReplyToReply replyToReply;
  final Reply reply;

  @override
  Widget build(BuildContext context) {
    final bool isMe = context.read<AppModel>().loggedInUser != null
        ? context.read<AppModel>().loggedInUser!.uid == replyToReply.uid
        : false;
    return Consumer<ReplyToReplyCardModel>(builder: (context, model, child) {
      return Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          SizedBox(height: 20.0),
          Card(
            elevation: 0,
            color: Colors.white,
            // margin: EdgeInsets.only(bottom: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              // side: BorderSide(
              //   color: kLightPink,
              //   width: 2.0,
              // ),
            ),
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Transform(
                        alignment: Alignment.topCenter,
                        transform: Matrix4.rotationY(math.pi),
                        child: Icon(
                          Icons.reply,
                          color: kLightGrey,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          getFormattedPosterData(replyToReply),
                          style: TextStyle(color: kLightGrey),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      replyToReply.body,
                      style: TextStyle(fontSize: 16.0, height: 1.8),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      replyToReply.createdAt,
                      style: TextStyle(color: kLightGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isMe == true
              ? Positioned.directional(
                  textDirection: TextDirection.ltr,
                  top: -6.0,
                  end: -4.0,
                  child: PopupMenuOnReplyToReplyCard(
                    replyToReply: replyToReply,
                    reply: reply,
                  ),
                )
              : Container(),
        ],
      );
    });
  }
}
