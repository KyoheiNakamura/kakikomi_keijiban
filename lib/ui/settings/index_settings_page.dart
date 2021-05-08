import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/ui/authentication/registration_method_page.dart';
import 'package:kakikomi_keijiban/ui/settings/index_settings_model.dart';
import 'package:kakikomi_keijiban/ui/settings/edit_email_page.dart';
import 'package:kakikomi_keijiban/ui/settings/edit_password_page.dart';
import 'package:kakikomi_keijiban/ui/settings/edit_profile_page.dart';
import 'package:kakikomi_keijiban/ui/settings/edit_push_notification_page.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget with ShowConfirmDialogMixin {
  final bool? isCurrentUserAnonymous =
      AppModel.user?.isCurrentUserAnonymous() ?? false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsModel>(
      create: (context) => SettingsModel(),
      child: WillPopScope(
        onWillPop: () {
          Navigator.of(context).popUntil(
            ModalRoute.withName('/'),
          );
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            
            title: Text('設定'),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('プロフィール入力設定'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('プッシュ通知設定'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPushNotificationPage(),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                ),
                Divider(thickness: 1.0),
                isCurrentUserAnonymous == false
                    ? Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text('メールアドレスの変更'),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditEmailPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text('パスワードの変更'),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditPasswordPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          Divider(thickness: 1.0),
                          ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('ログアウト'),
                            onTap: () {
                              showLogoutConfirmDialog(context);
                              // Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.login),
                            title: Text('会員登録'),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RegistrationMethodPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 32.0),
                          Text(
                            'データの損失を防ぐために、\n会員登録をおすすめします。\n会員登録をした後も現在の\nデータは引き継がれます。 ',
                            style: TextStyle(
                              fontSize: 17.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
