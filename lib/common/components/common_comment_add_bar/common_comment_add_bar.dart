import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_comment_add_bar/common_comment_add_bar_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/entity/reply.dart';
import 'package:provider/provider.dart';

/// コメントを入力して送信するためのバー
class CommonCommentAddBar extends StatelessWidget {
  const CommonCommentAddBar({
    this.post,
    this.reply,
    Key? key,
  })  : assert(
          post != null || reply != null,
          'post または reply のどちらかが必要です！',
        ),
        assert(
          post == null || reply == null,
          'post と reply のどちらも指定することはできません！',
        ),
        super(key: key);

  final Post? post;
  final Reply? reply;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CommentAddBarModel>(
      create: (context) => CommentAddBarModel(post: post, reply: reply),
      child: Consumer<CommentAddBarModel>(
        builder: (context, model, child) {
          return Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: const BoxDecoration(
              color: kbackGroundGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const EmotionIconSelectButton(),
                Expanded(
                  child: TextField(
                    controller: model.commentTextController,
                    focusNode: model.focusNode,
                    textInputAction: TextInputAction.done,
                    onTap: model.onTapTextFild,
                    onChanged: model.validateComment,
                    minLines: 1,
                    maxLines: 4,
                    cursorColor: kDarkPink,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      isDense: true,
                      errorText: model.errorCommentText,
                      hintText: 'すてきなコメントを残そう！',
                      hintStyle: const TextStyle(color: kGrey),
                      fillColor: kbackGroundWhite,
                      filled: true,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                  onPressed: () async {
                    if (model.isSendButtonAvailable) {
                      await model.addReply(context);
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: model.isSendButtonAvailable ? kDarkPink : kGrey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 気持ちを選択するダイアログを表示するボタン
class EmotionIconSelectButton extends StatefulWidget {
  const EmotionIconSelectButton({
    Key? key,
  }) : super(key: key);

  @override
  _EmotionIconSelectButtonState createState() =>
      _EmotionIconSelectButtonState();
}

class _EmotionIconSelectButtonState extends State<EmotionIconSelectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !context.watch<CommentAddBarModel>().isEmotionSelected
        ? ScaleTransition(
            scale: animationController.drive(
              Tween<double>(
                begin: 1,
                end: 1.2,
              ).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: IconButton(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              onPressed: () async {
                final emotion = await _showEmotionSelectDialog(context);
                context.read<CommentAddBarModel>().validateEmotion(emotion);
              },
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: kDarkPink,
              ),
            ),
          )
        : IconButton(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            onPressed: () async {
              final emotion = await _showEmotionSelectDialog(context);
              context.read<CommentAddBarModel>().validateEmotion(emotion);
            },
            icon: context.watch<CommentAddBarModel>().emotionIcon != null
                ? Image.asset(emotinoImage(
                    context.read<CommentAddBarModel>().emotionIcon!,
                  ))
                : const Icon(
                    Icons.emoji_emotions_outlined,
                    color: kGrey,
                  ),
          );
  }

  Future<Emotion?> _showEmotionSelectDialog(BuildContext context) async {
    final selectedEmotion = await showGeneralDialog<Emotion?>(
      context: context,
      barrierDismissible: false,
      // barrierColor: Colors.black.withOpacity(0.8),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          child: Material(
            color: Colors.black.withOpacity(.6),
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * .1,
                horizontal: MediaQuery.of(context).size.width * .1,
              ),
              decoration: BoxDecoration(
                color: kbackGroundWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'あなたの気持ちを教えて！',
                          style: TextStyle(
                            color: kGrey,
                            fontSize: 15,
                          ),
                        ),
                        Flexible(
                          child: GridView.count(
                            physics: const BouncingScrollPhysics(),
                            crossAxisCount: 2,
                            children: List.generate(
                              Emotion.values.length,
                              (index) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop<Emotion>(
                                          context,
                                          Emotion.values[index],
                                        );
                                      },
                                      child: Image.asset(
                                        emotinoImage(
                                          Emotion.values[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return selectedEmotion;
  }
}
