import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/add_post/add_post_model.dart';
import 'package:kakikomi_keijiban/constants.dart';
import 'package:kakikomi_keijiban/enum.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatelessWidget {
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
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'タイトルを入力してください';
                          } else if (value.length > 50) {
                            return '50字以内でご記入ください';
                          }
                          return null;
                        },
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
                          labelText: 'タイトル',
                          hintText: '大人の発達障害とグレーゾーンについて',
                          helperText: '50字以内でご記入ください',
                          counterText: '${model.titleValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '内容を入力してください';
                          } else if (value.length > 1000) {
                            return '1000字以内でご記入ください';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
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
                          labelText: '内容',
                          hintText:
                              '自分が大人の発達障害ではないかと疑っているのですが、特徴の濃淡がはっきりせずグレーゾーンに思われるため、確信が持てないのと、親へどう話せばいいかわからず、診断に踏み切れていません。',
                          helperText: '1000字以内でご記入ください',
                          counterText: '${model.contentValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      TextFormField(
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
                          labelText: 'ニックネーム',
                          hintText: 'センシティ部',
                          helperText: '10字以内でご記入ください',
                          counterText: '${model.nicknameValue.length} 字',
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      DropdownButtonFormField(
                        focusNode: _emotionFocusNode,
                        focusColor: Colors.pink[50],
                        value: model.emotionDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          labelText: 'あなたの気持ち',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectEmotionDropdownValue(selectedValue);
                          FocusScope.of(context)
                              .requestFocus(_positionFocusNode);
                        },
                        items: <String>[
                          '選択してください',
                          '相談',
                          '疑問',
                          '提案',
                          '悩み',
                          'エール',
                          'うれしい',
                          'かなしい',
                          'つらい',
                          '呼びかけ'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      DropdownButtonFormField(
                        focusNode: _positionFocusNode,
                        focusColor: Colors.pink[50],
                        value: model.positionDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          labelText: 'あなたの立場',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectPositionDropdownValue(selectedValue);
                          FocusScope.of(context).requestFocus(_genderFocusNode);
                        },
                        items: <String>[
                          '選択してください',
                          '当事者',
                          '配偶者',
                          '親',
                          '子ども',
                          '親戚',
                          '友達',
                          '同僚'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      DropdownButtonFormField(
                        focusNode: _genderFocusNode,
                        focusColor: Colors.pink[50],
                        value: model.genderDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          labelText: 'あなたの性別',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectGenderDropdownValue(selectedValue);
                          FocusScope.of(context).requestFocus(_ageFocusNode);
                        },
                        items: <String>['選択してください', '男性', '女性', '選択しない']
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
                      DropdownButtonFormField(
                        focusNode: _ageFocusNode,
                        focusColor: Colors.pink[50],
                        value: model.ageDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          labelText: 'あなたの年齢',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectAgeDropdownValue(selectedValue);
                          FocusScope.of(context).requestFocus(_areaFocusNode);
                        },
                        items: <String>[
                          '選択してください',
                          '19歳以下',
                          '20代',
                          '30代',
                          '40代',
                          '50代',
                          '60代',
                          '70代以上',
                          '選択しない'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      DropdownButtonFormField(
                        focusNode: _areaFocusNode,
                        focusColor: Colors.pink[50],
                        value: model.areaDropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: kDarkPink,
                        ),
                        iconSize: 24,
                        elevation: 1,
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        decoration: InputDecoration(
                          labelText: 'お住まいの地域',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? selectedValue) {
                          model.selectAreaDropdownValue(selectedValue);
                          FocusScope.of(context)
                              .requestFocus(_postButtonFocusNode);
                        },
                        items: <String>[
                          '選択してください',
                          '北海道',
                          '東京',
                          '広島',
                          '沖縄',
                          '選択しない'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      OutlinedButton(
                        focusNode: _postButtonFocusNode,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            model.addPost();
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          '投稿する',
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
