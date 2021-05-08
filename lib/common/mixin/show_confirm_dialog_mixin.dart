import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/common/enum.dart';

mixin ShowConfirmDialogMixin {
  Future<void> showDiscardConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text('変更内容の破棄'),
          content: Text('変更した内容が破棄されますがよろしいですか？'),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '破棄',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop(valueFromShowConfirmDialog.discard);
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
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Text('ログアウトしてもよろしいですか？'),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          actions: <Widget>[
            TextButton(
              child: Text(
                'キャンセル',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'ログアウト',
                style: TextStyle(color: kDarkPink),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop(valueFromShowConfirmDialog.logout);
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
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Text('必須項目を入力してください。'),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          actions: <Widget>[
            TextButton(
              child: Text(
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
