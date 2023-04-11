import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_dialog.dart';
import 'package:notary_admin/src/pages/files/files_table_widget.dart';
import 'package:notary_admin/src/pages/pdf/pdf_images.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class FilesArchiveTableWidget extends StatefulWidget {
  final int startDate;
  final int endDate;
  final GlobalKey<LazyPaginatedDataTableState> tableKey;
  const FilesArchiveTableWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.tableKey,
  });

  @override
  State<FilesArchiveTableWidget> createState() =>
      _FilesArchiveTableWidgetState();
}

class _FilesArchiveTableWidgetState extends BasicState<FilesArchiveTableWidget>
    with WidgetUtilsMixin {
  //services
  final tokenService = GetIt.instance.get<TokenDbService>();
  final archiveService = GetIt.instance.get<FilesArchiveService>();
  final pdfService = GetIt.instance.get<PdfService>();
  //key
  final fileNameKey = GlobalKey<FormState>();
  //stream
  final dropDownValueStream = BehaviorSubject.seeded("");
  final filesCodeSearchStream = BehaviorSubject.seeded("");
  final filesSpecSearchStream = BehaviorSubject.seeded("");
  final searchFilterStream = BehaviorSubject<SearchFilter?>();
  final customerSearchStream = BehaviorSubject.seeded(<Customer>[]);
  //input controller
  final templateNameCrtl = TextEditingController();
  final filesCodeSearchCtrl = TextEditingController();
  final filesSpecSearchCtrl = TextEditingController();
//variables
  List<DataColumn> columns = [];
  bool initialized = false;
  final columnSpacing = 65.0;
  late List<String> items;

  @override
  void initState() {
    filesCodeSearchStream.listen((value) {
      widget.tableKey.currentState?.refreshPage();
    });
    filesSpecSearchStream.listen((value) {
      widget.tableKey.currentState?.refreshPage();
    });
    customerSearchStream.listen((value) {
      widget.tableKey.currentState?.refreshPage();
    });
    super.initState();
  }

  void init() {
    if (!initialized) {
      items = [lang.editName, lang.editContent, lang.print, lang.delete];
      dropDownValueStream.add(items.first);
      columns = [
        DataColumn(
            label: InkWell(
          child: Row(
            children: [Text(lang.archivingDate), Icon(Icons.search)],
          ),
          onTap: () {
            if (searchFilterStream.valueOrNull == SearchFilter.ARCHIVNG_DATE) {
              searchFilterStream.add(null);
            } else {
              searchFilterStream.add(SearchFilter.ARCHIVNG_DATE);
            }
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
        DataColumn(label: Text(lang.listDocumentsFileSpec)),
        DataColumn(label: Text(lang.delete)),
      ];
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<List<Object>>(
            stream: Rx.combineLatest3(
                filesCodeSearchStream,
                filesSpecSearchStream,
                customerSearchStream,
                (a, b, c) => [
                      a,
                      b,
                      c,
                    ]),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data == null || data.isEmpty) {
                return SizedBox.shrink();
              }
              var filesCode = data[0] as String;
              var filesSpec = data[1] as String;
              var customers = data[2] as List<Customer>;
              return Wrap(spacing: 20, children: [
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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: LazyPaginatedDataTable(
              getData: getData,
              getTotal: getTotal,
              columns: columns,
              dataToRow: dataToRow,
              sortAscending: true,
              key: widget.tableKey,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<FilesArchive>> getData(PageInfo page) {
    try {
      if (filesCodeSearchStream.value.isNotEmpty ||
          filesSpecSearchStream.value.isNotEmpty ||
          customerSearchStream.value.isNotEmpty) {
        var customerIds = "";
        customerSearchStream.value.forEach((e) {
          customerIds = customerIds + "," + e.id;
        });

        return archiveService.searchFilesArchive(
            number: filesCodeSearchStream.value,
            filesSpecName: filesSpecSearchStream.value,
            customerIds: customerIds,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }
      return archiveService.getFilesArchiveByDate(
          widget.startDate, widget.endDate);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  Future<int> getTotal() {
    if (filesCodeSearchStream.value.isNotEmpty ||
        filesSpecSearchStream.value.isNotEmpty ||
        customerSearchStream.value.isNotEmpty) {
      var customerIds = "";
      customerSearchStream.value.forEach((e) {
        customerIds = customerIds + "," + e.id;
      });
      return archiveService.countSearchFilesArchive(
          number: filesCodeSearchStream.value,
          filesSpecName: filesSpecSearchStream.value,
          customerIds: customerIds,
          startDate: widget.startDate,
          endDate: widget.endDate);
    }
    return archiveService.getCountFilesArchiveByDate(
        widget.startDate, widget.endDate);
  }

  DataRow dataToRow(FilesArchive data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.archvingDate))),
      DataCell(Text(data.number)),
      DataCell(Text(data.specification.name)),
      DataCell(TextButton(
          onPressed: () => customerDetails(data),
          child: Text(lang.customerList))),
      DataCell(
        TextButton(
            onPressed: () => documentList(data),
            child: Text(lang.listDocumentsFileSpec)),
      ),
      DataCell(
        TextButton(
          onPressed: () => deleteFiles(data),
          child: Text(lang.delete),
        ),
      ),
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  customerDetails(FilesArchive data) async {
    try {
      WidgetMixin.showDialog2(
        context,
        label: lang.customerList,
        content: WidgetMixin.ListCustomers(
          context,
          listCustomers: data.customers,
        ),
      );
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  deleteFiles(FilesArchive data) {
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
                  await archiveService.delete(data.id);
                } catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                }
                Navigator.of(context).pop(true);
                widget.tableKey.currentState?.refreshPage();
                await showSnackBar2(context, lang.delete);
              },
              child: Text(lang.yes.toUpperCase())),
        ],
      ),
    );
  }

  void documentList(FilesArchive data) {
    WidgetMixin.showDialog2(
      context,
      label: lang.listDocumentsFileSpec,
      content: InfiniteScrollListView<String>(
        elementBuilder: (context, element, index, animation) {
          return ListTile(
            leading: CircleAvatar(child: Text("${(index + 1)}")),
            title: Text("$element"),
            trailing: element.endsWith("pdf")
                ? Icon(Icons.picture_as_pdf)
                : Icon(Icons.download),
            onTap: () => downloadDocument(element, data.uploadedFiles[index]),
          );
        },
        pageLoader: ((index) => getDataDocuments(index, data)),
      ),
    );
  }

  Future<List<String>> getDataDocuments(int index, FilesArchive data) async {
    try {
      if (index == 0) {
        var docNames = await archiveService.getDocumentsName(data.id);
        return Future.value(docNames);
      }
      return Future.value(<String>[]);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  downloadDocument(String name, String id) async {
    if (name.endsWith(".pdf")) {
      try {
        var imageIds = await pdfService.getPdfImages(id);
        push(context, PdfImages(name: name, id: id, imageIds: imageIds));
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError(context, error: error);
        throw error;
      }
    } else {
      String? authToken = await tokenService.getToken();
      final response = await http.get(
        Uri.parse("${getUrlBase()}/admin/grid/download/${id}"),
        headers: {"Authorization": "Bearer $authToken"},
      );
      final bytes = response.bodyBytes;

      if (kIsWeb) {
        final content = base64Encode(bytes);
        final anchor = html.AnchorElement(
            href:
                "data:application/octet-stream;charset=utf-16le;base64,$content")
          ..setAttribute("download", name)
          ..click();
      } else {
        saveBytesToFile(bytes);
      }
    }
  }

  Future<void> saveBytesToFile(List<int> bytes) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      await FilePicker.platform.getDirectoryPath(
        dialogTitle: lang.directoryDialog,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(lang.permissionDenied),
          content: Text(lang.permissionText),
          actions: [
            getButtons(
              saveLabel: lang.openSettings,
              onSave: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    }
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
