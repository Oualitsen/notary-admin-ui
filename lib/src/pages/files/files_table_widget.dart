import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_dialog.dart';
import 'package:notary_admin/src/pages/file-spec/document/replace_document_widget.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/pages/printed_docs/printed_doc_view.dart';
import 'package:notary_admin/src/pages/search/date_range_picker_widget.dart';
import 'package:notary_admin/src/pages/search/search_filter_table_widget.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class FilesTableWidget extends StatefulWidget {
  final GlobalKey? tableKey;
  final String? seachValue;
  const FilesTableWidget({super.key, this.tableKey, this.seachValue});

  @override
  State<FilesTableWidget> createState() => _FilesTableWidgetState();
}

class _FilesTableWidgetState extends BasicState<FilesTableWidget>
    with WidgetUtilsMixin {
  //services
  final filesService = GetIt.instance.get<FilesService>();
  final servicePrintDocument = GetIt.instance.get<PrintedDocService>();
  //key
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();
  final fileNameKey = GlobalKey<FormState>();
  //controllers
  final templateNameCtrl = TextEditingController();
  final filesCodeSearchCtrl = TextEditingController();
  final filesSpecSearchCtrl = TextEditingController();
  //streams
  final dropDownValueStream = BehaviorSubject.seeded("");
  final searchFilterStream = BehaviorSubject<bool?>();
  final subject = BehaviorSubject.seeded(SearchParams2(
      customers: [],
      fileSpecName: "",
      number: "",
      range: DateRange(endDate: null, startDate: null)));

  //variables
  List<DataColumn> columns = [];
  final columnSpacing = 60.0;

  @override
  void initState() {
    subject.listen((data) {
      if (data.number.isEmpty) {
        filesCodeSearchCtrl.text = "";
        searchFilterStream.add(null);
      }
      if (data.fileSpecName.isEmpty) {
        searchFilterStream.add(null);
        filesSpecSearchCtrl.text = "";
        searchFilterStream.add(null);
      }

      tableKey.currentState?.refreshPage();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    columns = getColumns();
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<SearchParams2>(
              stream: subject,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }

                return SearchFilterTableWidget(
                  searchParam: snapshot.data!,
                  onSearchParamsChanged: (p0) {
                    subject.add(p0);
                  },
                );
              }),
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
    try {
      var params = WidgetMixin.getParams(subject.value);
      if (params != null) {
        return filesService.searchFiles(
          number: params.number,
          filesSpecName: params.fileSpecName,
          customerIds: params.customerIds,
          startDate: params.startDate,
          endDate: params.endDate,
        );
      }
      return filesService.getFilesAll(
          pageIndex: page.pageIndex, pageSize: page.pageSize);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  Future<int> getTotal() {
    var params = WidgetMixin.getParams(subject.value);
    if (params != null) {
      return filesService.countSearchFiles(
        number: params.number,
        filesSpecName: params.fileSpecName,
        customerIds: params.customerIds,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    }
    return filesService.getFilesCount();
  }

  DataRow dataToRow(Files data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.creationDate))),
      DataCell(Text(data.number)),
      DataCell(Text(data.specification.name)),
      DataCell(TextButton(
          onPressed: () => customerDetails(data),
          child: Text(lang.customerList.toUpperCase()))),
      DataCell(
        TextButton.icon(
            label: Text(data.currentStep.name.toUpperCase()),
            onPressed: (() => updateCurrentStep(data)),
            icon: Icon(Icons.edit)),
      ),
      DataCell(
        TextButton.icon(
            label: Text(lang.listDocumentsFileSpec.toUpperCase()),
            onPressed: () async => await updateDocumentFolderCustomer(data),
            icon: Icon(Icons.edit)),
      ),
      DataCell(
        TextButton(
            child: Text(lang.print.toUpperCase()),
            onPressed: (() => onPrint(data.printedDocId))),
      ),
      DataCell(TextButton(
          onPressed: () => archiveFiles(data),
          child: Text(lang.archive.toUpperCase()))),
      DataCell(TextButton(
          onPressed: () => deleteFiles(data),
          child: Text(
            lang.delete.toUpperCase(),
            style: TextStyle(color: Colors.red),
          ))),
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
      content: InfiniteScrollListView(
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
            child: Text(lang.yes.toUpperCase()),
          ),
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
    WidgetMixin.confirmDelete(context)
        .asStream()
        .where((event) => event == true)
        .listen(
      (_) async {
        try {
          await filesService.deleteFile(data.id);
          showSnackBar2(context, lang.deletedSuccessfully);
        } catch (error, stacktrace) {
          showServerError(context, error: error);
          print(stacktrace);
        }
        tableKey.currentState?.refreshPage();
        await showSnackBar2(context, lang.delete);
      },
    );
  }

  updateDocumentFolderCustomer(Files file) {
    return WidgetMixin.showDialog2(
      context,
      label: lang.listDocumentsFileSpec,
      content: ListView.builder(
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
                      .map((e) => DocumentUploadInfos(
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

  List<DataColumn> getColumns() {
    var columns = [
      DataColumn(
          label: InkWell(
        child: Row(
          children: [Text(lang.creationDate), Icon(Icons.search)],
        ),
        onTap: () {
          searchFilterStream.add(null);
          showDialog(
            context: context,
            builder: ((context) {
              return DateRangePickerWidget(
                onSave: (range) {
                  var value = subject.value;
                  value.range = range;
                  subject.add(value);
                },
                range: subject.value.range,
              );
            }),
          );
        },
      )),
      DataColumn(
        label: columnWidget(
          lang.filesNumber,
          true,
        ),
      ),
      DataColumn(
        label: columnWidget(
          lang.specification,
          false,
        ),
      ),
      DataColumn(
        label: InkWell(
            child: Row(
              children: [Text(lang.customerList), Icon(Icons.search)],
            ),
            onTap: () {
              searchFilterStream.add(null);
              showDialog(
                context: context,
                builder: (context) => CustomerSelectionDialog(
                  initialCustomers: subject.value.customers,
                  onSave: (selectedCustomer) {
                    var value = subject.value;
                    value.customers = selectedCustomer;
                    subject.add(value);
                  },
                ),
              );
            }),
      ),
      DataColumn(label: Text(lang.state)),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
      DataColumn(label: Text(lang.template)),
      DataColumn(label: Text(lang.archive)),
      DataColumn(label: Text(lang.delete)),
    ];
    return columns;
  }

  Widget columnWidget(String label, bool filter) {
    var controller = filter ? filesCodeSearchCtrl : filesSpecSearchCtrl;

    return StreamBuilder<bool?>(
        stream: searchFilterStream,
        builder: (context, snapshot) {
          if (snapshot.data == filter || controller.text.isNotEmpty) {
            return Container(
              width: 100,
              child: TextFormField(
                autofocus: true,
                onFieldSubmitted: (value) {
                  var val = subject.value;
                  filter ? val.number = value : val.fileSpecName = value;
                  subject.add(val);
                },
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchFilterStream.add(null);
                      controller.clear();
                      controller.text = "";
                      var val = subject.value;
                      filter ? val.number = "" : val.fileSpecName = "";
                      subject.add(val);
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
              ),
            );
          }

          return InkWell(
            child: Row(
              children: [Text(label), Icon(Icons.search)],
            ),
            onTap: () => searchFilterStream.add(filter),
          );
        });
  }
}
