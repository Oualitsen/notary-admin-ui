import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/file/html_editor.dart';
import 'package:notary_admin/src/pages/file/upload_file.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';

class LoadFilePage extends StatefulWidget {
  const LoadFilePage({super.key});

  @override
  State<LoadFilePage> createState() => _LoadFilePageState();
}

class _LoadFilePageState extends BasicState<LoadFilePage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<TemplateDocumentService>();
  final key = GlobalKey<InfiniteScrollListViewState<TemplateDocument>>();
  final templateNameCrtl = TextEditingController();
  final fileNameKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All the files")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadFilePage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: InfiniteScrollListView<TemplateDocument>(
        key: key,
        comparator: ((a, b) => b.creationDate - a.creationDate),
        elementBuilder: (BuildContext context, template, index, animation) {
          return ListTile(
            title: Text(template.name),
            //subtitle: Text(template.creationDate.toString()),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    templateNameCrtl.text = template.name;
                    showTextInputDialog(context, template).then((value) {
                      if (value != null && value.isNotEmpty) {
                        onSave(template, value);
                      }
                    });
                  },
                ),
                IconButton(
                    onPressed: (() {
                      Navigator.push<TemplateDocument?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HtmlEditorExample(template: template),
                        ),
                      );
                    }),
                    icon: Icon(Icons.file_copy))
              ],
            ),
            // subtitle: Text("${file.creationDate}"),
            // onTap: () async {
            //   var res = await Navigator.push<TemplateDocument?>(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => TemplateDetails(
            //               template: file,
            //             )),
            //   );
            //   if (res != null) {
            //     key.currentState?.add(res);
            //   }
            // }
          );
        },
        pageLoader: getData,
      ),
    );
  }

  Future<String?> showTextInputDialog(
      BuildContext context, TemplateDocument file) async {
    return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
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
            actions: <Widget>[
              getButtons(
                onSave: () {
                  if (fileNameKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(templateNameCrtl.text);
                    templateNameCrtl.clear();
                  }
                },
              )
            ],
          );
        });
  }

  void onSave(TemplateDocument template, String newName) async {
    progressSubject.add(true);
    try {
      var res = await service.updateName(template.id, newName);

      await showSnackBar2(context, lang.updatedSuccessfully);
      //   Navigator.of(context).pop(res);
      key.currentState!.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }

  Future<List<TemplateDocument>> getData(int index) {
    if (index == 0)
      return service.getFiles(pageIndex: index, pageSize: 20);
    else
      return Future.value([]);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
