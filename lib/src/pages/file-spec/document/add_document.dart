import 'package:flutter/material.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:rxdart/rxdart.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({super.key});

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends BasicState<AddDocument> with WidgetUtilsMixin {
  //stream
  final isOriginalDocumentStream = BehaviorSubject.seeded(false);
  final isRequiredDocumentStream = BehaviorSubject.seeded(false);
  final isDoubleSidedStream = BehaviorSubject.seeded(false);
  //key
  final formKey = GlobalKey<FormState>();
  //controller
  final nameDocumentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.addDocumentsSpec),
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: nameDocumentCtrl,
                    decoration: getDecoration(lang.name, true),
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<bool>(
                      stream: isOriginalDocumentStream,
                      initialData: isOriginalDocumentStream.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile(
                          title: Text(lang.isOriginal),
                          value: isOriginalDocumentStream.value,
                          onChanged: (value) {
                            if (value != null) {
                              isOriginalDocumentStream.add(value);
                            }
                          },
                        );
                      }),
                  StreamBuilder<bool>(
                      stream: isRequiredDocumentStream,
                      initialData: isRequiredDocumentStream.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile(
                          title: Text(lang.isRequired),
                          value: isRequiredDocumentStream.value,
                          onChanged: (value) {
                            if (value != null) {
                              isRequiredDocumentStream.add(value);
                            }
                          },
                        );
                      }),
                  StreamBuilder<bool>(
                      stream: isDoubleSidedStream,
                      initialData: isDoubleSidedStream.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile(
                          title: Text(lang.isDoubleSided),
                          value: isDoubleSidedStream.value,
                          onChanged: (value) {
                            if (value != null) {
                              isDoubleSidedStream.add(value);
                            }
                          },
                        );
                      }),
                  getButtons(onSave: save),
                ],
              ),
            ),
          ),
        ));
  }

  save() async {
    try {
      if (formKey.currentState!.validate()) {
        final doc = DocumentSpecInput(
            id: null,
            name: nameDocumentCtrl.text,
            optional: isOriginalDocumentStream.value,
            original: isRequiredDocumentStream.value,
            doubleSided: isDoubleSidedStream.value);
        Navigator.of(context).pop(doc);
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
