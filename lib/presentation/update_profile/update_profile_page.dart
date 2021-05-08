import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/update_profile/update_profile_model.dart';
import 'package:provider/provider.dart';

class UpdateProfilePage extends StatelessWidget with ShowExceptionDialogMixin {
  final user = AppModel.user!;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateProfileModel>(
      create: (context) => UpdateProfileModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text('プロフィール入力設定'),
        ),
        body: Consumer<UpdateProfileModel>(
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
                              initialValue: model.nicknameValue = user.nickname,
                              validator: model.validateNicknameCallback,
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
                              value: user.position.isNotEmpty
                                  ? model.positionDropdownValue = user.position
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
                              value: user.gender.isNotEmpty
                                  ? model.genderDropdownValue = user.gender
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
                              value: user.age.isNotEmpty
                                  ? model.ageDropdownValue = user.age
                                  : model.ageDropdownValue,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 1,
                              style: kDropdownButtonFormFieldTextStyle,
                              decoration: kAgeDropdownButtonFormFieldDecoration,
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
                              value: user.area.isNotEmpty
                                  ? model.areaDropdownValue = user.area
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
                                try {
                                  await model.updateUserProfile();
                                  await AppModel.reloadUser();
                                  Navigator.of(context).popUntil(
                                    ModalRoute.withName('/'),
                                  );
                                } catch (e) {
                                  await showExceptionDialog(
                                    context,
                                    e.toString(),
                                  );
                                }
                                // Navigator.pop(context);
                              }
                            },
                            child: Text(
                              '更新する',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: kDarkPink,
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
    );
  }
}
