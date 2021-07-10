import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/home/home_page.dart';
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
      child: Consumer<SettingsModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: commonAppBar(title: '設定'),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
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
                    leading: const Icon(Icons.notifications_outlined),
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
                              leading: const Icon(Icons.email_outlined),
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
                              leading: const Icon(Icons.lock_outlined),
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
                              onTap: () async {
                                final isLoggedOut =
                                    await showLogoutConfirmDialog(context);
                                if (isLoggedOut) {
                                  model.signOut();
                                }
                                await Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                  (_) => false,
                                );
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
          );
        },
      ),
    );
  }
}
