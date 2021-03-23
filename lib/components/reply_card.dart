import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/reply.dart';

class ReplyCard extends StatelessWidget {
  ReplyCard(this.reply);

  final Reply reply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          color: Colors.white,
          padding:
              EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            children: [
              Text(
                '名前/性別/年齢/地域/立場',
                style: TextStyle(color: kLightGrey),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  reply.text,
                  style: TextStyle(fontSize: 16.0),
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
    );
  }
}
