import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/common/mixin/keyboard_actions_config_done_mixin.dart';
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
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text(
            'お問い合わせ',
            style: kAppBarTextStyle,
          ),
        ),
        body: Consumer<ContactModel>(
          builder: (context, model, child) {
            return LoadingSpinner(
              inAsyncCall: model.isLoading,
              child: KeyboardActions(
                config: buildConfig(context, _focusNodeContent),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32.0, horizontal: 24.0),
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
                          SizedBox(height: 32.0),

                          /// contactCategory
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: DropdownButtonFormField(
                              validator: model.validateContactCallback,
                              value: model.contactDropdownValue,
                              icon: Icon(Icons.arrow_downward),
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
                            decoration: kContactContentTextFormFieldDecoration,
                          ),
                          SizedBox(height: 40.0),

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
                                    SnackBar(
                                      content: Text('お問い合わせが送信されました。'),
                                    ),
                                  );
                                } catch (e) {
                                  await showExceptionDialog(
                                    context,
                                    e.toString(),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'お問い合わせをする',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: kDarkPink,
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(15),
                              // ),
                              side: BorderSide(color: kDarkPink),
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
    );
  }
}