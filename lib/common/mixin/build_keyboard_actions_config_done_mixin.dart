import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
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

  KeyboardActionsItem _keyboardActionItems(FocusNode _focusNode) {
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
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: const Text(
          '完了',
          style: TextStyle(
            color: kDarkPink,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
