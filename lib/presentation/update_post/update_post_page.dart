import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';
import 'package:kakikomi_keijiban/common/mixin/build_keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class UpdatePostPage extends StatelessWidget
    with
        ShowConfirmDialogMixin,
        KeyboardActionsConfigDoneMixin,
        ShowExceptionDialogMixin {
  UpdatePostPage({
    required this.existingPost,
    // required this.passedModel,
    Key? key,
  }) : super(key: key);

  final Post existingPost;
  // final dynamic passedModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await showDiscardConfirmDialog(context);
        return true;
      },
      child: ChangeNotifierProvider<UpdatePostModel>(
        create: (context) =>
            UpdatePostModel(existingPost: existingPost)..init(),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: const Text('編集'),
          ),
          body: Consumer<UpdatePostModel>(
            builder: (context, model, child) {
              final user = AppModel.user;
              final isUserExisting = user != null;
              if (model.selectedCategories.isEmpty) {
                model.selectedCategories.addAll(existingPost.categories!);
              }
              return LoadingSpinner(
                isModalLoading: model.isLoading,
                child: KeyboardActions(
                  config: buildConfig(context, _focusNodeContent),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// title
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: TextFormField(
                                controller: model.titleController,
                                validator: model.validateTitleCallback,
                                decoration: kTitleTextFormFieldDecoration,
                              ),
                            ),

                            /// content
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: TextFormField(
                                focusNode: _focusNodeContent,
                                controller: model.bodyController,
                                validator: model.validateContentCallback,
                                minLines: 3,
                                maxLines: null,
                                decoration: kContentTextFormFieldDecoration,
                              ),
                            ),

                            /// nickname
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: TextFormField(
                                controller: model.nicknameController,
                                validator: model.validateNicknameCallback,
                                decoration: kNicknameTextFormFieldDecoration,
                              ),
                            ),

                            /// emotion
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: DropdownButtonFormField(
                                validator: model.validateEmotionCallback,
                                value: model.emotionDropdownValue =
                                    existingPost.emotion!,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kEmotionDropdownButtonFormFieldDecoration,
                                onChanged: (String? selectedValue) {
                                  model.emotionDropdownValue = selectedValue!;
                                },
                                items: kEmotionList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// category チップ複数選択
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: model.isCategoriesValid
                                      ? Colors.grey[500]!
                                      : kDarkPink,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Icon(
                                          Icons.category_outlined,
                                          color: model.isCategoriesValid
                                              ? kGrey
                                              : kDarkPink,
                                        ),
                                      ),
                                      Text(
                                        'カテゴリー',
                                        style: TextStyle(
                                          color: model.isCategoriesValid
                                              ? Colors.grey[700]
                                              : kDarkPink,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 14),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 2,
                                      // alignment: WrapAlignment.center,
                                      children:
                                          kCategoryList.map<Widget>((item) {
                                        return FilterChipWidget(
                                          chipName: item,
                                          model: model,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 32),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    model.isCategoriesValid
                                        ? '必須'
                                        : 'カテゴリーを選択してください',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kDarkPink,
                                    ),
                                  ),
                                  const Text(
                                    '5つ以内で選択してください',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// position
                            // Todo positionを複数選択できるようにしよう
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: DropdownButtonFormField(
                                // validator: model.validatePositionCallback,
                                value: existingPost.position!.isNotEmpty
                                    ? model.positionDropdownValue =
                                        existingPost.position!
                                    : isUserExisting
                                        ? model.positionDropdownValue =
                                            user!.position
                                        : model.positionDropdownValue,
                                icon: const Icon(Icons.arrow_downward),
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
                            ),

                            /// gender
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: DropdownButtonFormField(
                                value: existingPost.gender!.isNotEmpty
                                    ? model.genderDropdownValue =
                                        existingPost.gender!
                                    : isUserExisting
                                        ? model.genderDropdownValue =
                                            user!.gender
                                        : model.genderDropdownValue,
                                icon: const Icon(Icons.arrow_downward),
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
                              padding: const EdgeInsets.only(bottom: 32),
                              child: DropdownButtonFormField(
                                value: existingPost.age!.isNotEmpty
                                    ? model.ageDropdownValue = existingPost.age!
                                    : isUserExisting
                                        ? model.ageDropdownValue = user!.age
                                        : model.ageDropdownValue,
                                icon: const Icon(Icons.arrow_downward),
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
                              padding: const EdgeInsets.only(bottom: 48),
                              child: DropdownButtonFormField(
                                value: existingPost.area!.isNotEmpty
                                    ? model.areaDropdownValue =
                                        existingPost.area!
                                    : isUserExisting
                                        ? model.areaDropdownValue = user!.area
                                        : model.areaDropdownValue,
                                icon: const Icon(Icons.arrow_downward),
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

                            /// 投稿更新ボタン
                            // passedModel is! DraftsModel
                            // ?
                            OutlinedButton(
                              onPressed: () async {
                                if (model.validateSelectedCategories() &&
                                    _formKey.currentState!.validate()) {
                                  try {
                                    await model.updatePost();
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
                                '更新する',
                                style: TextStyle(
                                  color: kDarkPink,
                                  fontSize: 16,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            // :

                            // /// 投稿送信ボタン
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.stretch,
                            //   children: [
                            //     OutlinedButton(
                            //       onPressed: () async {
                            //         if (model.validateSelectedCategories() &&
                            //             _formKey.currentState!.validate()) {
                            //           try {
                            //             await model
                            //                 .addPostFromDraft(existingPost);
                            //             Navigator.pop(
                            //               context,
                            //               ResultForDraftButton.addPostFromDraft,
                            //             );
                            //           } on Exception catch (e) {
                            //             await showExceptionDialog(context, e);
                            //           }

                            //           // Navigator.of(context).popUntil(
                            //           //   ModalRoute.withName('/'),
                            //           // );
                            //         } else {
                            //           await showRequiredInputConfirmDialog(
                            //               context);
                            //         }
                            //       },
                            //       style: OutlinedButton.styleFrom(
                            //         backgroundColor: kDarkPink,
                            //         padding: const EdgeInsets.symmetric(
                            //             vertical: 12),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(16),
                            //         ),
                            //         side: const BorderSide(color: kDarkPink),
                            //       ),
                            //       child: const Text(
                            //         '投稿する',
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 16,
                            //           // fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(height: 16),

                            //     /// 下書き保存ボタン
                            //     OutlinedButton(
                            //       onPressed: () async {
                            //         if (model.validateSelectedCategories() &&
                            //             _formKey.currentState!.validate()) {
                            //           try {
                            //             await model
                            //                 .updateDraftPost(existingPost);
                            //             const snackBar = SnackBar(
                            //               content: Text('下書きに保存しました'),
                            //             );
                            //             ScaffoldMessenger.of(context)
                            //                 .showSnackBar(snackBar);
                            //             Navigator.pop(
                            //               context,
                            //               ResultForDraftButton.updateDraft,
                            //             );
                            //           } on Exception catch (e) {
                            //             await showExceptionDialog(context, e);
                            //           }
                            //           // Navigator.of(context).popUntil(
                            //           //   ModalRoute.withName('/'),
                            //           // );
                            //         } else {
                            //           await showRequiredInputConfirmDialog(
                            //               context);
                            //         }
                            //       },
                            //       style: OutlinedButton.styleFrom(
                            //         padding: const EdgeInsets.symmetric(
                            //             vertical: 12),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(16),
                            //         ),
                            //         side: const BorderSide(color: kDarkPink),
                            //       ),
                            //       child: const Text(
                            //         '下書きに保存する',
                            //         style: TextStyle(
                            //           color: kDarkPink,
                            //           fontSize: 16,
                            //           // fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
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

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    required this.chipName,
    required this.model,
    Key? key,
  }) : super(key: key);

  final String chipName;
  final UpdatePostModel model;

  @override
  Widget build(BuildContext context) {
    final isSelected = model.selectedCategories.contains(chipName);
    return FilterChip(
      label: Text(
        chipName,
        style: TextStyle(
          color: isSelected ? kDarkPink : Colors.grey[800],
        ),
      ),
      selected: isSelected == true,
      onSelected: (_) {
        model.toggleCategory(chipName);
        // isSelected
        //     ? model.selectedCategories.remove(chipName)
        //     : model.selectedCategories.add(chipName);
        // model.reload();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? kPink : Colors.grey[500]!),
      ),
      backgroundColor: Colors.grey[200],
      selectedColor: kLightPink,
      selectedShadowColor: kDarkPink,
      showCheckmark: false,
      pressElevation: 0,
    );
  }
}
