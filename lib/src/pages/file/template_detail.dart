import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rxdart/subjects.dart';

class TemplateDetails extends StatefulWidget {
  final TemplateDocument template;
  TemplateDetails({super.key, required this.template});
  @override
  State<TemplateDetails> createState() => _TemplateDetailsState();
}

class _TemplateDetailsState extends BasicState<TemplateDetails>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<TemplateDocumentService>();
  late TemplateDocument template;
  final templateNameCrtl = TextEditingController();
  final newName = BehaviorSubject<String>();
  final fileNameKey = GlobalKey<FormState>();
  @override
  void initState() {
    template = widget.template;
    newName.add(template.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(template.name.toUpperCase())),
      body: ListView(
        children: [
          StreamBuilder<String>(
              stream: newName,
              builder: (context, snapshot) {
                var name = template.name;
                if (snapshot.hasData) {
                  name = newName.value;
                }
                return ListTile(
                  title: Text(name),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      templateNameCrtl.text = name;
                      showTextInputDialog(context);
                    },
                  ),
                );
              }),
          getButtons(onSave: onSave)
        ],
      ),
    );
  }

  Future<void> showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.editFileName),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AlertDialog(
                    title: Text(lang.editFileName),
                    content: Form(
                      key: fileNameKey,
                      child: TextFormField(
                        controller: templateNameCrtl,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        validator: (text) {
                          return ValidationUtils.requiredField(text, context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: <Widget>[
              getButtons(
                onSave: () {
                  if (fileNameKey.currentState?.validate() ?? false) {
                    newName.add(templateNameCrtl.text);
                    templateNameCrtl.clear();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  void onSave() async {
    progressSubject.add(true);
    try {
     var res =  await service.updateName(widget.template.id, newName.value);

      await showSnackBar2(context, lang.savedSuccessfully);
      Navigator.of(context).pop(res);
    } catch (error) {
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
