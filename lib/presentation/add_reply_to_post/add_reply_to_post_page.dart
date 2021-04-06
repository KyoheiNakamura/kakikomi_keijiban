import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_post/add_reply_to_post_model.dart';
import 'package:provider/provider.dart';

// repliedPostかexistingReplyのどちらかを必ずコンストラクタ引数に取る
class AddReplyToPostPage extends StatelessWidget {
  AddReplyToPostPage({this.repliedPost, this.existingReply, this.userProfile});

  final Post? repliedPost;
  final Reply? existingReply;
  final UserProfile? userProfile;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isReplyExisting = existingReply != null;
    final bool isUserProfileNotAnonymous = userProfile != null;
    return ChangeNotifierProvider<AddReplyToPostModel>(
      create: (context) => AddReplyToPostModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '返信',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<AddReplyToPostModel>(
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
                          vertical: 48.0, horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// content
                          TextFormField(
                            initialValue: isReplyExisting
                                ? model.bodyValue = existingReply!.body
                                : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '返信の内容を入力してください';
                              } else if (value.length > 1000) {
                                return '1000字以内でご記入ください';
                              }
                              return null;
                            },
                            // maxLength: 1000,
                            maxLines: null,
                            minLines: 3,
                            keyboardType: TextInputType.multiline,
                            onChanged: (newValue) {
                              model.bodyValue = newValue;
                            },
                            decoration: kContentTextFormFieldDecoration,
                          ),
                          SizedBox(height: 32.0),

                          /// nickname
                          TextFormField(
                            initialValue: isReplyExisting
                                ? model.nicknameValue = existingReply!.nickname
                                : isUserProfileNotAnonymous
                                    ? model.nicknameValue =
                                        userProfile!.nickname
                                    : null,
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
                            decoration:
                                kEmotionDropdownButtonFormFieldDecoration,
                          ),
                          SizedBox(height: 32.0),

                          /// position
                          DropdownButtonFormField(
                            // validator: (value) {
                            //   if (value == kPleaseSelect) {
                            //     return 'あなたの立場を選択してください';
                            //   }
                            //   return null;
                            // },
                            // focusNode: _positionFocusNode,
                            focusColor: Colors.pink[50],
                            value: isReplyExisting &&
                                    existingReply!.position.isNotEmpty
                                ? model.positionDropdownValue =
                                    existingReply!.position
                                : isUserProfileNotAnonymous
                                    ? model.positionDropdownValue =
                                        userProfile!.position
                                    : model.positionDropdownValue,
                            icon: Icon(
                              Icons.arrow_downward,
                              // color: kDarkPink,
                            ),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration:
                                kPositionDropdownButtonFormFieldDecoration,
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
                          SizedBox(height: 32.0),

                          /// gender
                          DropdownButtonFormField(
                            // focusNode: _genderFocusNode,
                            focusColor: Colors.pink[50],
                            value: isReplyExisting &&
                                    existingReply!.gender.isNotEmpty
                                ? model.genderDropdownValue =
                                    existingReply!.gender
                                : isUserProfileNotAnonymous
                                    ? model.genderDropdownValue =
                                        userProfile!.gender
                                    : model.genderDropdownValue,
                            icon: Icon(
                              Icons.arrow_downward,
                              // color: kDarkPink,
                            ),
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
                          SizedBox(height: 32.0),

                          /// age
                          DropdownButtonFormField(
                            // focusNode: _ageFocusNode,
                            focusColor: Colors.pink[50],
                            value: isReplyExisting &&
                                    existingReply!.age.isNotEmpty
                                ? model.ageDropdownValue = existingReply!.age
                                : isUserProfileNotAnonymous
                                    ? model.ageDropdownValue = userProfile!.age
                                    : model.ageDropdownValue,
                            icon: Icon(
                              Icons.arrow_downward,
                              // color: kDarkPink,
                            ),
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
                          SizedBox(height: 32.0),

                          /// area
                          DropdownButtonFormField(
                            // focusNode: _areaFocusNode,
                            focusColor: Colors.pink[50],
                            value: isReplyExisting &&
                                    existingReply!.area.isNotEmpty
                                ? model.areaDropdownValue = existingReply!.area
                                : isUserProfileNotAnonymous
                                    ? model.areaDropdownValue =
                                        userProfile!.area
                                    : model.areaDropdownValue,
                            icon: Icon(
                              Icons.arrow_downward,
                              // color: kDarkPink,
                            ),
                            iconSize: 24,
                            elevation: 1,
                            style: kDropdownButtonFormFieldTextStyle,
                            decoration: kAreaDropdownButtonFormFieldDecoration,
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
                          SizedBox(
                            height: 48.0,
                          ),

                          /// 投稿送信ボタン
                          OutlinedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                model.startLoading();
                                isReplyExisting
                                    ? await model.updateReply(existingReply!)
                                    : await model.addReply(repliedPost!);
                                model.stopLoading();
                                Navigator.pop(context);
                                // Navigator.of(context).popUntil(
                                //   ModalRoute.withName('/'),
                                // );
                              }
                            },
                            child: Text(
                              isReplyExisting ? '更新する' : '返信する',
                              style: TextStyle(
                                color: kDarkPink,
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: kDarkPink),
                            ),
                          )
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
