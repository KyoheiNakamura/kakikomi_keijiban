import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/update_reply_to_reply/update_reply_to_reply_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class UpdateReplyToReplyPage extends StatelessWidget
    with ShowConfirmDialogMixin, KeyboardActionsConfigDoneMixin {
  UpdateReplyToReplyPage(
      {required this.existingReplyToReply, required this.passedModel});

  final ReplyToReply existingReplyToReply;
  final passedModel;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    final UserProfile? userProfile = context.read<AppModel>().userProfile;
    final bool isUserProfileExisting = userProfile != null;
    return WillPopScope(
      onWillPop: () {
        showConfirmDialog(context);
        return Future.value(true);
      },
      child: ChangeNotifierProvider<UpdateReplyToReplyModel>(
        create: (context) => UpdateReplyToReplyModel(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            elevation: 0,
            centerTitle: true,
            title: Text(
              '編集',
              style: kAppBarTextStyle,
            ),
          ),
          body: Consumer<UpdateReplyToReplyModel>(
            builder: (context, model, child) {
              return LoadingSpinner(
                inAsyncCall: model.isLoading,
                child: KeyboardActions(
                  config: buildConfig(context, _focusNodeContent),
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
                              initialValue: model.bodyValue =
                                  existingReplyToReply.body,
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
                              initialValue: model.nicknameValue =
                                  existingReplyToReply.nickname,
                              validator: model.validateNicknameCallback,
                              onChanged: (newValue) {
                                model.nicknameValue = newValue;
                              },
                              decoration:
                                  kEmotionDropdownButtonFormFieldDecoration,
                            ),
                            SizedBox(height: 32.0),

                            /// position
                            DropdownButtonFormField(
                              focusColor: Colors.pink[50],
                              value: existingReplyToReply.position.isNotEmpty
                                  ? model.positionDropdownValue =
                                      existingReplyToReply.position
                                  : isUserProfileExisting
                                      ? model.positionDropdownValue =
                                          userProfile.position
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
                              value: existingReplyToReply.gender.isNotEmpty
                                  ? model.genderDropdownValue =
                                      existingReplyToReply.gender
                                  : isUserProfileExisting
                                      ? model.genderDropdownValue =
                                          userProfile.gender
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
                              value: existingReplyToReply.age.isNotEmpty
                                  ? model.ageDropdownValue =
                                      existingReplyToReply.age
                                  : isUserProfileExisting
                                      ? model.ageDropdownValue = userProfile.age
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
                              value: existingReplyToReply.area.isNotEmpty
                                  ? model.areaDropdownValue =
                                      existingReplyToReply.area
                                  : isUserProfileExisting
                                      ? model.areaDropdownValue =
                                          userProfile.area
                                      : model.areaDropdownValue,
                              icon: Icon(
                                Icons.arrow_downward,
                                // color: kDarkPink,
                              ),
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
                            SizedBox(
                              height: 48.0,
                            ),

                            /// 投稿送信ボタン
                            passedModel is! DraftsModel
                                ? OutlinedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        model.startLoading();
                                        await model.updateReplyToReply(
                                            existingReplyToReply);
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      side: BorderSide(color: kDarkPink),
                                    ),
                                  )
                                :

                                /// 投稿送信ボタン
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await model
                                                .addReplyToReplyFromDraft(
                                                    existingReplyToReply);
                                            Navigator.pop(
                                              context,
                                              ResultForDraftButton
                                                  .addPostFromDraft,
                                            );
                                            // Navigator.of(context).popUntil(
                                            //   ModalRoute.withName('/'),
                                            // );
                                          }
                                        },
                                        child: Text(
                                          '投稿する',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: kDarkPink,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          side: BorderSide(color: kDarkPink),
                                        ),
                                      ),
                                      SizedBox(height: 16.0),

                                      /// 下書き保存ボタン
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await model.updateDraftReplyToReply(
                                                existingReplyToReply);
                                            Navigator.pop(
                                              context,
                                              ResultForDraftButton.updateDraft,
                                            );
                                            // Navigator.of(context).popUntil(
                                            //   ModalRoute.withName('/'),
                                            // );
                                          }
                                        },
                                        child: Text(
                                          '下書きに保存する',
                                          style: TextStyle(
                                            color: kDarkPink,
                                            fontSize: 16,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          side: BorderSide(color: kDarkPink),
                                        ),
                                      ),
                                    ],
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
