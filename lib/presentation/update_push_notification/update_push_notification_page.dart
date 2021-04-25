import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/update_push_notification/update_push_notification_model.dart';
import 'package:provider/provider.dart';

class UpdatePushNotificationPage extends StatelessWidget
    with ShowExceptionDialogMixin {
  final user = AppModel.user!;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdatePushNotificationModel>(
      create: (context) => UpdatePushNotificationModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text(
            '通知設定',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<UpdatePushNotificationModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    // horizontal: 24.0,
                  ),
                  child: ListView(
                    children: [
                      /// newPostTopic
                      ListTile(
                        title: Text(
                          '新着の投稿のお知らせ',
                          style: TextStyle(
                            // fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        leading: Icon(
                          Icons.post_add,
                          color: kLightGrey,
                        ),
                        trailing: Switch(
                          value: model.isNewPostTopicAllowed,
                          onChanged: model.toggleSubscriptionForNewPostTopic,
                          activeTrackColor: kPink,
                          activeColor: Colors.pinkAccent,
                        ),
                      ),

                      /// ReplyToMyPost
                      ListTile(
                        title: Text(
                          '返信のお知らせ',
                          style: TextStyle(
                            // fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        leading: Transform(
                          alignment: Alignment.topCenter,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(
                            Icons.reply,
                            color: kLightGrey,
                          ),
                        ),
                        trailing: Switch(
                          value: model.isReplyToMyPostAllowed,
                          onChanged: model.togglePermissionForReplyToMyPost,
                          activeTrackColor: kPink,
                          activeColor: Colors.pinkAccent,
                        ),
                      ),

                      /// ReplyToMyReply
                      ListTile(
                        title: Text(
                          '返信への返信のお知らせ',
                          style: TextStyle(
                            // fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        leading: Transform(
                          alignment: Alignment.topCenter,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(
                            Icons.reply_all,
                            color: kLightGrey,
                          ),
                        ),
                        trailing: Switch(
                          value: model.isReplyToMyReplyAllowed,
                          onChanged: model.togglePermissionForReplyToMyReply,
                          activeTrackColor: kPink,
                          activeColor: Colors.pinkAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
