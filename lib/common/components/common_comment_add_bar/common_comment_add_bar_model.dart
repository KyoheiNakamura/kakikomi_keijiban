import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/app_model.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/firebase_util.dart';
import 'package:kakikomi_keijiban/common/text_process.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';

class CommentAddBarModel extends ChangeNotifier {
  CommentAddBarModel({
    this.post,
    this.reply,
  })  : assert(
          post != null || reply != null,
          'post または reply のどちらかが必要です！',
        ),
        assert(
          post == null || reply == null,
          'post と reply のどちらも指定することはできません！',
        );

  final Post? post;
  final Reply? reply;

  final TextEditingController commentTextController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  String? errorCommentText;
  bool isValidComment = false;
  bool isEmotionSelected = true;
  Emotion? emotionIcon;
  bool isSendButtonAvailable = false;

  /// コメントを追加する
  Future<void> addReply(BuildContext context) async {
    if (post != null) {
      await addReplyToPost(context);
    }
    if (reply != null) {
      await addReplyToReply(context);
    }
  }

  /// 投稿に対してのコメントを追加する
  Future<void> addReplyToPost(BuildContext context) async {
    if (post == null) {
      return;
    }

    // ignore: unawaited_futures
    CommonLoadingDialog.instance.showDialog(context);

    final _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(post!.userId);
    final postRef = userRef.collection('posts').doc(post!.id);
    final replyRef = postRef.collection('replies').doc();

    _batch
      ..set(replyRef, <String, dynamic>{
        'id': replyRef.id,
        'userId': post!.userId,
        'postId': post!.id,
        'replierId': auth.currentUser!.uid,
        'body': removeUnnecessaryBlankLines(commentTextController.text),
        'nickname': AppModel.user?.nickname ?? '匿名',
        'emotion': emotionIcon != null ? emotinoDescription(emotionIcon!) : '',
        'position': '',
        'gender': '',
        'age': '',
        'area': '',
        'replyCount': 0,
        'empathyCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..update(postRef, <String, dynamic>{
        'replyCount': FieldValue.increment(1),
        'isReplyExisting': true,
      });

    try {
      await _batch.commit();
      _succeedToAddReply();
    } on Exception catch (e) {
      print('addReplyToPostのバッチ処理中のエラーです');
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      CommonLoadingDialog.instance.closeDialog();
    }
  }

  /// コメントに対してのコメントを追加する
  Future<void> addReplyToReply(BuildContext context) async {
    if (reply == null) {
      return;
    }

    // ignore: unawaited_futures
    CommonLoadingDialog.instance.showDialog(context);

    final _batch = firestore.batch();

    final userRef = firestore.collection('users').doc(reply!.userId);
    final postRef = userRef.collection('posts').doc(reply!.postId);
    final replyRef = postRef.collection('replies').doc(reply!.id);
    final replyToReplyRef = replyRef.collection('repliesToReply').doc();

    _batch
      ..set(replyToReplyRef, <String, dynamic>{
        'id': replyToReplyRef.id,
        'userId': reply!.userId,
        'postId': reply!.postId,
        'replyId': reply!.id,
        'replierId': auth.currentUser!.uid,
        'body': removeUnnecessaryBlankLines(commentTextController.text),
        'nickname': AppModel.user?.nickname ?? '匿名',
        'emotion': emotionIcon != null ? emotinoDescription(emotionIcon!) : '',
        'position': '',
        'gender': '',
        'age': '',
        'area': '',
        'empathyCount': 0,
        'createdAt': serverTimestamp(),
        'updatedAt': serverTimestamp(),
      })
      ..update(postRef, <String, FieldValue>{
        'replyCount': FieldValue.increment(1),
      })
      ..update(replyRef, <String, FieldValue>{
        'replyCount': FieldValue.increment(1),
      });
    // TODO(Kyohei-Nakamura): eventBusを使って、PostCardの返信数も更新する

    try {
      await _batch.commit();
      _succeedToAddReply();
    } on Exception catch (e) {
      print('addReplyToReplyのバッチ処理中のエラーです');
      print(e.toString());
      throw Exception('エラーが発生しました。\nもう一度お試し下さい。');
    } finally {
      CommonLoadingDialog.instance.closeDialog();
    }
  }

  /// コメントの送信が成功した後に行うの処理
  void _succeedToAddReply() {
    commentTextController.clear();
    focusNode.unfocus();
    isValidComment = false;
    isEmotionSelected = true;
    emotionIcon = null;
    isSendButtonAvailable = false;
    notifyListeners();
  }

  void onTapTextFild() {
    if (emotionIcon == null) {
      isEmotionSelected = false;
      notifyListeners();
    }
  }

  /// 気持ちのバリデーション
  void validateEmotion(Emotion? emotion) {
    if (emotionIcon == null && emotion == null) {
      isEmotionSelected = false;
    } else if (emotion != null) {
      emotionIcon = emotion;
      isEmotionSelected = true;
    }
    notifyListeners();
    _validateSendButton();
  }

  /// コメントのバリデーション
  void validateComment(String value) {
    if (value.isEmpty || value.trim() == '') {
      isValidComment = false;
    } else if (value.length > 1500) {
      errorCommentText = '1500字以内でご記入ください';
      isValidComment = false;
    } else {
      errorCommentText = null;
      isValidComment = true;
    }
    notifyListeners();
    _validateSendButton();
  }

  /// 送信ボタンを押せるかのバリデーション
  void _validateSendButton() {
    if (isValidComment && emotionIcon != null) {
      isSendButtonAvailable = true;
    } else {
      isSendButtonAvailable = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    commentTextController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
