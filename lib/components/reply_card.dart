import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/popup_menu_on_card.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';

class ReplyCard extends StatelessWidget {
  ReplyCard(this.reply);

  final Reply reply;

  String _getFormattedPosterData(reply) {
    String replierInfo = '';
    String formattedReplierInfo = '';
    List<String> replierData = [
      '${reply.nickname}さん',
      reply.gender,
      reply.age,
      reply.area,
      reply.position,
    ];
    for (var data in replierData) {
      data.isNotEmpty ? replierInfo += '$data/' : replierInfo += '';
      int lastSlashIndex = replierInfo.length - 1;
      formattedReplierInfo = replierInfo.substring(0, lastSlashIndex);
    }
    return formattedReplierInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Container(
          padding: EdgeInsets.only(top: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    _getFormattedPosterData(reply),
                    style: TextStyle(color: kLightGrey),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      reply.textBody,
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
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          top: 27.0,
          end: -5.0,
          child: PopupMenuOnCard(reply: reply),
        ),
      ],
    );
  }
}
