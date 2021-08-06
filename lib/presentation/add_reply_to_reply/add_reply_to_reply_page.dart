import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/build_keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:kakikomi_keijiban/presentation/add_reply_to_reply/add_reply_to_reply_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class AddReplyToReplyPage extends StatelessWidget
    with
        ShowConfirmDialogMixin,
        KeyboardActionsConfigDoneMixin,
        ShowExceptionDialogMixin {
  AddReplyToReplyPage({
    required this.repliedReply,
    Key? key,
  }) : super(key: key);

  final Reply repliedReply;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await showDiscardConfirmDialog(context);
        return true;
      },
      child: GestureDetector(
        onTap: () {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: ChangeNotifierProvider<AddReplyToReplyModel>(
          create: (context) => AddReplyToReplyModel(),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 50,
              title: const Text('返信'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Consumer<AddReplyToReplyModel>(
                      builder: (context, model, child) {
                    return TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await model.addDraftedReplyToReply(
                              context,
                              repliedReply: repliedReply,
                            );
                            const snackBar = SnackBar(
                              content: Text('下書きに保存しました'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.pop(context);
                          } on Exception catch (e) {
                            await showExceptionDialog(context, e);
                          }
                        } else {
                          await showRequiredInputConfirmDialog(context);
                        }
                      },
                      child: const Text(
                        '下書き保存',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }),
                )
              ],
            ),
            body: Consumer<AddReplyToReplyModel>(
              builder: (context, model, child) {
                final user = AppModel.user;
                final isUserExisting = user != null;
                return KeyboardActions(
                  config: buildConfig(context, _focusNodeContent),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 48, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// content
                            TextFormField(
                              controller: model.bodyController,
                              focusNode: _focusNodeContent,
                              validator: model.validateContentCallback,
                              // maxLength: 1000,
                              maxLines: null,
                              minLines: 5,
                              keyboardType: TextInputType.multiline,
                              decoration: kContentTextFormFieldDecoration,
                            ),
                            const SizedBox(height: 32),

                            /// nickname
                            TextFormField(
                              controller: model.nicknameController,
                              validator: model.validateNicknameCallback,
                              decoration: kNicknameTextFormFieldDecoration,
                            ),
                            const SizedBox(height: 32),

                            /// position
                            DropdownButtonFormField(
                              focusColor: Colors.pink[50],
                              value: isUserExisting
                                  ? model.positionDropdownValue = user!.position
                                  : model.positionDropdownValue,
                              icon: const Icon(
                                Icons.arrow_downward,
                                // color: kDarkPink,
                              ),
                              iconSize: 24,
                              elevation: 1,
                              style: kDropdownButtonFormFieldTextStyle,
                              decoration:
                                  // ignore: lines_longer_than_80_chars
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
                            const SizedBox(height: 32),

                            /// gender
                            DropdownButtonFormField(
                              // focusNode: _genderFocusNode,
                              focusColor: Colors.pink[50],
                              value: isUserExisting
                                  ? model.genderDropdownValue = user!.gender
                                  : model.genderDropdownValue,
                              icon: const Icon(
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
                            const SizedBox(height: 32),

                            /// age
                            DropdownButtonFormField(
                              // focusNode: _ageFocusNode,
                              focusColor: Colors.pink[50],
                              value: isUserExisting
                                  ? model.ageDropdownValue = user!.age
                                  : model.ageDropdownValue,
                              icon: const Icon(
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
                            const SizedBox(height: 32),

                            /// area
                            DropdownButtonFormField(
                              // focusNode: _areaFocusNode,
                              focusColor: Colors.pink[50],
                              value: isUserExisting
                                  ? model.areaDropdownValue = user!.area
                                  : model.areaDropdownValue,
                              icon: const Icon(
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
                            const SizedBox(height: 48),

                            /// 投稿送信ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await model.addReplyToReply(
                                      context,
                                      repliedReply: repliedReply,
                                    );
                                    Navigator.pop(context);
                                  } on Exception catch (e) {
                                    await showExceptionDialog(context, e);
                                  }
                                } else {
                                  await showRequiredInputConfirmDialog(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: kDarkPink,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: const BorderSide(color: kDarkPink),
                              ),
                              child: const Text(
                                '返信する',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// 下書き保存ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await model.addDraftedReplyToReply(
                                      context,
                                      repliedReply: repliedReply,
                                    );
                                    const snackBar = SnackBar(
                                      content: Text('下書きに保存しました'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Navigator.pop(context);
                                  } on Exception catch (e) {
                                    await showExceptionDialog(context, e);
                                  }
                                  // Navigator.of(context).popUntil(
                                  //   ModalRoute.withName('/'),
                                  // );
                                } else {
                                  await showRequiredInputConfirmDialog(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: const BorderSide(color: kDarkPink),
                              ),
                              child: const Text(
                                '下書きに保存する',
                                style: TextStyle(
                                  color: kDarkPink,
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
