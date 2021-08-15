import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_card_menu_button/common_card_menu_button_model.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/presentation/update_post/update_post_page.dart';
import 'package:provider/provider.dart';

class CardMenuButton extends StatelessWidget {
  const CardMenuButton({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.more_horiz,
        color: kLightGrey,
      ),
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          // barrierColor: Colors.black.withOpacity(0.8),
          pageBuilder: (_, __, ___) {
            return SafeArea(
              child: Material(
                color: Colors.black.withOpacity(.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// メニューの中身
                    CardMenuItemButtonList(post: post),
                    const SizedBox(height: 8),

                    /// キャンセルボタン
                    const CardMenuCancelButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// メニューで行えること一覧
class CardMenuItemButtonList extends StatelessWidget {
  const CardMenuItemButtonList({
    required this.post,
    Key? key,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CardMenuButtonModel>(
      create: (context) => CardMenuButtonModel(),
      child: Container(
        width: MediaQuery.of(context).size.width * .9,
        height: 104,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CardMenuItemButton(
              iconData: Icons.report_outlined,
              iconName: '通報',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            if (post.isMe() == true)
              CardMenuItemButton(
                iconData: Icons.edit_outlined,
                iconName: '編集',
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return UpdatePostPage(
                        existingPost: post,
                      );
                    }),
                  );
                },
              ),
            Consumer<CardMenuButtonModel>(
              builder: (context, model, child) {
                return CardMenuItemButton(
                  iconData: post.isBookmarked ? Icons.star : Icons.star_outline,
                  iconColor: post.isBookmarked ? Colors.yellow : null,
                  iconName: 'ブックマーク',
                  onPressed: () async {
                    if (post.isBookmarked) {
                      model.turnOffStar(post);
                      await model.deleteBookmarkedPost(post);
                      Navigator.pop(context);
                    } else {
                      model.turnOnStar(post);
                      await model.addBookmarkedPost(post);
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// メニューの各ボタン
class CardMenuItemButton extends StatelessWidget {
  const CardMenuItemButton({
    required this.iconData,
    required this.iconName,
    required this.onPressed,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  final IconData iconData;
  final String iconName;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kUltraLightGrey,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            IconButton(
              icon: Icon(
                iconData,
                size: 32,
                color: iconColor ?? kDarkGrey,
              ),
              onPressed: onPressed,
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          iconName,
          style: const TextStyle(
            color: kGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// メニューを閉じるボタン
class CardMenuCancelButton extends StatelessWidget {
  const CardMenuCancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * .9,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'キャンセル',
            style: TextStyle(
              color: kDarkGrey,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
