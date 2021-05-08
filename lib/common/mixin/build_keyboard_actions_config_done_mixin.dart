import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';

mixin KeyboardActionsConfigDoneMixin {
  KeyboardActionsConfig buildConfig(
      BuildContext context, FocusNode _focusNode) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: kLightPink,
      nextFocus: false,
      actions: [
        _keyboardActionItems(_focusNode),
      ],
    );
  }

  _keyboardActionItems(_focusNode) {
    return KeyboardActionsItem(
      focusNode: _focusNode,
      toolbarButtons: [
        (node) {
          return _customDoneButton(_focusNode);
        },
      ],
    );
  }

  Widget _customDoneButton(FocusNode _focusNode) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(left: 8.0, right: 16.0),
        child: Text(
          '完了',
          style: TextStyle(
            color: kDarkPink,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
