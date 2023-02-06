import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contact.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/subjects.dart';

class ContactsInputPage extends StatefulWidget {
  const ContactsInputPage({Key? key}) : super(key: key);

  @override
  State<ContactsInputPage> createState() => ContactsInputPageState();
}

class ContactsInputPageState extends BasicState<ContactsInputPage>
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
          Expanded(
            child: StreamBuilder<List<Contact>>(
                stream: createdContacts,
                initialData: createdContacts.value,
                builder: (context, snapshot) {
                  var data = snapshot.data ?? [];
                  return ListView(
                    children: data
                        .map((e) => ListTile(
                              title: Text(e.name),
                              subtitle: Text(e.value),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => removeElement(e),
                              ),
                            ))
                        .toList(),
                  );
                }),
          ),
          FloatingActionButton(
            onPressed: () async {
              var contact = await _showTextInputDialog(context);

              if (contact != null) {
                var contactList = createdContacts.value;
                contactList.add(contact);
                //notify listener
                createdContacts.add(contactList);
              }
            },
            child: const Icon(Icons.add),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: getButtons(
              onSave: () {
                Navigator.of(context).pop(createdContacts.value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Contact?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.newContact),
            content: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
          );
        });
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

  removeElement(Contact e) {
    var list = createdContacts.value;
    list.remove(e);
    createdContacts.add(list);
  }
}
