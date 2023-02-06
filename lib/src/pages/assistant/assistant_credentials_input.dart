import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/services/assistant/assistant_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant.dart';

import 'package:rxdart/src/subjects/subject.dart';

class AssistantCredentailsInput extends StatefulWidget {
  final Assistant? assistant;
  const AssistantCredentailsInput({super.key, this.assistant});

  @override
  State<AssistantCredentailsInput> createState() =>
      AssistantCredentailsInputState();
}

class AssistantCredentailsInputState
    extends BasicState<AssistantCredentailsInput> with WidgetUtilsMixin {
  final service = GetIt.instance.get<AssistantService>();
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

  Future<AssistantCredentials?> readCredentails() async {
    if (key.currentState!.validate()) {
      try {
        var assistant = await service.getByUsername(usernameCtrl.text);
        if (assistant.id == widget.assistant?.id) {
          return AssistantCredentials(usernameCtrl.text, passwordCtrl.text);
        }
      } catch (error) {
        return AssistantCredentials(usernameCtrl.text, passwordCtrl.text);
      }
    }
    return Future.value();
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
