import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/printed_docs/html_editor_printed_doc.dart';
import 'package:notary_admin/src/pages/printed_docs/printed_doc_view.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';

import '../../utils/widget_utils.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';

class PrintedDocumentsPage extends StatefulWidget {
  const PrintedDocumentsPage({super.key});

  @override
  State<PrintedDocumentsPage> createState() => _PrintedDocumentsPageState();
}

class _PrintedDocumentsPageState extends BasicState<PrintedDocumentsPage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<PrintedDocService>();
  final key = GlobalKey<InfiniteScrollListViewState<PrintedDoc>>();
  final templateNameCrtl = TextEditingController();
  late List<String> items;
  bool initialized = false;
  final dropDownValueStream = BehaviorSubject.seeded("");
  final fileNameKey = GlobalKey<FormState>();

  void init() {
    if (!initialized) {
      items = [lang.editFileName, lang.editContent, lang.print, lang.delete];
      dropDownValueStream.add(items.first);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.listFilesCustomer),
          ),
          body: InfiniteScrollListView<PrintedDoc>(
            key: key,
            comparator: ((a, b) => b.creationDate - a.creationDate),
            elementBuilder: (BuildContext context, template, index, animation) {
              return ListTile(
                leading:
                    CircleAvatar(child: Text(template.name[0].toUpperCase())),
                title: Text(template.name),
                subtitle: Text(lang.formatDate(template.creationDate)),
                trailing: PopupMenuButton(
                  onSelected: (value) => onChanged(value, template),
                  itemBuilder: (item) {
                    return items
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList();
                  },
                  child: Text(lang.menu.toUpperCase()),
                ),
              );
            },
            pageLoader: getData,
          ),
        ));
  }

  Future<List<PrintedDoc>> getData(int index) {
    return service.getAllPrinted(pageIndex: index, pageSize: 20);
  }

  editContent(PrintedDoc template) {
    Navigator.push<PrintedDoc?>(
      context,
      MaterialPageRoute(
        builder: (context) => HtmlEditorPrintedDoc(template: template),
      ),
    ).then((value) => key.currentState?.reload());
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void onChanged(String? value, PrintedDoc doc) async {
    if (value != null) {
      dropDownValueStream.add(value);
      if (value == items[0]) {
        templateNameCrtl.text = doc.name;
        editName(doc).then((value) {
          if (value != null && value.isNotEmpty) {
            onSave(doc, value);
            key.currentState?.reload();
          }
        });
      }
      if (value == items[1]) {
        editContent(doc);
      }
      if (value == items[2]) {
        push(context, PrintedDocViewHtml(text: doc.htmlData));
      }
      if (value == items[3]) {
        showDialog(
            context: context,
            builder: (BuildContext) => AlertDialog(
                  title: Text(lang.confirm),
                  content: Text(lang.confirmDelete),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(lang.no.toUpperCase())),
                    TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(true);
                          await _delete(doc);
                        },
                        child: Text(lang.confirm.toUpperCase())),
                  ],
                ));
      }
      ;
    }
  }

  void onSave(PrintedDoc doc, String newName) async {
    progressSubject.add(true);
    try {
      var res = await service.updateName(doc.id, newName);
      await showSnackBar2(context, lang.updatedSuccessfully);
      key.currentState?.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }

  Future<String?> editName(PrintedDoc file) async {
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

  _delete(PrintedDoc doc) async {
    progressSubject.add(true);
    try {
      await service.delete(doc.id);
      key.currentState?.reload();
      await showSnackBar2(context, lang.delete);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }
}
