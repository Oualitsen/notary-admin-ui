import 'package:flutter/material.dart';
import 'package:flutter/src/animation/animation_controller.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/ticker_provider.dart';
import 'package:notary_admin/src/pages/file-spec/document/add_document.dart';
import 'package:notary_admin/src/pages/file-spec/document/document_table_widget.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/parts_spec_input.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';

class AddPartsSpecPage extends StatefulWidget {
  const AddPartsSpecPage({super.key});

  @override
  State<AddPartsSpecPage> createState() => AddPartsSpecPageState();
}

class AddPartsSpecPageState extends BasicState<AddPartsSpecPage>
    with WidgetUtilsMixin {
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final partsNameCtrl = TextEditingController();
  final _listDocumentsInputStream =
      BehaviorSubject.seeded(<DocumentSpecInput>[]);
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.addFileSpec),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: key,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: partsNameCtrl,
                    decoration: getDecoration(lang.name, true),
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push<DocumentSpecInput>(
                  context,
                  MaterialPageRoute(builder: (context) => AddDocument()),
                ).then((value) {
                  if (value != null) {
                    var list = _listDocumentsInputStream.value;
                    list.add(value);
                    _listDocumentsInputStream.add(list);
                  }
                }),
                child: Text(lang.addDocumentsSpec),
              ),
              StreamBuilder<List<DocumentSpecInput>>(
                  stream: _listDocumentsInputStream,
                  initialData: _listDocumentsInputStream.value,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DocumentsWidget(
                          listDocument: snapshot.data!,
                          onChanged: (List<DocumentSpecInput> listDoc) {
                            _listDocumentsInputStream.add(listDoc);
                          },
                        ),
                      ],
                    );
                  }),
              getButtons(
                onSave: ((key.currentState?.validate() ?? false) &&
                        _listDocumentsInputStream.value.isNotEmpty)
                    ? onSave
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  onSave() {
    if (key.currentState!.validate() &&
        _listDocumentsInputStream.value.isNotEmpty) {
      var partsSpecInput = PartsSpecInput(
          id: null,
          documentSpecInputs: _listDocumentsInputStream.value,
          name: partsNameCtrl.text);
      Navigator.of(context).pop(partsSpecInput);
    }
  }
}
