import 'package:flutter/material.dart';

const Color kDarkPink = Color(0xFFDC5A6E);
const Color kPink = Color(0xFFf3d4d8);
const Color kLightPink = Color(0xFFFFF7FA);
const Color kLightGrey = Colors.black54;

const String kPleaseSelect = '選択してください';
const String kDoNotSelect = '選択しない';

const Map<String, String> kEmotionIcons = {
  'うれしい': 'images/anpanman.png',
  'かなしい': 'images/anpanman.png',
  'つらい': 'images/anpanman.png',
  '相談': 'images/anpanman.png',
  '疑問': 'images/anpanman.png',
  '提案': 'images/anpanman.png',
  '悩み': 'images/anpanman.png',
  'エール': 'images/anpanman.png',
  '呼びかけ': 'images/anpanman.png',
};

const List<String> kEmotionList = [
  kPleaseSelect,
  'うれしい',
  'かなしい',
  'つらい',
  '相談',
  '疑問',
  '提案',
  '悩み',
  'エール',
  '呼びかけ',
];

const List<String> kCategoryList = [
  // kPleaseSelect,
  'ASD',
  // 'ASD(自閉症スペクトラム障害)',
  'ADHD',
  // 'ADHD(注意欠如・多動性障害)',
  'SLD',
  // 'SLD(限局性学習障害)',
  '大人の発達障害',
  '発達障害グレーゾーン',
  '知的障害',
  '不安障害',
  'パニック障害',
  'チック症',
  '吃音',
  'うつ病',
  '双極性障害',
  // '躁うつ病(双極性障害)',
  '適応障害',
  // '新型うつ病(適応障害)',
  '睡眠障害',
  '強迫性障害',
  '統合失調症',
  '依存症',
  'パーソナリティ障害',
  'PTSD',
  // 'PTSD(心的外傷後ストレス障害)',
  '愛着障害',
  'いじめ',
  '不登校',
  'ひきこもり',
  'コミュニケーション',
  '療育',
  '薬物療法',
  '障害者手帳',
  '障害福祉サービス',
  'カサンドラ症候群',
  '就職',
  '職業選択',
  'ライフハック',
  'その他',
];

const List<String> kPositionList = [
  kPleaseSelect,
  '当事者',
  '妻',
  '夫',
  '母親',
  '父親',
  '子ども',
  '親戚',
  '友達',
  '同僚',
  '学生',
  'その他',
  kDoNotSelect,
];

const List<String> kGenderList = [
  kPleaseSelect,
  '男性',
  '女性',
  'その他',
  kDoNotSelect,
];

const List<String> kAgeList = [
  kPleaseSelect,
  '19歳以下',
  '20代',
  '30代',
  '40代',
  '50代',
  '60代',
  '70代以上',
  kDoNotSelect,
];

const List<String> kAreaList = [
  kPleaseSelect,
  '北海道',
  '青森県',
  '岩手県',
  '宮城県',
  '秋田県',
  '山形県',
  '福島県',
  '茨城県',
  '栃木県',
  '群馬県',
  '埼玉県',
  '千葉県',
  '東京都',
  '神奈川県',
  '新潟県',
  '富山県',
  '石川県',
  '福井県',
  '山梨県',
  '長野県',
  '岐阜県',
  '静岡県',
  '愛知県',
  '三重県',
  '滋賀県',
  '京都府',
  '大阪府',
  '兵庫県',
  '奈良県',
  '和歌山県',
  '鳥取県',
  '島根県',
  '岡山県',
  '広島県',
  '山口県',
  '徳島県',
  '香川県',
  '愛媛県',
  '高知県',
  '福岡県',
  '佐賀県',
  '長崎県',
  '熊本県',
  '大分県',
  '宮崎県',
  '鹿児島県',
  '沖縄県',
  'その他',
  kDoNotSelect,
];

const kTitleTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.title),
  labelText: 'タイトル',
  hintText: '大人の発達障害とグレーゾーンについて',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
  counterText: '50字以内でご記入ください',
  counterStyle: TextStyle(color: kLightGrey),
  // counterText: isPostExisting
  //     ? '${existingPost!.title.length} 字'
  //     : '${model.titleValue.length} 字',
);

const kContentTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.text_fields),
  labelText: '投稿の内容',
  hintText:
      '自分が大人の発達障害ではないかと疑っているのですが、特徴の濃淡がはっきりせずグレーゾーンに思われるため、確信が持てないのと、親へどう話せばいいかわからず、診断に踏み切れていません。',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
  counterText: '1000字以内でご記入ください',
  counterStyle: TextStyle(color: kLightGrey),
  // counterText: isPostExisting
  //     ? '${existingPost!.textBody.length} 字'
  //     : '${model.contentValue.length} 字',
);

const kNicknameTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.face),
  labelText: 'ニックネーム',
  hintText: 'ムセンシティ部',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
  counterText: '10字以内でご記入ください',
  counterStyle: TextStyle(color: kLightGrey),
  // counterText: isPostExisting
  //     ? '${existingPost!.nickname.length} 字'
  //     : '${model.nicknameValue.length} 字',
);

const kEmotionDropdownButtonFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.mood),
  labelText: 'あなたの気持ち(アイコン)',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
);

const kPositionDropdownButtonFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'あなたの立場',
  // helperText: '必須',
  // helperStyle: TextStyle(color: kDarkPink),
  prefixIcon: Icon(Icons.group),
);

const kGenderDropdownButtonFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'あなたの性別',
  prefixIcon: Icon(Icons.lens_outlined),
);

const kAgeDropdownButtonFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'あなたの年齢',
  prefixIcon: Icon(Icons.date_range),
);

const kAreaDropdownButtonFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'お住まいの地域',
  prefixIcon: Icon(Icons.place_outlined),
);

const kAppBarTextStyle = TextStyle(
  fontSize: 17.0,
  fontWeight: FontWeight.bold,
);
