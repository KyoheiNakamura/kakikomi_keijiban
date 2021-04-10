import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/mixin/format_poster_data_mixin.dart';

class ReplyToReplyCard extends StatelessWidget with FormatPosterDataMixin {
  ReplyToReplyCard({required this.repliedReply, required this.isMe});

  final Reply repliedReply;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        SizedBox(height: 20.0),
        Card(
          // elevation: 1.0,
          color: Colors.white,
          margin: EdgeInsets.only(bottom: 20.0),
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
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Icon(Icons.reply),
                    ),
                    Flexible(
                      child: Text(
                        getFormattedPosterData(repliedReply),
                        style: TextStyle(color: kLightGrey),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    repliedReply.body,
                    style: TextStyle(fontSize: 16.0, height: 1.8),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    repliedReply.createdAt,
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
                top: 10.0,
                end: -6.0,
                child: PopupMenuOnCard(reply: repliedReply),
              )
            : Container(),
      ],
    );
  }
}
