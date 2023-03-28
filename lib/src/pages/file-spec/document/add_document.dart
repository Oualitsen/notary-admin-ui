import 'package:flutter/material.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:rxdart/rxdart.dart';
import '../../../utils/validation_utils.dart';
import '../../../widgets/mixins/button_utils_mixin.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({
    super.key,
  });

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends BasicState<AddDocument> with WidgetUtilsMixin {
  final _isOriginalDocumentStream = BehaviorSubject.seeded(false);
  final _isRequiredDocumentStream = BehaviorSubject.seeded(false);
  final _isDoubleSidedStream = BehaviorSubject.seeded(false);
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final _nameDocumentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.addFileSpec),
          ),
          body: Form(
            key: key,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: _nameDocumentCtrl,
                    decoration: getDecoration(lang.name, true),
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<bool>(
                      stream: _isOriginalDocumentStream,
                      initialData: _isOriginalDocumentStream.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile(
                          title: Text(lang.isOriginal),
                          value: _isOriginalDocumentStream.value,
                          onChanged: (value) {
                            if (value != null) {
                              _isOriginalDocumentStream.add(value);
                            }
                          },
                        );
                      }),
                  StreamBuilder<bool>(
                      stream: _isRequiredDocumentStream,
                      initialData: _isRequiredDocumentStream.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile(
                          title: Text(lang.isRequired),
                          value: _isRequiredDocumentStream.value,
                          onChanged: (value) {
                            print(value);
                            if (value != null) {
                              _isRequiredDocumentStream.add(value);
                            }
                          },
                        );
                      }),
                  StreamBuilder<bool>(
                      stream: _isDoubleSidedStream,
                      initialData: _isDoubleSidedStream.value,
                      builder: (context, snapshot) {
                        return CheckboxListTile(
                          title: Text(lang.isDoubleSided),
                          value: _isDoubleSidedStream.value,
                          onChanged: (value) {
                            print(value);
                            if (value != null) {
                              _isDoubleSidedStream.add(value);
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
      if (key.currentState!.validate()) {
        final doc = DocumentSpecInput(
            id: null,
            name: _nameDocumentCtrl.text,
            optional: _isOriginalDocumentStream.value,
            original: _isRequiredDocumentStream.value,
            doubleSided: _isDoubleSidedStream.value);
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
