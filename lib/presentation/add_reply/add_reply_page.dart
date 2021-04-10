import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/add_reply/add_reply_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:provider/provider.dart';

// repliedPostかrepliedReplyのどちらかを必ず取る
class AddReplyPage extends StatelessWidget {
  AddReplyPage({this.repliedPost, this.repliedReply, this.userProfile});

  final Post? repliedPost;
  final Reply? repliedReply;
  final UserProfile? userProfile;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: kLightPink,
      nextFocus: false,
      actions: [
        _keyboardActionItems(_focusNodeContent),
      ],
    );
  }

  _keyboardActionItems(_focusNode) {
    return KeyboardActionsItem(
      focusNode: _focusNode,
      toolbarButtons: [
        (node) {
          return customDoneButton(_focusNode);
        },
      ],
    );
  }

  Widget customDoneButton(FocusNode _focusNode) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(left: 8.0, right: 16.0),
        child: Text(
          '完了',
          style: TextStyle(
            color: kDarkPink,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isUserProfileNotAnonymous = userProfile != null;
    return ChangeNotifierProvider<AddReplyModel>(
      create: (context) => AddReplyModel(),
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
        body: Consumer<AddReplyModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: KeyboardActions(
                config: _buildConfig(context),
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
                            focusNode: _focusNodeContent,
                            initialValue: null,
                            validator: model.validateContentCallback,
                            // maxLength: 1000,
                            maxLines: null,
                            minLines: 5,
                            keyboardType: TextInputType.multiline,
                            onChanged: (newValue) {
                              model.bodyValue = newValue;
                            },
                            decoration: kContentTextFormFieldDecoration,
                          ),
                          SizedBox(height: 32.0),

                          /// nickname
                          TextFormField(
                            initialValue: isUserProfileNotAnonymous
                                ? model.nicknameValue = userProfile!.nickname
                                : null,
                            validator: model.validateNicknameCallback,
                            onChanged: (newValue) {
                              model.nicknameValue = newValue;
                            },
                            decoration: kNicknameTextFormFieldDecoration,
                          ),
                          SizedBox(height: 32.0),

                          /// position
                          DropdownButtonFormField(
                            focusColor: Colors.pink[50],
                            value: isUserProfileNotAnonymous
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
                                kPositionDropdownButtonFormFieldDecorationForReply,
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
                            value: isUserProfileNotAnonymous
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
                            value: isUserProfileNotAnonymous
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
                            value: isUserProfileNotAnonymous
                                ? model.areaDropdownValue = userProfile!.area
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
                          SizedBox(height: 48.0),

                          /// 投稿送信ボタン
                          OutlinedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                model.startLoading();
                                if (repliedPost != null) {
                                  await model.addReplyToPost(repliedPost!);
                                } else if (repliedReply != null) {
                                  await model.addReplyToReply(repliedReply!);
                                }
                                model.stopLoading();
                                Navigator.pop(context);
                                // Navigator.of(context).popUntil(
                                //   ModalRoute.withName('/'),
                                // );
                              }
                            },
                            child: Text(
                              '返信する',
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
