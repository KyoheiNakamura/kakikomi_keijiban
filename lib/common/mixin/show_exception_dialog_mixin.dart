import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';

mixin ShowExceptionDialogMixin {
  Future<void> showExceptionDialog(
    BuildContext context,
    Exception e,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Text(e.formatToString()),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: kDarkPink),
              ),
            ),
          ],
        );
      },
    );
  }
}

extension ExceptionToString on Exception {
  String formatToString() {
    final errorMessage = toString();
    final exp = RegExp(r'Exception: ');
    return errorMessage.replaceAll(exp, '');
  }
}
