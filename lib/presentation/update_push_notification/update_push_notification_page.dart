import 'package:flutter/cupertino.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdatePushNotificationModel>(
      create: (context) => UpdatePushNotificationModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'プッシュ通知設定',
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 48.0,
                        // horizontal: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// newPostTopic
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: ListTile(
                              title: Text(
                                '投稿がされたとき',
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
                                onChanged:
                                    model.toggleSubscriptionForNewPostTopic,
                                activeTrackColor: kPink,
                                activeColor: Colors.pinkAccent,
                              ),
                            ),
                          ),

                          /// ReplyToMyPost
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: ListTile(
                              title: Text(
                                '返信をされたとき',
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              leading: Icon(
                                Icons.reply,
                                color: kLightGrey,
                              ),
                              trailing: Switch(
                                value: model.isReplyToMyPostAllowed,
                                onChanged:
                                    model.togglePermissionForReplyToMyPost,
                                activeTrackColor: kPink,
                                activeColor: Colors.pinkAccent,
                              ),
                            ),
                          ),

                          /// ReplyToMyReply
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: ListTile(
                              title: Text(
                                '返信に返信をされたとき',
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                ),
                              ),
                              leading: Icon(
                                Icons.reply_all,
                                color: kLightGrey,
                              ),
                              trailing: Switch(
                                value: model.isReplyToMyReplyAllowed,
                                onChanged:
                                    model.togglePermissionForReplyToMyReply,
                                activeTrackColor: kPink,
                                activeColor: Colors.pinkAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
