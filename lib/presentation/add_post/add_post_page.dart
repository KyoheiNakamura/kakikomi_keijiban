import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/build_keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_confirm_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/add_post/add_post_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatelessWidget
    with
        ShowConfirmDialogMixin,
        KeyboardActionsConfigDoneMixin,
        ShowExceptionDialogMixin {
  const AddPostPage();


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDiscardConfirmDialog(context);
        return true;
      },
      child: GestureDetector(
        onTap: () {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: ChangeNotifierProvider<AddPostModel>(
          create: (context) => AddPostModel(),
          child: Scaffold(
            appBar: commonAppBar(
              title: '新規投稿',
              action: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () async {
                    if (context
                            .read<AddPostModel>()
                            .validateSelectedCategories() &&
                        context
                            .read<AddPostModel>()
                            .formKey
                            .currentState!
                            .validate()) {
                      try {
                        await context.read<AddPostModel>().addDraftedPost();
                        const snackBar = SnackBar(
                          content: Text('下書きに保存しました'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pop(context);
                      } on String catch (e) {
                        await showExceptionDialog(
                          context,
                          e.toString(),
                        );
                      }
                    } else {
                      await showRequiredInputConfirmDialog(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    primary: kDarkPink,
                  ),
                  child: const Text(
                    '下書き保存',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            body: Consumer<AddPostModel>(
              builder: (context, model, child) {
                final user = AppModel.user;
                final isUserExisting = user != null;
                return LoadingSpinner(
                  isModalLoading: model.isLoading,
                  child: KeyboardActions(
                    config: buildConfig(context, model.focusNodeContent),
                    child: SingleChildScrollView(
                      child: Form(
                        key: model.formKey,
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

                              /// body
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: TextFormField(
                                  focusNode: model.focusNodeContent,
                                  controller: model.bodyController,
                                  validator: model.validateContentCallback,
                                  // maxLength: 1000,
                                  minLines: 5,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
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
                                  value: model.emotionDropdownValue,
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
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, bottom: 14),
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
                                padding: const EdgeInsets.only(
                                    left: 10, top: 8, right: 10, bottom: 32),
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
                                  value: isUserExisting
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
                                    model.positionDropdownValue =
                                        selectedValue!;
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
                                  value: isUserExisting
                                      ? model.genderDropdownValue = user!.gender
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
                                  value: isUserExisting
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
                                  value: isUserExisting
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

                              /// 投稿送信ボタン
                              OutlinedButton(
                                onPressed: () async {
                                  if (model.validateSelectedCategories() &&
                                      model.formKey.currentState!.validate()) {
                                    try {
                                      await model.addPost();
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
                                  '投稿する',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: kDarkPink,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: const BorderSide(color: kDarkPink),
                                ),
                              ),

                              const SizedBox(height: 16),

                              /// 下書き保存ボタン
                              OutlinedButton(
                                onPressed: () async {
                                  if (model.validateSelectedCategories() &&
                                      model.formKey.currentState!.validate()) {
                                    try {
                                      await model.addDraftedPost();
                                      const snackBar = SnackBar(
                                        content: Text('下書きに保存しました'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
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
                                  '下書きに保存する',
                                  style: TextStyle(
                                    color: kDarkPink,
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: const BorderSide(color: kDarkPink),
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
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    required this.chipName,
    required this.model,
  });

  final String chipName;
  final AddPostModel model;

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
        isSelected
            ? model.selectedCategories.remove(chipName)
            : model.selectedCategories.add(chipName);
        model.reload();
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

// Category チップ一つ選択
// Container(
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.grey[500]!),
//     borderRadius: BorderRadius.circular(5),
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(14),
//             child: const Icon(
//               Icons.category_outlined,
//               color: kLightGrey,
//             ),
//           ),
//           Text(
//             'カテゴリー',
//             style: TextStyle(
//               color: Colors.grey[700],
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//       Padding(
//         padding: const EdgeInsets.only(
//             left: 16, right: 16, bottom: 14),
//         child: Wrap(
//           spacing: 16,
//           runSpacing: 2,
//           // alignment: WrapAlignment.center,
//           children: kCategoryList.map<Widget>((item) {
//             return ChoiceChip(
//               label: Text(item),
//               selected: model.selectedCategory == item,
//               onSelected: (selected) {
//                 model.selectedCategory = item;
//                 model.reload();
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     ],
//   ),
// ),
// Padding(
//   padding:
//       EdgeInsets.only(left: 12, top: 8, right: 12),
//   child: Text(
//     '必須',
//     style: TextStyle(
//       fontSize: 12,
//       color: kDarkPink,
//     ),
//   ),
// ),
// const SizedBox(
//   height: 32,
// ),
