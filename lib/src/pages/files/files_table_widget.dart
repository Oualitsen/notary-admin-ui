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
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/rxdart.dart';

class FilesTableWidget extends StatefulWidget {
  final GlobalKey? tableKey;
  final String? seachValue;
  final Function(bool doSearch)? onSearch;
  const FilesTableWidget(
      {super.key, this.tableKey, this.seachValue, this.onSearch});

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
  final searchValueStream = BehaviorSubject.seeded("");
  final filesCodeSearchStream = BehaviorSubject.seeded("");
  final filesSpecSearchStream = BehaviorSubject.seeded("");
  final searchFilterStream = BehaviorSubject<SearchFilter?>();
  final customerSearchStream = BehaviorSubject.seeded(<Customer>[]);
  final rangeDateSearchStream = BehaviorSubject.seeded(<int>[]);
  //variables
  List<DataColumn> columns = [];
  bool initialized = false;
  final columnSpacing = 60.0;
  late List<String> items;

  @override
  void initState() {
    searchValueStream
        .where((event) => tableKey.currentState != null)
        .debounceTime(Duration(milliseconds: 500))
        .listen((value) {
      tableKey.currentState?.refreshPage();
    });
    filesCodeSearchStream.listen((value) {
      tableKey.currentState?.refreshPage();
    });
    filesSpecSearchStream.listen((value) {
      tableKey.currentState?.refreshPage();
    });
    customerSearchStream.listen((value) {
      tableKey.currentState?.refreshPage();
    });
    rangeDateSearchStream.listen((value) {
      if (value.isNotEmpty && value[0] == -1 && value[1] == -1) {
        rangeDateSearchStream.add(<int>[]);
      }
      tableKey.currentState?.refreshPage();
    });
    super.initState();
  }

