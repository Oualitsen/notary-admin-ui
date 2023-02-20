import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/form_and_view_html.dart';
import 'package:notary_admin/src/pages/file/html_editor.dart';
import 'package:notary_admin/src/pages/file/upload_file.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/template_document.dart';
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
  late List<String> items;
  bool initialized = false;
  final pathFiles = BehaviorSubject.seeded(<String>[]);
  final dropDownValueStream = BehaviorSubject.seeded("");

  void init() {
    if (!initialized) {
      items = [lang.editFileName, lang.editContent, lang.generatForm];
      dropDownValueStream.add(items.first);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(title: Text("All the files")),
        floatingActionButton: ElevatedButton(
          onPressed: loadFiles,
          child: Text(lang.addFiles),
        ),
        body: InfiniteScrollListView<TemplateDocument>(
          key: key,
          comparator: ((a, b) => b.creationDate - a.creationDate),
          elementBuilder: (BuildContext context, template, index, animation) {
            return ListTile(
                leading:
                    CircleAvatar(child: Text(template.name[0].toUpperCase())),
                title: Text(template.name),
                trailing: PopupMenuButton(
                  onSelected: (value) => onChanged(value, template),
                  itemBuilder: (item) {
                    return items
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList();
                  },
                  child: Text(lang.menu.toUpperCase()),
                ));
          },
          pageLoader: getData,
        ),
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
      key.currentState?.add(res);
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

  void onChanged(String? value, TemplateDocument template) async {
    if (value != null) {
      dropDownValueStream.add(value);
      if (value == items[0]) {
        templateNameCrtl.text = template.name;
        showTextInputDialog(context, template).then((value) {
          if (value != null && value.isNotEmpty) {
            onSave(template, value);
            key.currentState?.reload();
          }
        });
      }
      if (value == items[1]) {
        Navigator.push<TemplateDocument?>(
          context,
          MaterialPageRoute(
            builder: (context) => HtmlEditorExample(template: template),
          ),
        ).then((value) => key.currentState?.reload());
        ;
      }
      if (value == items[2]) {
        var finalList = [];
        var list = await service.formGenerating(template.id);
        for (var res in list) {
          //res =
          finalList.add(res.replaceAll(" ", "_"));
        }
        var data = await service.replacements(template.id);
        //  print(data);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormAndViewHtml(
              listFormField: finalList,
              text: data,
            ),
          ),
        ).then((value) => key.currentState?.reload());
        ;
      }
    }
  }

  Future loadFiles() async {
    List<String> extensions = ["docx"];
    try {
      var platformFiles = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: extensions);
      if (platformFiles != null) {
        var path = platformFiles.files.first.path;
        if (path != null) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                    builder: (context) => UploadFilePage(
                          firstPath: path,
                        )),
              )
              .then((value) => key.currentState?.reload());
        }
      }
    } catch (e) {
      print("[ERROR]${e.toString}");
    }
  }
}
