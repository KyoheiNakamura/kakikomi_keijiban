import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/select_registration_method/select_registration_method_page.dart';
import 'package:kakikomi_keijiban/presentation/settings/settings_model.dart';
import 'package:kakikomi_keijiban/presentation/update_email/update_email_page.dart';
import 'package:kakikomi_keijiban/presentation/update_password/update_password_page.dart';
import 'package:kakikomi_keijiban/presentation/update_profile/update_profile_page.dart';
import 'package:kakikomi_keijiban/presentation/update_push_notification/update_push_notification_page.dart';
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
            toolbarHeight: 50,
            title: Text(
              '設定',
              style: kAppBarTextStyle,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('デフォルト入力設定'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProfilePage(),
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
                        builder: (context) => UpdatePushNotificationPage(),
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
                                  builder: (context) => UpdateEmailPage(),
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
                                  builder: (context) => UpdatePasswordPage(),
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
                                      SelectRegistrationMethodPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 32.0),
                          Text(
                            'データの損失を防ぐために、\n新規会員登録がおすすめです。',
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
          // SingleChildScrollView(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16.0, top: 24.0, right: 16.0, bottom: 16.0),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // Icon(Icons.email_outlined, color: Colors.white),
          //               Padding(
          //                 padding: const EdgeInsets.all(12.0),
          //                 child: Text(
          //                   'プロフィール設定',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16.0,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => UpdateProfilePage(),
          //               ),
          //             );
          //             // Navigator.pop(context);
          //           },
          //           style: ButtonStyle(
          //             backgroundColor: MaterialStateProperty.all(kDarkPink),
          //           ),
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16.0, top: 12.0, right: 16.0, bottom: 24.0),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // Icon(Icons.email_outlined, color: Colors.white),
          //               Padding(
          //                 padding: const EdgeInsets.all(12.0),
          //                 child: Text(
          //                   'プッシュ通知設定',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16.0,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => UpdatePushNotificationPage(),
          //               ),
          //             );
          //             // Navigator.pop(context);
          //           },
          //           style: ButtonStyle(
          //             backgroundColor: MaterialStateProperty.all(kDarkPink),
          //           ),
          //         ),
          //       ),
          //       Divider(thickness: 1.0),
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16.0, top: 24.0, right: 16.0, bottom: 16.0),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // Icon(Icons.login_outlined, color: kDarkPink),
          //               Padding(
          //                 padding: const EdgeInsets.all(12.0),
          //                 child: Text(
          //                   'メールアドレスの変更',
          //                   style: TextStyle(
          //                     color: kDarkPink,
          //                     fontSize: 16.0,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => UpdateEmailPage(),
          //               ),
          //             );
          //             // Navigator.pop(context);
          //           },
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16.0, top: 12.0, right: 16.0, bottom: 16.0),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // Icon(Icons.login_outlined, color: kDarkPink),
          //               Padding(
          //                 padding: const EdgeInsets.all(12.0),
          //                 child: Text(
          //                   'パスワードの変更',
          //                   style: TextStyle(
          //                     color: kDarkPink,
          //                     fontSize: 16.0,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => UpdatePasswordPage(),
          //               ),
          //             );
          //             // Navigator.pop(context);
          //           },
          //         ),
          //       ),
          //       Divider(thickness: 1.0),
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16.0, top: 12.0, right: 16.0, bottom: 16.0),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // Icon(Icons.login_outlined, color: kDarkPink),
          //               Padding(
          //                 padding: const EdgeInsets.all(12.0),
          //                 child: Text(
          //                   'ログアウト',
          //                   style: TextStyle(
          //                     color: kDarkPink,
          //                     fontSize: 16.0,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             showLogoutConfirmDialog(context);
          //             // Navigator.pop(context);
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }
}
