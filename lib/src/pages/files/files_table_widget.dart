import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/utils/widget_utils_new.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/src/subjects/subject.dart';
import '../../services/admin/printed_docs_service.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import 'update_document_folder_customer.dart';

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

  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.createdFileSpec)),
      DataColumn(label: Text(lang.print)),
      DataColumn(label: Text(lang.state)),
      DataColumn(label: Text(lang.filesNumber)),
      DataColumn(label: Text(lang.customerName)),
      DataColumn(label: Text(lang.fileSpec)),
      DataColumn(label: Text(lang.fileList)),
      DataColumn(label: Text(lang.edit)),
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
      DataCell(
        Tooltip(
          message: lang.print,
          child: IconButton(
            onPressed: () => null,
            icon: Icon(Icons.print),
          ),
        ),
      ),
      DataCell(Row(
        children: [
          Tooltip(
            message: lang.previous,
            child: TextButton(
              onPressed: () => updateCurrentStep(data, false),
              child: Text(lang.previous),
            ),
          ),
          SizedBox(width: 5),
          Text(data.currentStep.name),
          SizedBox(width: 5),
          Tooltip(
            message: lang.next,
            child: TextButton(
              onPressed: () => updateCurrentStep(data, false),
              child: Text(lang.next),
            ),
          ),
        ],
      )),
      DataCell(Text(data.number)),
      DataCell(TextButton(
          onPressed: () async {
            try {
              var customersList = await filesService.getFilesCustomers(data.id);
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Container(
                            height: 40,
                            color: Colors.blue,
                            child: Center(child: Text(lang.customerList))),
                        content: ListCustomers(
                          listCustomers: customersList,
                          width: 300,
                        ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(lang.previous.toUpperCase())),
                        ],
                      ));
            } catch (error, stacktrace) {
              showServerError(context, error: error);
              print(stacktrace);
            }
          },
          child: Text(lang.customerList))),
      DataCell(Text(data.specification.name)),
      DataCell(TextButton(
          onPressed: () async {
            try {
              var documentsUpload =
                  await filesService.loadFileDocuments(data.id);
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Container(
                            height: 40,
                            color: Colors.blue,
                            child: Center(child: Text(lang.fileList))),
                        content: widgetListFiles(
                          documentsUpload: documentsUpload,
                          width: 300,
                        ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text(lang.previous.toUpperCase())),
                        ],
                      ));
            } catch (error, stacktrace) {
              showServerError(context, error: error);
              print(stacktrace);
            }
          },
          child: Text(lang.fileList))),
      DataCell(TextButton(
          onPressed: () async {
            Navigator.push<Files>(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateDocumentFolderCustomer(
                          file: data,
                        ))).then((value) => {if (value != null) {}});
          },
          child: Text(lang.edit))),
      DataCell(TextButton(
          onPressed: () => {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
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
                        ))
              },
          child: Text(
            lang.delete,
            style: TextStyle(color: Colors.red),
          ))),
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Steps? getStep(Files data, bool goNext) {
    var steps = data.specification.steps;
    var currentStep = steps.indexOf(data.currentStep);
    if (goNext) {
      if (currentStep < (steps.length - 1)) {
        return steps.elementAt(currentStep + 1);
      }
    } else {
      if (currentStep > 0) {
        return steps.elementAt(currentStep - 1);
      }
    }
    return null;
  }

  void updateCurrentStep(Files data, bool goNext) async {
    Steps? newStep = getStep(data, goNext);
    if (newStep != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
                    await filesService.updateCurrentStep(data.id, newStep);
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
  }
}
