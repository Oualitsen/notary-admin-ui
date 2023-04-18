import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/printed_docs/html_editor_printed_doc.dart';
import 'package:notary_admin/src/pages/printed_docs/printed_doc_view.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:rxdart/subjects.dart';

class PrintedDocumentsPage extends StatefulWidget {
  const PrintedDocumentsPage({super.key});

  @override
  State<PrintedDocumentsPage> createState() => _PrintedDocumentsPageState();
}

class _PrintedDocumentsPageState extends BasicState<PrintedDocumentsPage>
    with WidgetUtilsMixin {
  //service
  final service = GetIt.instance.get<PrintedDocService>();
  //key
  final printedDocListkey =
      GlobalKey<InfiniteScrollListViewState<PrintedDoc>>();
  final fileNameKey = GlobalKey<FormState>();
  //controller
  final templateNameCrtl = TextEditingController();
  //stream
  final dropDownValueStream = BehaviorSubject.seeded("");
  //variables
  late List<String> items;
  bool initialized = false;

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
            title: Text(lang.savedTemplates),
          ),
          body: InfiniteScrollListView<PrintedDoc>(
            key: printedDocListkey,
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
    ).then((value) => printedDocListkey.currentState?.reload());
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
            printedDocListkey.currentState?.reload();
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
        WidgetMixin.confirmDelete(context)
            .asStream()
            .where((event) => event == true)
            .listen(
          (_) async {
            await _delete(doc);
          },
        );
      }
      ;
    }
  }

  void onSave(PrintedDoc doc, String newName) async {
    progressSubject.add(true);
    try {
      var res = await service.updateName(doc.id, newName);
      await showSnackBar2(context, lang.updatedSuccessfully);
      printedDocListkey.currentState?.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }

  Future<String?> editName(PrintedDoc file) async {
    return WidgetMixin.showDialog2<String>(
      context,
      label: lang.editFileName,
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
  }

  _delete(PrintedDoc doc) async {
    progressSubject.add(true);
    try {
      await service.delete(doc.id);
      printedDocListkey.currentState?.reload();
      await showSnackBar2(context, lang.delete);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }
}
