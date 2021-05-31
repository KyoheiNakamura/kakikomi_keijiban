import 'package:flutter/material.dart';

const Color kDeepDarkPink = Color(0xFFa54352);
const Color kDarkPink = Color(0xFFDC5A6E);
const Color kPink = Color(0xFFf3d4d8);
const Color kLightPink = Color(0xFFFCF0F5);
const Color kUltraLightPink = Color(0xFFFFF7FA);
const Color kDarkGrey = Color(0xFF646464);
const Color kGrey = Color(0xFFa0a0a0);
const Color kLightGrey = Colors.grey;
const Color kUltraLightGrey = Color(0xFFe0e0e0);

const String kOnBoardingDoneKey = 'onBoardingDone';

const List<Map<String, String>> kOnBoardingData = [
  {
    'text': '発達障害お悩み掲示板（仮）は発達障害をテーマに扱う掲示板アプリです。',
    'image': 'lib/assets/images/anpanman_charactors.jpeg',
  },
  {
    'text': '当事者の方はもちろん、ご家族、友人の方などもお気軽にご利用ください。',
    'image': 'lib/assets/images/anpanman_charactors.jpeg',
  },
  {
    'text': 'ああああああああああああああああああああああああああああああああ',
    'image': 'lib/assets/images/anpanman_charactors.jpeg',
  },
];

const List<String> kInitialpushNoticesSetting = [
  'replyToMyPost',
  // 'replyToMyReply',
];

// const String kAllPostsTab = '新着の投稿';
// const String kMyPostsTab = '自分の投稿';
// const String kBookmarkedPostsTab = 'ブックマーク';
//
// const List<String> kTabs = <String>[
//   kAllPostsTab,
//   kMyPostsTab,
//   kBookmarkedPostsTab
// ];

const String kPleaseSelect = '選択してください';
const String kDoNotSelect = '選択しない';

const Map<String, String> kEmotionIcons = {
  'うれしい': 'lib/assets/images/anpanman_charactors_1.png',
  'かなしい': 'lib/assets/images/anpanman_charactors_2.png',
  'いかり': 'lib/assets/images/anpanman_charactors_3.png',
  '相談': 'lib/assets/images/anpanman_charactors_4.png',
  '疑問': 'lib/assets/images/anpanman_charactors_5.png',
  '提案': 'lib/assets/images/anpanman_charactors_6.png',
  '悩み': 'lib/assets/images/anpanman_charactors_7.png',
  'エール': 'lib/assets/images/anpanman_charactors_8.png',
  '呼びかけ': 'lib/assets/images/anpanman_charactors_9.png',
};

/// kEmotionListを変更したら、↑のkEmotionIconsにも値を追加する！！
const List<String> kEmotionList = [
  kPleaseSelect,
  'うれしい',
  // '希望',
  'かなしい',
  // 'つらい',
  'いかり',
  // '落ち込み',
  '相談',
  '疑問',
  // '質問',
  '提案',
  '悩み',
  '愚痴',
  'エール',
  '呼びかけ',
];

const List<String> kCategoryList = [
  // kPleaseSelect,
  'ASD',
  // 'ASD(自閉症スペクトラム障害)',
  'ADHD',
  // 'ADHD(注意欠如・多動性障害)',
  'LD',
  // 'SLD(限局性学習障害)',
  '大人の発達障害',
  '発達障害グレーゾーン',
  'アスペルガー',
  'カサンドラ',
  '広汎性発達障害',
  '知的障害',
  '不安障害',
  'パニック障害',
  // 'チック症',
  // '吃音',
  'うつ病',
  '双極性障害',
  // '躁うつ病(双極性障害)',
  '適応障害',
  // '新型うつ病(適応障害)',
  '睡眠障害',
  '強迫性障害',
  '統合失調症',
  '依存症',
  '過集中',
  'パーソナリティ障害',
  'PTSD',
  '感覚過敏',
  'HSP',
  'LGBT',
  // 'PTSD(心的外傷後ストレス障害)',
  '愛着障害',
  'いじめ',
  '不登校',
  'ひきこもり',
  '対人関係',
  'コミュニケーション',
  '障害者手帳',
  '福祉サービス',
  '仕事',
  '就職',
  '転職',
  '休職',
  '退職',
  '職業選択',
  '恋愛',
  '家族',
  '育児',
  '療育',
  '薬物療法',
  '病院',
  'カウンセラー',
  'ライフハック',
  'イベント',
  'パワハラ',
  'その他のカテゴリー',
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
  'その他の立場',
  kDoNotSelect,
];

const List<String> kGenderList = [
  kPleaseSelect,
  '男性',
  '女性',
  'その他の性別',
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
  '海外',
  kDoNotSelect,
];

const List<String> kContactList = [
  kPleaseSelect,
  '不具合の報告',
  '追加・改善して欲しい機能がある',
  'その他',
];

const kTitleTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.title),
  labelText: 'タイトル',
  hintText: '衝動買いをして後悔しての繰り返しです',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
  counterText: '50字以内でご記入ください',
  counterStyle: TextStyle(color: kGrey),
  // counterText: isPostExisting
  //     ? '${existingPost!.title.length} 字'
  //     : '${model.titleValue.length} 字',
);

const kContentTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.text_fields),
  labelText: '投稿の内容',
  hintText: '''
自閉症スペクトラムの人は自分の所持金のことを考えないで衝動買いをしてしまうと発達障害について説明している本に書いてありました。あるお子様向けのあるキャラクターが好きなのですが、収入が障害年金しかないのにそのキャラクターのグッズに1万円くらい使ってしまいました。好きな歌手がいるのでその歌手のCDやDVDは定価で買うのが当たり前になっているし、その歌手がSNSに写真を載せた商品まで買ってしまいました。貯金通帳を見て「何でこんなに無駄遣いしたんだろう」と後悔しています。でも買い物はどうしてもやめられません。''',
  hintMaxLines: 5,
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
  counterText: '1500字以内でご記入ください',
  counterStyle: TextStyle(color: kGrey),
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
  counterStyle: TextStyle(color: kGrey),
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
  prefixIcon: Icon(Icons.group),
  labelText: 'あなたの立場',
  // helperText: '必須',
  // helperStyle: TextStyle(color: kDarkPink),
);

const kPositionDropdownButtonFormFieldDecorationForReply = InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'あなたの立場',
  helperStyle: TextStyle(color: kDarkPink),
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

const kContactDropdownButtonFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.category_outlined),
  labelText: 'お問い合わせのカテゴリー',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
);

const kContactEmailTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.email),
  labelText: 'メールアドレス',
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
);

const kContactContentTextFormFieldDecoration = InputDecoration(
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.text_fields),
  labelText: 'お問い合わせの内容',
  hintText: '〇〇ができる機能を追加して欲しいです。\n\n具体的には、〇〇のときに〇〇なので、〇〇ができると良いと思います。',
  hintMaxLines: 5,
  helperText: '必須',
  helperStyle: TextStyle(color: kDarkPink),
  counterText: '500字以内でご記入ください',
  counterStyle: TextStyle(color: kGrey),
  // counterText: isPostExisting
  //     ? '${existingPost!.textBody.length} 字'
  //     : '${model.contentValue.length} 字',
);

const kAppBarTextStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
);

const kDropdownButtonFormFieldTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 15,
);

const kValidEmailRegularExpression =
    r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$";
// r"[^\s]+@[^\s]+";

const kValidPasswordRegularExpression = r'^([a-zA-Z0-9!-/:-@¥[-`{-~]{8,})$';
