import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';

mixin ShowConfirmDialogMixin {
  Future<void> showDiscardConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('変更内容の破棄'),
          content: const Text('変更した内容が破棄されますがよろしいですか？'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'キャンセル',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                '破棄',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop(ValueFromShowConfirmDialog.discard);
                // Navigator.of(context).popUntil(
                //   ModalRoute.withName('/'),
                // );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showLogoutConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Text('ログアウトしてもよろしいですか？'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'キャンセル',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'ログアウト',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop(ValueFromShowConfirmDialog.logout);
                // Navigator.of(context).popUntil(
                //   ModalRoute.withName('/'),
                // );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showRequiredInputConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Text('必須項目を入力してください。'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
