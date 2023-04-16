import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/file-spec/document/add_document.dart';
import 'package:notary_admin/src/pages/file-spec/document/documents_widget.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/parts_spec_input.dart';
import 'package:rxdart/subjects.dart';

class AddPartsSpecPage extends StatefulWidget {
  const AddPartsSpecPage({super.key});

  @override
  State<AddPartsSpecPage> createState() => AddPartsSpecPageState();
}

class AddPartsSpecPageState extends BasicState<AddPartsSpecPage>
    with WidgetUtilsMixin {
  //key
  final formKey = GlobalKey<FormState>();
  //controller
  final partsNameCtrl = TextEditingController();
  //stream
  final documentInputsStream = BehaviorSubject.seeded(<DocumentSpecInput>[]);

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.addPart),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: formKey,
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
              StreamBuilder<List<DocumentSpecInput>>(
                  stream: documentInputsStream,
                  initialData: documentInputsStream.value,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    return DocumentsWidget(
                      listDocument: snapshot.data!,
                      onChanged: (List<DocumentSpecInput> listDoc) {
                        documentInputsStream.add(listDoc);
                      },
                    );
                  }),
              ElevatedButton(
                onPressed: () => Navigator.push<DocumentSpecInput>(
                  context,
                  MaterialPageRoute(builder: (context) => AddDocument()),
                ).then((value) {
                  if (value != null) {
                    var list = documentInputsStream.value;
                    list.add(value);
                    documentInputsStream.add(list);
                  }
                }),
                child: Text(lang.addDocumentsSpec),
              ),
              SizedBox(height: 16),
              getButtons(onSave: onSave),
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
    if (formKey.currentState!.validate() &&
        documentInputsStream.value.isNotEmpty) {
      var partsSpecInput = PartsSpecInput(
          id: null,
          documentSpecInputs: documentInputsStream.value,
          name: partsNameCtrl.text);
      Navigator.of(context).pop(partsSpecInput);
    } else if (documentInputsStream.value.isEmpty) {
      showSnackBar2(context, lang.noDocument);
    }
  }
}
