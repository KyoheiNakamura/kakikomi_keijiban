import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/add_post/add_post_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/post.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatelessWidget {
  AddPostPage({this.existingPost});

  final Post? existingPost;
  final _formKey = GlobalKey<FormState>();

  final _contentFocusNode = FocusNode();
  final _nicknameFocusNode = FocusNode();
  final _emotionFocusNode = FocusNode();
  final _positionFocusNode = FocusNode();
  final _genderFocusNode = FocusNode();
  final _ageFocusNode = FocusNode();
  final _postButtonFocusNode = FocusNode();
  final _areaFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final bool isPostExisting = existingPost != null;
    return ChangeNotifierProvider<AddPostModel>(
      create: (context) => AddPostModel(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 30,
            ),
            onPressed: () {},
          ),
          title: Text(
            '発達障害困りごと掲示板',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                size: 30,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Consumer<AddPostModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              // reverse: true,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32.0, horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // title
                      TextFormField(
                        initialValue: isPostExisting
                            ? model.titleValue = existingPost!.title
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'タイトルを入力してください';
                          } else if (value.length > 50) {
                            return '50字以内でご記入ください';
                          }
                          return null;
                        },
                        // maxLength: 50,
                        maxLines: null,
                        // autofocus: true,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_contentFocusNode);
                        },
                        onChanged: (newValue) {
                          model.getTitleValue(newValue);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                          labelText: 'タイトル',
                          hintText: '大人の発達障害とグレーゾーンについて',
                          helperText: '必須 50字以内でご記入ください',
                          // helperStyle: TextStyle(color: kDarkPink),
                          counterText: isPostExisting
                              ? '${existingPost!.title.length} 字'
                              : '${model.titleValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // content
                      TextFormField(
                        initialValue: isPostExisting
                            ? model.contentValue = existingPost!.textBody
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '内容を入力してください';
                          } else if (value.length > 1000) {
                            return '1000字以内でご記入ください';
                          }
                          return null;
                        },
                        // maxLength: 1000,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        focusNode: _contentFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_nicknameFocusNode);
                        },
                        onChanged: (newValue) {
                          model.getContentValue(newValue);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.text_fields),
                          labelText: '内容',
                          hintText:
                              '自分が大人の発達障害ではないかと疑っているのですが、特徴の濃淡がはっきりせずグレーゾーンに思われるため、確信が持てないのと、親へどう話せばいいかわからず、診断に踏み切れていません。',
                          helperText: '必須 1000字以内でご記入ください',
                          // helperStyle: TextStyle(color: kDarkPink),
                          counterText: isPostExisting
                              ? '${existingPost!.textBody.length} 字'
                              : '${model.contentValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // nickname
                      TextFormField(
                        initialValue: isPostExisting
                            ? model.nicknameValue = existingPost!.nickname
                            : null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ニックネームを入力してください';
                          } else if (value.length > 10) {
                            return '10字以内でご記入ください';
                          }
                          return null;
                        },
                        focusNode: _nicknameFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_emotionFocusNode);
                        },
                        onChanged: (newValue) {
                          model.getNicknameValue(newValue);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.face),
                          labelText: 'ニックネーム',
                          hintText: 'ムセンシティ部',
                          helperText: '必須 10字以内でご記入ください',
                          // helperStyle: TextStyle(color: kDarkPink),
                          counterText: isPostExisting
                              ? '${existingPost!.nickname.length} 字'
                              : '${model.nicknameValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // emotion
                      DropdownButtonFormField(
                        validator: (value) {
                          if (value == pleaseSelect) {
                            return 'あなたの気持ちを選択してください';
                          }
                          return null;
                        },
                        focusNode: _emotionFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting
                            ? model.emotionDropdownValue = existingPost!.emotion
                            : model.emotionDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.mood),
                          labelText: 'あなたの気持ち',
                          helperText: '必須',
                          // helperStyle: TextStyle(color: kDarkPink),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectEmotionDropdownValue(selectedValue);
                          FocusScope.of(context)
                              .requestFocus(_positionFocusNode);
                        },
                        items: emotionList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // position
                      DropdownButtonFormField(
                        validator: (value) {
                          if (value == pleaseSelect) {
                            return 'あなたの立場を選択してください';
                          }
                          return null;
                        },
                        focusNode: _positionFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting
                            ? model.positionDropdownValue =
                                existingPost!.position
                            : model.positionDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'あなたの立場',
                          helperText: '必須',
                          prefixIcon: Icon(Icons.group),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectPositionDropdownValue(selectedValue);
                          FocusScope.of(context).requestFocus(_genderFocusNode);
                        },
                        items: positionList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // gender
                      DropdownButtonFormField(
                        focusNode: _genderFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting && existingPost!.gender.isNotEmpty
                            ? model.genderDropdownValue = existingPost!.gender
                            : model.genderDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'あなたの性別',
                          prefixIcon: Icon(Icons.lens_outlined),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectGenderDropdownValue(selectedValue);
                          FocusScope.of(context).requestFocus(_ageFocusNode);
                        },
                        items: <String>[pleaseSelect, '男性', '女性', doNotSelect]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // age
                      DropdownButtonFormField(
                        focusNode: _ageFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting && existingPost!.age.isNotEmpty
                            ? model.ageDropdownValue = existingPost!.age
                            : model.ageDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'あなたの年齢',
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectAgeDropdownValue(selectedValue);
                          FocusScope.of(context).requestFocus(_areaFocusNode);
                        },
                        items: ageList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      // area
                      DropdownButtonFormField(
                        focusNode: _areaFocusNode,
                        focusColor: Colors.pink[50],
                        value: isPostExisting && existingPost!.area.isNotEmpty
                            ? model.areaDropdownValue = existingPost!.area
                            : model.areaDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          // color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'お住まいの地域',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectAreaDropdownValue(selectedValue);
                          FocusScope.of(context)
                              .requestFocus(_postButtonFocusNode);
                        },
                        items: areaList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      // 投稿送信ボタン
                      OutlinedButton(
                        focusNode: _postButtonFocusNode,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            isPostExisting
                                ? await model.updatePost(existingPost!)
                                : await model.addPost();
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          isPostExisting ? '更新する' : '投稿する',
                          style: TextStyle(
                            color: kDarkPink,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(15),
                          // ),
                          side: BorderSide(color: kDarkPink),
                        ),
                      )
                    ],
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
