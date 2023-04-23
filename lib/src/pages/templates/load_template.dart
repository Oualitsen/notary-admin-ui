import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/widgets/widget_roles.dart';
import 'package:notary_admin/src/pages/templates/html_editor_template.dart';
import 'package:notary_admin/src/pages/templates/upload_template.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/role.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rapidoc_utils/alerts/alert_vertical_widget.dart';
import 'package:rxdart/subjects.dart';

class LoadTemplatePage extends StatefulWidget {
  const LoadTemplatePage({super.key});

  @override
  State<LoadTemplatePage> createState() => _LoadTemplatePageState();
}

class _LoadTemplatePageState extends BasicState<LoadTemplatePage>
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
      items = [lang.editFileName, lang.editContent, lang.delete];
      dropDownValueStream.add(items.first);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) => RoleGuardWidget(
        role: Role.ADMIN,
        noRoleWidget: Center(
            child: AlertVerticalWidget.createDanger(
                lang.noAccessRightError.toUpperCase())),
        child: Scaffold(
          appBar: AppBar(title: Text(lang.template)),
          floatingActionButton: ElevatedButton(
            onPressed: loadFiles,
            child: Text(lang.addFiles.toUpperCase()),
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
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(lang.menu.toUpperCase()),
                  ),
                ),
              );
            },
            pageLoader: getData,
          ),
        ),
      ),
    );
  }

  Future<String?> showTextInputDialog(
      BuildContext context, TemplateDocument file) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
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
      return service.getTemplates(pageIndex: index, pageSize: 20);
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
            builder: (context) => HtmlEditorTemplate(template: template),
          ),
        ).then((value) => key.currentState?.reload());
      }
      if (value == items[2]) {
        ReusedWidgets.confirmDelete(context)
            .asStream()
            .where((event) => event == true)
            .listen(
          (_) async {
            try {
              await service.delete(template.id);
              key.currentState?.reload();
              showSnackBar2(context, lang.deletedSuccessfully);
            } catch (error, stackTrace) {
              print(stackTrace);
              showServerError(context, error: error);
            }
          },
        );
      }
    }
  }

  Future loadFiles() async {
    List<String> extensions = ["docx"];
    try {
      var pickedFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: extensions);
      if (pickedFile != null) {
        var path = null;
        if (!kIsWeb) {
          path = pickedFile.files.first.path;
        }
        var data = UploadData(
            data: pickedFile.files.first.bytes,
            name: pickedFile.files.first.name,
            path: path);
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                  builder: (context) => UploadTemplatePage(
                        firstPath: data,
                      )),
            )
            .then((value) => key.currentState?.reload());
      }
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
      throw error;
    }
  }
}
