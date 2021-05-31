import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
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
            title: const Text('設定'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('デフォルト入力設定'),
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProfilePage(),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('プッシュ通知設定'),
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePushNotificationPage(),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                ),
                const Divider(thickness: 1),
                isCurrentUserAnonymous == false
                    ? Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('メールアドレスの変更'),
                            onTap: () async {
                              await Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateEmailPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text('パスワードの変更'),
                            onTap: () async {
                              await Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdatePasswordPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          const Divider(thickness: 1),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('ログアウト'),
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
                            leading: const Icon(Icons.login),
                            title: const Text('会員登録'),
                            onTap: () async {
                              await Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SelectRegistrationMethodPage(),
                                ),
                              );
                              // Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'データの損失を防ぐために、会員登録をおすすめします。\n'
                            '会員登録をした後も現在のデータは引き継がれます。 ',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.start,
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
          //             left: 16, top: 24, right: 16, bottom: 16),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // const Icon(Icons.email_outlined, color: Colors.white),
          //               Padding(
          //                 padding: const EdgeInsets.all(12),
          //                 child: const Text(
          //                   'プロフィール設定',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push<void>(
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
          //             left: 16, top: 12, right: 16, bottom: 24),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // const Icon(Icons.email_outlined, color: Colors.white),
          //               Padding(
          //                 padding: const EdgeInsets.all(12),
          //                 child: const Text(
          //                   'プッシュ通知設定',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push<void>(
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
          //       Divider(thickness: 1),
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16, top: 24, right: 16, bottom: 16),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // const Icon(Icons.login_outlined, color: kDarkPink),
          //               Padding(
          //                 padding: const EdgeInsets.all(12),
          //                 child: const Text(
          //                   'メールアドレスの変更',
          //                   style: TextStyle(
          //                     color: kDarkPink,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push<void>(
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
          //             left: 16, top: 12, right: 16, bottom: 16),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // const Icon(Icons.login_outlined, color: kDarkPink),
          //               Padding(
          //                 padding: const EdgeInsets.all(12),
          //                 child: const Text(
          //                   'パスワードの変更',
          //                   style: TextStyle(
          //                     color: kDarkPink,
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           onPressed: () async {
          //             await Navigator.push<void>(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => UpdatePasswordPage(),
          //               ),
          //             );
          //             // Navigator.pop(context);
          //           },
          //         ),
          //       ),
          //       Divider(thickness: 1),
          //       Padding(
          //         padding: const EdgeInsets.only(
          //             left: 16, top: 12, right: 16, bottom: 16),
          //         child: OutlinedButton(
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               // const Icon(Icons.login_outlined, color: kDarkPink),
          //               Padding(
          //                 padding: const EdgeInsets.all(12),
          //                 child: const Text(
          //                   'ログアウト',
          //                   style: TextStyle(
          //                     color: kDarkPink,
          //                     fontSize: 16,
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
