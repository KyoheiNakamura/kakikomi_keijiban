import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/build_keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/domain/reply_to_reply.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/update_reply_to_reply/update_reply_to_reply_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class UpdateReplyToReplyPage extends StatelessWidget
    with
        ShowConfirmDialogMixin,
        KeyboardActionsConfigDoneMixin,
        ShowExceptionDialogMixin {
  UpdateReplyToReplyPage({
    required this.existingReplyToReply,
    required this.passedModel,
  });

  final ReplyToReply existingReplyToReply;
  final dynamic passedModel;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDiscardConfirmDialog(context);
        return true;
      },
      child: ChangeNotifierProvider<UpdateReplyToReplyModel>(
        create: (context) => UpdateReplyToReplyModel(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: const Text('編集'),
          ),
          body: Consumer<UpdateReplyToReplyModel>(
            builder: (context, model, child) {
              final user = AppModel.user;
              final isUserExisting = user != null;
              return LoadingSpinner(
                inAsyncCall: model.isLoading,
                child: KeyboardActions(
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
                            const SizedBox(height: 32),

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
                            const SizedBox(height: 32),

                            /// position
                            DropdownButtonFormField(
                              focusColor: Colors.pink[50],
                              value: existingReplyToReply.position.isNotEmpty
                                  ? model.positionDropdownValue =
                                      existingReplyToReply.position
                                  : isUserExisting
                                      ? model.positionDropdownValue =
                                          user!.position
                                      : model.positionDropdownValue,
                              icon: const Icon(
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
                            const SizedBox(height: 32),

                            /// gender
                            DropdownButtonFormField(
                              // focusNode: _genderFocusNode,
                              focusColor: Colors.pink[50],
                              value: existingReplyToReply.gender.isNotEmpty
                                  ? model.genderDropdownValue =
                                      existingReplyToReply.gender
                                  : isUserExisting
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
                              value: existingReplyToReply.age.isNotEmpty
                                  ? model.ageDropdownValue =
                                      existingReplyToReply.age
                                  : isUserExisting
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
                              value: existingReplyToReply.area.isNotEmpty
                                  ? model.areaDropdownValue =
                                      existingReplyToReply.area
                                  : isUserExisting
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
                            const SizedBox(
                              height: 48,
                            ),

                            /// 投稿更新ボタン
                            passedModel is! DraftsModel
                                ? OutlinedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        try {
                                          await model.updateReplyToReply(
                                              existingReplyToReply);
                                          Navigator.pop(context);
                                        } on String catch (e) {
                                          await showExceptionDialog(
                                            context,
                                            e.toString(),
                                          );
                                        }
                                        // Navigator.of(context).popUntil(
                                        //   ModalRoute.withName('/'),
                                        // );
                                      } else {
                                        await showRequiredInputConfirmDialog(
                                            context);
                                      }
                                    },
                                    child: const Text(
                                      '更新する',
                                      style: TextStyle(
                                        color: kDarkPink,
                                        fontSize: 16,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      side: const BorderSide(color: kDarkPink),
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
                                                  .addReplyToReplyFromDraft(
                                                      existingReplyToReply);
                                              Navigator.pop(
                                                context,
                                                ResultForDraftButton
                                                    .addPostFromDraft,
                                              );
                                            } on String catch (e) {
                                              await showExceptionDialog(
                                                context,
                                                e.toString(),
                                              );
                                            }
                                            // Navigator.of(context).popUntil(
                                            //   ModalRoute.withName('/'),
                                            // );
                                          } else {
                                            await showRequiredInputConfirmDialog(
                                                context);
                                          }
                                        },
                                        child: const Text(
                                          '投稿する',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: kDarkPink,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          side: const BorderSide(
                                              color: kDarkPink),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      /// 下書き保存ボタン
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            try {
                                              await model
                                                  .updateDraftReplyToReply(
                                                      existingReplyToReply);
                                              const snackBar = SnackBar(
                                                content:
                                                    const Text('下書きに保存しました'),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                              Navigator.pop(
                                                context,
                                                ResultForDraftButton
                                                    .updateDraft,
                                              );
                                            } on String catch (e) {
                                              await showExceptionDialog(
                                                context,
                                                e.toString(),
                                              );
                                            }
                                            // Navigator.of(context).popUntil(
                                            //   ModalRoute.withName('/'),
                                            // );
                                          } else {
                                            await showRequiredInputConfirmDialog(
                                                context);
                                          }
                                        },
                                        child: const Text(
                                          '下書きに保存する',
                                          style: TextStyle(
                                            color: kDarkPink,
                                            fontSize: 16,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          side: const BorderSide(
                                              color: kDarkPink),
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
