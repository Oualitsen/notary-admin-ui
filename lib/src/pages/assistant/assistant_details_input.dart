import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:notary_model/model/gender.dart';

import 'package:rxdart/src/subjects/subject.dart';

class AssistantDetailsInput extends StatefulWidget {
  final Assistant? assistant;
  const AssistantDetailsInput({super.key, this.assistant});

  @override
  State<AssistantDetailsInput> createState() => AssistantDetailsInputState();
}

class AssistantDetailsInputState extends BasicState<AssistantDetailsInput>
    with WidgetUtilsMixin {
  final key = GlobalKey<FormState>();
  final firstNameCrtl = TextEditingController();
  final lastNameCrtl = TextEditingController();

  @override
  void initState() {
    firstNameCrtl.text = widget.assistant?.firstName ?? "";
    lastNameCrtl.text = widget.assistant?.lastName ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        children: [
          TextFormField(
            decoration: getDecoration(lang.firstName, true),
            controller: firstNameCrtl,
            validator: (text) => ValidationUtils.requiredField(text, context),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: getDecoration(lang.lastName, true),
            controller: lastNameCrtl,
            validator: (text) => ValidationUtils.requiredField(text, context),
          )
        ],
      ),
    );
  }

  AssistantDetails? readDetails() {
    if (key.currentState!.validate()) {
      return AssistantDetails(
          firstNameCrtl.text, lastNameCrtl.text, Gender.MALE);
    }
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class AssistantDetails {
  final String firstName;
  final String lastName;
  final Gender gender;
  AssistantDetails(this.firstName, this.lastName, this.gender);
}
