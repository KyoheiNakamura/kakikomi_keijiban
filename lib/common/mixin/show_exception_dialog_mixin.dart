import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

mixin ShowExceptionDialogMixin {
  Future<void> showExceptionDialog(BuildContext context, String errorMessage) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(errorMessage),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
