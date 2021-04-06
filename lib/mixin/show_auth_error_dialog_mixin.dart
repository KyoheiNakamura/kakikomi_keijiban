import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/constants.dart';

mixin ShowAuthErrorDialogMixin {
  Future<void> showAuthErrorDialog(
      BuildContext context, String errorMessage) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          // title: Text('認証エラー'),
          content: Text(errorMessage),
          contentPadding:
              EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 0),
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
