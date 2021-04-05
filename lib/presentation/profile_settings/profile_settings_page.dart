import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/profile_settings/profile_settings_model.dart';
import 'package:provider/provider.dart';

class ProfileSettingsPage extends StatelessWidget {
  ProfileSettingsPage(this.userProfile);

  final UserProfile userProfile;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileSettingsModel>(
      create: (context) => ProfileSettingsModel(),
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
              'プロフィール設定',
              style: kAppBarTextStyle,
            ),
          ),
          body: Consumer<ProfileSettingsModel>(
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
                          horizontal: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// nickname
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: TextFormField(
                                initialValue: model.nicknameValue =
                                    userProfile.nickname,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ニックネームを入力してください';
                                  } else if (value.length > 10) {
                                    return '10字以内でご記入ください';
                                  }
                                  return null;
                                },
                                onChanged: (newValue) {
                                  model.nicknameValue = newValue;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.face),
                                  labelText: 'ニックネーム',
                                  hintText: 'ムセンシティ部',
                                ),
                              ),
                            ),

                            /// position
                            // Todo positionを複数選択できるようにしよう
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: DropdownButtonFormField(
                                value: userProfile.position.isNotEmpty
                                    ? model.positionDropdownValue =
                                        userProfile.position
                                    : model.positionDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'あなたの立場',
                                  helperStyle: TextStyle(color: kDarkPink),
                                  prefixIcon: Icon(Icons.group),
                                ),
                                onChanged: (String? selectedValue) {
                                  model.positionDropdownValue = selectedValue!;
                                },
                                items: kPositionList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// gender
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: DropdownButtonFormField(
                                value: userProfile.gender.isNotEmpty
                                    ? model.genderDropdownValue =
                                        userProfile.gender
                                    : model.genderDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kGenderDropdownButtonFormFieldDecoration,
                                onChanged: (String? selectedValue) {
                                  model.genderDropdownValue = selectedValue!;
                                },
                                items: kGenderList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// age
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: DropdownButtonFormField(
                                value: userProfile.age.isNotEmpty
                                    ? model.ageDropdownValue = userProfile.age
                                    : model.ageDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kAgeDropdownButtonFormFieldDecoration,
                                onChanged: (String? selectedValue) {
                                  model.ageDropdownValue = selectedValue!;
                                },
                                items: kAgeList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// area
                            Padding(
                              padding: const EdgeInsets.only(bottom: 48.0),
                              child: DropdownButtonFormField(
                                value: userProfile.area.isNotEmpty
                                    ? model.areaDropdownValue = userProfile.area
                                    : model.areaDropdownValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kAreaDropdownButtonFormFieldDecoration,
                                onChanged: (String? selectedValue) {
                                  model.areaDropdownValue = selectedValue!;
                                },
                                items: kAreaList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// 投稿送信ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  model.startLoading();
                                  await model.updateUserProfile();
                                  model.stopLoading();
                                  Navigator.pop(context);
                                  // Navigator.of(context).popUntil(
                                  //   ModalRoute.withName('/'),
                                  // );
                                }
                              },
                              child: Text(
                                '更新する',
                                style: TextStyle(
                                  color: kDarkPink,
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                side: BorderSide(color: kDarkPink),
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
      ),
    );
  }
}
