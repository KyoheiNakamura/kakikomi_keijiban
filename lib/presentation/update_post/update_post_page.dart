import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/domain/user_profile.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:keyboard_actions/keyboard_actions_item.dart';
import 'package:provider/provider.dart';

class UpdatePostPage extends StatelessWidget {
  UpdatePostPage(this.existingPost, {this.userProfile});

  final Post existingPost;
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
    return ChangeNotifierProvider<UpdatePostModel>(
      create: (context) => UpdatePostModel(),
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
        body: Consumer<UpdatePostModel>(
          builder: (context, model, child) {
            if (model.selectedCategories.isEmpty) {
              model.selectedCategories.addAll(existingPost.categories);
            }

            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: KeyboardActions(
                config: _buildConfig(context),
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
                          /// title
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: TextFormField(
                              initialValue: model.titleValue =
                                  existingPost.title,
                              validator: model.validateTitleCallback,
                              onChanged: (newValue) {
                                model.titleValue = newValue;
                              },
                              decoration: kTitleTextFormFieldDecoration,
                            ),
                          ),

                          /// content
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: TextFormField(
                              focusNode: _focusNodeContent,
                              initialValue: model.bodyValue = existingPost.body,
                              validator: model.validateContentCallback,
                              // maxLength: 1000,
                              minLines: 3,
                              maxLines: null,
                              // keyboardType: TextInputType.multiline,
                              onChanged: (newValue) {
                                model.bodyValue = newValue;
                              },
                              decoration: kContentTextFormFieldDecoration,
                            ),
                          ),

                          /// nickname
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: TextFormField(
                              initialValue: model.nicknameValue =
                                  existingPost.nickname,
                              validator: model.validateNicknameCallback,
                              onChanged: (newValue) {
                                model.nicknameValue = newValue;
                              },
                              decoration: kNicknameTextFormFieldDecoration,
                            ),
                          ),

                          /// emotion
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: DropdownButtonFormField(
                              validator: model.validateEmotionCallback,
                              value: model.emotionDropdownValue =
                                  existingPost.emotion,
                              icon: Icon(Icons.arrow_downward),
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

                          /// position
                          // Todo positionを複数選択できるようにしよう
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: DropdownButtonFormField(
                              validator: model.validatePositionCallback,
                              value: existingPost.position.isNotEmpty
                                  ? model.positionDropdownValue =
                                      existingPost.position
                                  : isUserProfileNotAnonymous
                                      ? model.positionDropdownValue =
                                          userProfile!.position
                                      : model.positionDropdownValue,
                              icon: Icon(Icons.arrow_downward),
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
                                      padding: const EdgeInsets.all(14.0),
                                      child: Icon(
                                        Icons.category_outlined,
                                        color: model.isCategoriesValid
                                            ? kLightGrey
                                            : kDarkPink,
                                      ),
                                    ),
                                    Text(
                                      'カテゴリー',
                                      style: TextStyle(
                                        color: model.isCategoriesValid
                                            ? Colors.grey[700]
                                            : kDarkPink,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 16.0, right: 16.0, bottom: 14.0),
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 2.0,
                                    // alignment: WrapAlignment.center,
                                    children: kCategoryList.map<Widget>((item) {
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
                            padding: EdgeInsets.only(
                                left: 10.0,
                                top: 8.0,
                                right: 10.0,
                                bottom: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  model.isCategoriesValid
                                      ? '必須'
                                      : 'カテゴリーを選択してください',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: kDarkPink,
                                  ),
                                ),
                                Text(
                                  '1つ以上選択してください',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: kLightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// gender
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: DropdownButtonFormField(
                              value: existingPost.gender.isNotEmpty
                                  ? model.genderDropdownValue =
                                      existingPost.gender
                                  : isUserProfileNotAnonymous
                                      ? model.genderDropdownValue =
                                          userProfile!.gender
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
                              value: existingPost.age.isNotEmpty
                                  ? model.ageDropdownValue = existingPost.age
                                  : isUserProfileNotAnonymous
                                      ? model.ageDropdownValue =
                                          userProfile!.age
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
                              value: existingPost.area.isNotEmpty
                                  ? model.areaDropdownValue = existingPost.area
                                  : isUserProfileNotAnonymous
                                      ? model.areaDropdownValue =
                                          userProfile!.area
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
                              if (model.validateSelectedCategories() &&
                                  _formKey.currentState!.validate()) {
                                model.startLoading();
                                await model.updatePost(existingPost);
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

class FilterChipWidget extends StatelessWidget {
  FilterChipWidget({required this.chipName, required this.model});

  final String chipName;
  final UpdatePostModel model;

  @override
  Widget build(BuildContext context) {
    bool isSelected = model.selectedCategories.contains(chipName);
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
