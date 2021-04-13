import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/settings/settings_model.dart';
import 'package:kakikomi_keijiban/presentation/update_email/update_email_page.dart';
import 'package:kakikomi_keijiban/presentation/update_password/update_password_page.dart';
import 'package:kakikomi_keijiban/presentation/update_profile/update_profile_page.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage(this.userProfile);

  final UserProfile userProfile;

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
            elevation: 0,
            centerTitle: true,
            title: Text(
              '設定',
              style: kAppBarTextStyle,
            ),
          ),
          // Todo めちゃくちゃ簡潔に書けそうなので、後で書き直そう
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 24.0, right: 16.0, bottom: 12.0),
                child: OutlinedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.email_outlined, color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'プロフィール設定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProfilePage(userProfile)),
                    );
                    // Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(kDarkPink),
                  ),
                ),
              ),
              Divider(thickness: 1.0),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 12.0, right: 16.0, bottom: 16.0),
                child: OutlinedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.login_outlined, color: kDarkPink),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'メールアドレスの変更',
                          style: TextStyle(
                            color: kDarkPink,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateEmailPage()),
                    );
                    // Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 12.0, right: 16.0, bottom: 16.0),
                child: OutlinedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.login_outlined, color: kDarkPink),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'パスワードの変更',
                          style: TextStyle(
                            color: kDarkPink,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdatePasswordPage()),
                    );
                    // Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
