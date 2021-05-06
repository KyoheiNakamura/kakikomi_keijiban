import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/build_keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/domain/reply.dart';
import 'package:kakikomi_keijiban/domain/user.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_reply/add_reply_to_reply_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class AddReplyToReplyPage extends StatelessWidget
    with
        ShowConfirmDialogMixin,
        KeyboardActionsConfigDoneMixin,
        ShowExceptionDialogMixin {
  AddReplyToReplyPage(this.repliedReply);

  final Reply repliedReply;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDiscardConfirmDialog(context);
        return true;
      },
      child: ChangeNotifierProvider<AddReplyToReplyModel>(
        create: (context) => AddReplyToReplyModel(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: Text('返信'),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Consumer<AddReplyToReplyModel>(
                    builder: (context, model, child) {
                  return TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await model.addDraftedReplyToReply(repliedReply);
                          final snackBar = SnackBar(
                            content: Text('下書きに保存しました'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context);
                        } catch (e) {
                          await showExceptionDialog(
                            context,
                            e.toString(),
                          );
                        }
                      } else {
                        await showRequiredInputConfirmDialog(context);
                      }
                    },
                    child: Text(
                      '下書き保存',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
              )
            ],
          ),
          body: Consumer<AddReplyToReplyModel>(
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
                              initialValue: isUserExisting
                                  ? model.nicknameValue = user.nickname
                                  : model.nicknameValue = '匿名',
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
                              value: isUserExisting
                                  ? model.positionDropdownValue = user.position
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
                              value: isUserExisting
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
                              value: isUserExisting
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
                              value: isUserExisting
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
                            SizedBox(height: 48.0),

                            /// 投稿送信ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await model.addReplyToReply(repliedReply);
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
                                } else {
                                  await showRequiredInputConfirmDialog(context);
                                }
                              },
                              child: Text(
                                '返信する',
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
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: BorderSide(color: kDarkPink),
                              ),
                            ),

                            SizedBox(height: 16.0),

                            /// 下書き保存ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await model
                                        .addDraftedReplyToReply(repliedReply);
                                    final snackBar = SnackBar(
                                      content: Text('下書きに保存しました'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
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
                                } else {
                                  await showRequiredInputConfirmDialog(context);
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
