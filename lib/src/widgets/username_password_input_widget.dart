import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/password_input.dart';
import 'package:rxdart/rxdart.dart';

class UserNamePasswordWidget extends StatefulWidget {
  const UserNamePasswordWidget({Key? key}) : super(key: key);

  @override
  UserNamePasswordWidgetState createState() => UserNamePasswordWidgetState();
}

class UserNamePasswordWidgetState extends BasicState<UserNamePasswordWidget> {
  final usernameCtrl = TextEditingController();
  final pwd1 = TextEditingController();
  final pwd2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameCtrl,
            validator: (text) {
              if (text?.isEmpty ?? true) {
                return lang.requiredField;
              }
              return null;
            },
            decoration: InputDecoration(labelText: lang.userName),
          ),
          const SizedBox(height: 16),
          PasswordInput(
            controller: pwd1,
            label: Text(lang.password),
            validator: (text) => ValidationUtils.requiredField(text, context),
          ),
          const SizedBox(height: 16),
          PasswordInput(
            controller: pwd2,
            label: Text(lang.repeatPassword),
            validator: (text) {
              if (text?.isEmpty ?? true) {
                return lang.requiredField;
              }
              if (text != pwd1.text) {
                return lang.passwordDontMatch;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  UserNamePwd? read() {
    if (_formKey.currentState?.validate() ?? false) {
      return UserNamePwd(username: usernameCtrl.text, password: pwd1.text);
    }

    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [pwd1, pwd2];

  @override
  List<Subject> get subjects => [];
}

class UserNamePwd {
  final String username;
  final String password;

  UserNamePwd({required this.username, required this.password});
}
