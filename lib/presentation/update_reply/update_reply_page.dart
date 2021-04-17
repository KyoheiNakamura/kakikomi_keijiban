import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/update_reply/update_reply_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class UpdateReplyPage extends StatelessWidget
    with
        ShowConfirmDialogMixin,
        KeyboardActionsConfigDoneMixin,
        ShowExceptionDialogMixin {
  UpdateReplyPage({required this.existingReply, required this.passedModel});

  final Reply existingReply;
  final passedModel;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        showConfirmDialog(context);
        return Future.value(true);
      },
      child: ChangeNotifierProvider<UpdateReplyModel>(
        create: (context) => UpdateReplyModel(),
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
          body: Consumer<UpdateReplyModel>(
            builder: (context, model, child) {
              final User? user = AppModel.user;
              final bool isUserExisting = user != null;
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
                                  existingReply.body,
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
                                  existingReply.nickname,
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
                              value: existingReply.position.isNotEmpty
                                  ? model.positionDropdownValue =
                                      existingReply.position
                                  : isUserExisting
                                      ? model.positionDropdownValue =
                                          user.position
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
                              value: existingReply.gender.isNotEmpty
                                  ? model.genderDropdownValue =
                                      existingReply.gender
                                  : isUserExisting
                                      ? model.genderDropdownValue = user.gender
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
                              value: existingReply.age.isNotEmpty
                                  ? model.ageDropdownValue = existingReply.age
                                  : isUserExisting
                                      ? model.ageDropdownValue = user.age
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
                              value: existingReply.area.isNotEmpty
                                  ? model.areaDropdownValue = existingReply.area
                                  : isUserExisting
                                      ? model.areaDropdownValue = user.area
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

                            /// 投稿更新ボタン
                            passedModel is! DraftsModel
                                ? OutlinedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        try {
                                          await model
                                              .updateReply(existingReply);
                                          Navigator.pop(context);
                                        } catch (e) {
                                          await showExceptionDialog(
                                            context,
                                            e.toString(),
                                          );
                                        }
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
                                            try {
                                              await model
                                                  .addReplyToPostFromDraft(
                                                      existingReply);
                                              Navigator.pop(
                                                context,
                                                ResultForDraftButton
                                                    .addPostFromDraft,
                                              );
                                            } catch (e) {
                                              await showExceptionDialog(
                                                context,
                                                e.toString(),
                                              );
                                            }
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
                                            try {
                                              await model.updateDraftReply(
                                                  existingReply);
                                              final snackBar = SnackBar(
                                                content: Text('下書きに保存しました'),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                              Navigator.pop(
                                                context,
                                                ResultForDraftButton
                                                    .updateDraft,
                                              );
                                            } catch (e) {
                                              await showExceptionDialog(
                                                context,
                                                e.toString(),
                                              );
                                            }
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
