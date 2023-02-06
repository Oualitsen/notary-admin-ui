import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contact.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';

class ContactsInputPage2 extends StatefulWidget {
  const ContactsInputPage2({Key? key}) : super(key: key);

  @override
  State<ContactsInputPage2> createState() => ContactsInputPage2State();
}

class ContactsInputPage2State extends BasicState<ContactsInputPage2>
    with WidgetUtilsMixin {
  final createdContacts = BehaviorSubject.seeded(<Contact>[]);
  final nameController = TextEditingController();
  final valueController = TextEditingController();
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.addContacts),
      ),
      body: Column(
        children: [
          AlertDialog(
            title: Text(lang.newContact),
            content: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      validator: (text) {
                        return ValidationUtils.requiredField(text, context);
                      },
                      controller: nameController,
                      decoration: (getDecoration(
                          lang.contactName, true, lang.contactNameEx))),
                  const SizedBox(height: 16),
                  TextFormField(
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                    controller: valueController,
                    decoration: (getDecoration(lang.contactValue, true)),
                    onFieldSubmitted: (_) => save(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              getButtons(onSave: save),
            ],
          ),
        ],
      ),
    );
  }

  void save() {
    if (key.currentState?.validate() ?? false) {
      Navigator.of(context)
          .pop(Contact(name: nameController.text, value: valueController.text));
      nameController.clear();
      valueController.clear();
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [createdContacts];
}
