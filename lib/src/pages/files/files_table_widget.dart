import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/file-spec/document/replace_document_widget.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/pages/printed_docs/printed_doc_view.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/subjects.dart';

class FilesTableWidget extends StatefulWidget {
  final GlobalKey? tableKey;

  const FilesTableWidget({super.key, this.tableKey});

  @override
  State<FilesTableWidget> createState() => _FilesTableWidgetState();
}

class _FilesTableWidgetState extends BasicState<FilesTableWidget>
    with WidgetUtilsMixin {
  final filesService = GetIt.instance.get<FilesService>();
  final servicePrintDocument = GetIt.instance.get<PrintedDocService>();
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();
  List<DataColumn> columns = [];
  bool initialized = false;
  final columnSpacing = 65.0;
  late List<String> items;
  final dropDownValueStream = BehaviorSubject.seeded("");
  final fileNameKey = GlobalKey<FormState>();
  final templateNameCrtl = TextEditingController();
  void init() {
    if (!initialized) {
      items = [lang.editName, lang.editContent, lang.print, lang.delete];
      dropDownValueStream.add(items.first);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    columns = [
      DataColumn(label: Text(lang.createdFileSpec)),
      DataColumn(label: Text(lang.filesNumber)),
      DataColumn(label: Text(lang.fileSpec)),
      DataColumn(label: Text(lang.state)),
      DataColumn(label: Text(lang.customer)),
      DataColumn(label: Text(lang.template)),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
      DataColumn(label: Text(lang.archive)),
      DataColumn(label: Text(lang.delete)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(hintText: lang.search),
          ),
          LazyPaginatedDataTable(
            getData: getData,
            getTotal: getTotal,
            columns: columns,
            dataToRow: dataToRow,
            sortAscending: true,
            key: tableKey,
          ),
        ],
      ),
    );
  }

  Future<List<Files>> getData(PageInfo page) {
    return filesService.getFilesAll(
        pageIndex: page.pageIndex, pageSize: page.pageSize);
  }

  Future<int> getTotal() {
    return filesService.getFilesCount();
  }

  DataRow dataToRow(Files data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.creationDate))),
      DataCell(Text(data.number)),
      DataCell(Text(data.specification.name)),
      DataCell(
        TextButton.icon(
            label: Text(data.currentStep.name),
            onPressed: (() => updateCurrentStep(data)),
            icon: Icon(Icons.edit)),
      ),
      DataCell(TextButton(
          onPressed: () => customerDetails(data),
          child: Text(lang.customerList))),
      DataCell(
        TextButton(
            child: Text(lang.print),
            onPressed: (() => onPrint(data.printedDocId))),
      ),
      DataCell(
        TextButton.icon(
            label: Text(lang.listDocumentsFileSpec),
            onPressed: () async => await updateDocumentFolderCustomer(data),
            icon: Icon(Icons.edit)),
      ),
      DataCell(TextButton(
          onPressed: () => archiveFiles(data), child: Text(lang.archive))),
      DataCell(TextButton(
          onPressed: () => deleteFiles(data), child: Text(lang.delete))),
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void updateCurrentStep(Files data) async {
    WidgetMixin.showDialog2(
      context,
      label: lang.selectStep.toUpperCase(),
      content: SizedBox(
        height: 400,
        width: 400,
        child: InfiniteScrollListView(
          elementBuilder: (context, element, index, animation) {
            return ListTile(
              leading: element.id == data.currentStep.id
                  ? CircleAvatar(
                      backgroundColor: Colors.lightBlue,
                      child: Text(
                        "${(index + 1)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : CircleAvatar(child: Text("${(index + 1)}")),
              title: Text("${element.name}"),
              subtitle: element.id == data.currentStep.id
                  ? Text("${lang.currentStep}")
                  : null,
              onTap: () async {
                await confirmStep(data.id, element);
                Navigator.pop(context);
              },
            );
          },
          pageLoader: ((index) {
            if (index == 0) {
              return Future.value(data.specification.steps);
            } else
              return Future.value(<Steps>[]);
          }),
        ),
      ),
    );
  }

  Future confirmStep(String id, Steps newStep) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.confirm),
        content: Text(lang.confirmChangingState),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(lang.no.toUpperCase())),
          TextButton(
              onPressed: () async {
                try {
                  progressSubject.add(true);
                  await filesService.updateCurrentStep(id, newStep);
                  tableKey.currentState?.refreshPage();
                  Navigator.of(context).pop(true);
                  await showSnackBar2(context, lang.updatedSuccessfully);
                } catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                } finally {
                  progressSubject.add(false);
                }
              },
              child: Text(lang.yes.toUpperCase())),
        ],
      ),
    );
  }

  void onPrint(String docId) async {
    try {
      var doc = await servicePrintDocument.getPrintedDocsById(docId);
      push(context, PrintedDocViewHtml(title: doc.name, text: doc.htmlData));
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  customerDetails(Files data) async {
    try {
      var customersList = await filesService.getFilesCustomers(data.id);
      WidgetMixin.showDialog2(
        context,
        label: lang.customerList,
        content: WidgetMixin.ListCustomers(
          context,
          listCustomers: customersList,
          width: 300,
        ),
      );
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  archiveFiles(Files data) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddArchivePage(
              files: data,
            ),
          ),
        )
        .then((_) => tableKey.currentState?.refreshPage());
  }

  deleteFiles(Files data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.confirm),
        content: Text(lang.confirmDelete),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(lang.no.toUpperCase())),
          TextButton(
              onPressed: () async {
                try {
                  await filesService.deleteFile(data.id);
                } catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                }
                Navigator.of(context).pop(true);
                tableKey.currentState?.refreshPage();
                await showSnackBar2(context, lang.delete);
              },
              child: Text(lang.yes.toUpperCase())),
        ],
      ),
    );
  }

  updateDocumentFolderCustomer(Files file) {
    return WidgetMixin.showDialog2(
      context,
      label: lang.listDocumentsFileSpec,
      content: Container(
        height: 200,
        width: 400,
        child: ListView.builder(
          itemCount: file.specification.partsSpecs.length,
          itemBuilder: (context, index) {
            var element = file.specification.partsSpecs[index];
            var uploaded = file.uploadedFiles
                .where((e) => e.partSpecId == element.id)
                .toList()
                .length;
            return ListTile(
              leading: CircleAvatar(child: Text("${(index + 1)}")),
              title: Text("${element.name}"),
              trailing: Wrap(
                spacing: 5,
                children: [
                  Text("${uploaded} / ${element.documentSpec.length}"),
                  Icon(Icons.edit),
                ],
              ),
              onTap: (() {
                Navigator.of(context).pop();
                var listPathDocuments =
                    file.specification.partsSpecs[index].documentSpec
                        .map((e) => PathsDocuments(
                              idParts: element.id,
                              idDocument: e.id,
                              document: null,
                              selected: isUploaded(file, e.id),
                              namePickedDocument: null,
                              path: null,
                              nameDocument: e.name,
                            ))
                        .toList();

                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => ReplaceDocumentWidget(
                      pathDocumentsList: listPathDocuments,
                      filesId: file.id,
                    ),
                  ),
                )
                    .then((value) {
                  tableKey.currentState?.refreshPage();
                });
              }),
            );
          },
        ),
      ),
    );
  }

  bool isUploaded(Files file, String docSpecId) {
    var isUploaded = false;
    for (var doc in file.uploadedFiles) {
      if (doc.docSpecId == docSpecId) {
        isUploaded = true;
      }
    }
    return isUploaded;
  }
}
