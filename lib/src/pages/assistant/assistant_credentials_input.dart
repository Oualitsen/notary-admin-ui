import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AssistantCredentailsInput extends StatefulWidget {
  const AssistantCredentailsInput({super.key});

  @override
  State<AssistantCredentailsInput> createState() =>
      AssistantCredentailsInputState();
}

class AssistantCredentailsInputState
    extends BasicState<AssistantCredentailsInput> with WidgetUtilsMixin {
  final key = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        children: [
          TextFormField(
            controller: usernameCtrl,
            decoration: getDecoration(lang.userName, true),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: passwordCtrl,
            decoration: getDecoration(lang.password, true),
          )
        ],
      ),
    );
  }

  AssistantCredentials? readCredentails() {
    if (key.currentState!.validate()) {
      return AssistantCredentials(usernameCtrl.text, passwordCtrl.text);
    }
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class AssistantCredentials {
  final String username;
  final String password;
  AssistantCredentials(this.username, this.password);
}
