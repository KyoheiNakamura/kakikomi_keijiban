import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/build_keyboard_actions_config_done_mixin.dart';
import 'package:kakikomi_keijiban/common/mixin/show_exception_dialog_mixin.dart';
import 'package:kakikomi_keijiban/presentation/contact/contact_model.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatelessWidget
    with ShowExceptionDialogMixin, KeyboardActionsConfigDoneMixin {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNodeContent = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactModel>(
      create: (context) => ContactModel(),
      child: WillPopScope(
        onWillPop: () {
          Navigator.of(context).popUntil(
            ModalRoute.withName('/'),
          );
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            title: const Text('お問い合わせ'),
          ),
          body: Consumer<ContactModel>(
            builder: (context, model, child) {
              return LoadingSpinner(
                isModalLoading: model.isLoading,
                child: KeyboardActions(
                  config: buildConfig(context, _focusNodeContent),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// email
                            TextFormField(
                              initialValue: model.email,
                              validator: model.validateEmailCallback,
                              onChanged: (newValue) {
                                model.email = newValue.trim();
                              },
                              decoration: kContactEmailTextFormFieldDecoration,
                            ),
                            const SizedBox(height: 32),

                            /// contactCategory
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: DropdownButtonFormField(
                                validator: model.validateContactCallback,
                                value: model.contactDropdownValue,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 1,
                                style: kDropdownButtonFormFieldTextStyle,
                                decoration:
                                    kContactDropdownButtonFormFieldDecoration,
                                onChanged: (String? selectedValue) {
                                  model.contactDropdownValue = selectedValue!;
                                },
                                items: kContactList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            /// content
                            TextFormField(
                              focusNode: _focusNodeContent,
                              initialValue: null,
                              validator: model.validateContentCallback,
                              // maxLength: 1000,
                              minLines: 5,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onChanged: (newValue) {
                                model.contentValue = newValue;
                              },
                              decoration:
                                  kContactContentTextFormFieldDecoration,
                            ),
                            const SizedBox(height: 40),

                            /// 投稿送信ボタン
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await model.submitContactForm();
                                    Navigator.of(context).popUntil(
                                      ModalRoute.withName('/'),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('お問い合わせが送信されました。'),
                                      ),
                                    );
                                  } on String catch (e) {
                                    await showExceptionDialog(
                                      context,
                                      e.toString(),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'お問い合わせをする',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: kDarkPink,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(15),
                                // ),
                                side: const BorderSide(color: kDarkPink),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