  void init() {
    if (!initialized) {
      items = [lang.editName, lang.editContent, lang.print, lang.delete];
      dropDownValueStream.add(items.first);
      searchFilterStream.listen((value) {
        if (value != null) {
          widget.onSearch?.call(true);
        } else {
          widget.onSearch?.call(false);
        }
      });
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    columns = [
      DataColumn(
          label: InkWell(
        child: Row(
          children: [Text(lang.creationDate), Icon(Icons.search)],
        ),
        onTap: () {
          searchFilterStream.add(SearchFilter.ARCHIVNG_DATE);
          showDialog(
            context: context,
            builder: ((context) {
              var startDate = null;
              var endDate = null;
              if (rangeDateSearchStream.value.isNotEmpty) {
                if (rangeDateSearchStream.value[0] > 0) {
                  startDate = rangeDateSearchStream.value[0];
                }
                if (rangeDateSearchStream.value[1] > 0) {
                  endDate = rangeDateSearchStream.value[1];
                }
              }
              return DateRangePickerWidget(
                onSave: (range) {
                  rangeDateSearchStream.add(range);
                },
                startDate: startDate,
                endDate: endDate,
              );
            }),
          );
        },
      )),
      DataColumn(
        label: columnWidget(
          lang.filesNumber,
          SearchFilter.NUMBER,
        ),
      ),
      DataColumn(
        label: columnWidget(
          lang.specification,
          SearchFilter.FILES_SPEC_NAME,
        ),
      ),
      DataColumn(label: Text(lang.state)),
      DataColumn(
        label: InkWell(
            child: Row(
              children: [Text(lang.customerList), Icon(Icons.search)],
            ),
            onTap: () {
              searchFilterStream.add(SearchFilter.CUSTOMER_NAME);
              showDialog(
                context: context,
                builder: (context) => CustomerSelectionDialog(
                  onSave: (selectedCustomer) {
                    customerSearchStream.add(selectedCustomer);
                    Navigator.pop(context);
                  },
                ),
              );
            }),
      ),
      DataColumn(label: Text(lang.template)),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
      DataColumn(label: Text(lang.archive)),
      DataColumn(label: Text(lang.delete)),
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<List<Object>>(
            stream: Rx.combineLatest4(
                filesCodeSearchStream,
                filesSpecSearchStream,
                customerSearchStream,
                rangeDateSearchStream,
                (a, b, c, d) => [a, b, c, d]),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data == null || data.isEmpty) {
                return SizedBox.shrink();
              }
              var filesCode = data[0] as String;
              var filesSpec = data[1] as String;
              var customers = data[2] as List<Customer>;
              var range = data[3] as List<int>;
              return Wrap(spacing: 20, children: [
                range.isNotEmpty && range.elementAt(0) > 0
                    ? InputChip(
                        label: Text(
                            "${lang.start} : ${lang.formatDate(range.elementAt(0))}"),
                        onDeleted: () {
                          range.insert(0, -1);
                          range.removeAt(1);
                          rangeDateSearchStream.add(range);
                        },
                        deleteIcon: Icon(Icons.cancel),
                      )
                    : SizedBox.shrink(),
                range.isNotEmpty && range.elementAt(1) > 0
                    ? InputChip(
                        label: Text(
                            "${lang.end} : ${lang.formatDate(range.elementAt(1))}"),
                        onDeleted: () {
                          range.insert(1, -1);
                          range.removeAt(2);
                          rangeDateSearchStream.add(range);
                        },
                        deleteIcon: Icon(Icons.cancel),
                      )
                    : SizedBox.shrink(),
                filesCode.isNotEmpty
                    ? InputChip(
                        label: Text("${filesCode}"),
                        onDeleted: () {
                          filesCodeSearchStream.add("");
                          filesCodeSearchCtrl.clear();
                        },
                        deleteIcon: Icon(Icons.cancel),
                      )
                    : SizedBox.shrink(),
                filesSpec.isNotEmpty
                    ? InputChip(
                        label: Text("${filesSpec}"),
                        onDeleted: () {
                          filesSpecSearchStream.add("");
                          filesSpecSearchCtrl.clear();
                        },
                        deleteIcon: Icon(Icons.cancel),
                      )
                    : SizedBox.shrink(),
                ...customers
                    .map(
                      (e) => InputChip(
                        label: Text("${e.firstName} ${e.lastName}"),
                        onDeleted: () {
                          customers.remove(e);
                          customerSearchStream.add(customers);
                        },
                        deleteIcon: Icon(Icons.cancel),
                      ),
                    )
                    .toList()
              ]);
            },
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
    try {
      if (filesCodeSearchStream.value.isNotEmpty ||
          filesSpecSearchStream.value.isNotEmpty ||
          customerSearchStream.value.isNotEmpty ||
          rangeDateSearchStream.value.isNotEmpty) {
        var listArgs = _getArgs();

        return filesService.searchFiles(
          number: listArgs.elementAt(0) as String,
          filesSpecName: listArgs.elementAt(1) as String,
          customerIds: listArgs.elementAt(2) as String,
          startDate: listArgs.elementAt(3) as int,
          endDate: listArgs.elementAt(4) as int,
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
    if (filesCodeSearchStream.value.isNotEmpty ||
        filesSpecSearchStream.value.isNotEmpty ||
        customerSearchStream.value.isNotEmpty ||
        rangeDateSearchStream.value.isNotEmpty) {
      var listArgs = _getArgs();

      return filesService.countSearchFiles(
        number: listArgs.elementAt(0) as String,
        filesSpecName: listArgs.elementAt(1) as String,
        customerIds: listArgs.elementAt(2) as String,
        startDate: listArgs.elementAt(3) as int,
        endDate: listArgs.elementAt(4) as int,
      );
    }
    return filesService.getFilesCount();
  }

  List<dynamic> _getArgs() {
    var res = [];
    var customerIds = "";
    customerSearchStream.value.forEach((e) {
      customerIds = customerIds + "," + e.id;
    });
    var startDate = -1;
    var endDate = -1;
    if (rangeDateSearchStream.value.isNotEmpty) {
      startDate = rangeDateSearchStream.value[0];
      if (rangeDateSearchStream.value[1] > 0) {
        endDate =
            DateTime.fromMillisecondsSinceEpoch(rangeDateSearchStream.value[1])
                .add(Duration(days: 1))
                .millisecondsSinceEpoch;
      } else {
        endDate = rangeDateSearchStream.value[1];
      }
    }
    res.add(filesCodeSearchStream.value);
    res.add(filesSpecSearchStream.value);
    res.add(customerIds);
    res.add(startDate);
    res.add(endDate);
    return res;
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

  Widget columnWidget(String label, SearchFilter filter) {
    var stream = filter == SearchFilter.NUMBER
        ? filesCodeSearchStream
        : filesSpecSearchStream;

    var controller = filter == SearchFilter.NUMBER
        ? filesCodeSearchCtrl
        : filesSpecSearchCtrl;

    return StreamBuilder<SearchFilter?>(
        stream: searchFilterStream,
        builder: (context, snapshot) {
          if (snapshot.data == filter || controller.text.isNotEmpty) {
            return Container(
              width: 100,
              child: TextFormField(
                autofocus: true,
                onFieldSubmitted: (value) {
                  stream.add(value);
                },
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchFilterStream.add(null);
                      controller.clear();
                      stream.add("");
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

enum SearchFilter {
  ARCHIVNG_DATE,
  NUMBER,
  FILES_SPEC_NAME,
  CUSTOMER_NAME,
}
