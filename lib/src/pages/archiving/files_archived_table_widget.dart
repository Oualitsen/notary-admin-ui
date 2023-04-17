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
import 'package:notary_admin/src/pages/pdf/pdf_images.dart';
import 'package:notary_admin/src/pages/search/date_range_picker_widget.dart';
import 'package:notary_admin/src/pages/search/search_filter_table_widget.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class FilesArchiveTableWidget extends StatefulWidget {
  final DateRange initialRange;
  final GlobalKey<LazyPaginatedDataTableState> tableKey;
  const FilesArchiveTableWidget({
    super.key,
    required this.initialRange,
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

  final searchFilterStream = BehaviorSubject<bool?>();
  final searchValueStream = BehaviorSubject.seeded(SearchParams2(
      customers: [],
      fileSpecName: "",
      number: "",
      range: DateRange(endDate: null, startDate: null)));

  //input controller
  final templateNameCrtl = TextEditingController();
  final filesCodeSearchCtrl = TextEditingController();
  final filesSpecSearchCtrl = TextEditingController();
//variables
  List<DataColumn> columns = [];
  bool initialized = false;
  final columnSpacing = 65.0;

  @override
  void initState() {
    searchValueStream.listen((data) {
      if (data.number.isEmpty) {
        filesCodeSearchCtrl.text = "";
      }
      if (data.fileSpecName.isEmpty) {
        filesSpecSearchCtrl.text = "";
      }
      widget.tableKey.currentState?.refreshPage();
    });

    super.initState();
  }

  void init() {
    if (!initialized) {
      columns = getColumns();
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<SearchParams2>(
              stream: searchValueStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                return SearchFilterTableWidget(
                  searchParam: snapshot.data!,
                  onSearchParamsChanged: (p0) {
                    searchValueStream.add(p0);
                  },
                );
              }),
          LazyPaginatedDataTable(
            getData: getData,
            getTotal: getTotal,
            columns: columns,
            dataToRow: dataToRow,
            sortAscending: true,
            key: widget.tableKey,
          ),
        ],
      ),
    );
  }

  Future<List<FilesArchive>> getData(PageInfo page) {
    try {
      {
        var params = WidgetMixin.getParams(searchValueStream.value);
        if (params != null) {
          return archiveService.searchFilesArchive(
            number: params.number,
            filesSpecName: params.fileSpecName,
            customerIds: params.customerIds,
            startDate: params.startDate,
            endDate: params.endDate,
          );
        }
      }
      return archiveService.getFilesArchiveByDate(
        widget.initialRange.startDate?.millisecondsSinceEpoch ?? 0,
        widget.initialRange.endDate?.millisecondsSinceEpoch ?? 0,
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  Future<int> getTotal() {
    try {
      var params = WidgetMixin.getParams(searchValueStream.value);
      if (params != null) {
        return archiveService.countSearchFilesArchive(
          number: params.number,
          filesSpecName: params.fileSpecName,
          customerIds: params.customerIds,
          startDate: params.startDate,
          endDate: params.endDate,
        );
      }
      return archiveService.getCountFilesArchiveByDate(
        widget.initialRange.startDate?.millisecondsSinceEpoch ?? 0,
        widget.initialRange.endDate?.millisecondsSinceEpoch ?? 0,
      );
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  DataRow dataToRow(FilesArchive data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.archvingDate))),
      DataCell(Text(data.number)),
      DataCell(Text(data.specification.name)),
      DataCell(TextButton(
          onPressed: () => customerDetails(data),
          child: Text(lang.customerList.toUpperCase()))),
      DataCell(
        TextButton(
            onPressed: () => documentList(data),
            child: Text(lang.listDocumentsFileSpec.toUpperCase())),
      ),
      DataCell(
        TextButton(
          onPressed: () => deleteFiles(data),
          child: Text(lang.delete.toUpperCase()),
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

  List<DataColumn> getColumns() {
    var columns = [
      DataColumn(
          label: InkWell(
        child: Row(
          children: [Text(lang.archivingDate), Icon(Icons.search)],
        ),
        onTap: () {
          searchFilterStream.add(null);
          showDialog(
            context: context,
            builder: ((context) {
              return DateRangePickerWidget(
                onSave: (range) {
                  var value = searchValueStream.value;
                  value.range = range;
                  searchValueStream.add(value);
                },
                range: searchValueStream.value.range,
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
                  initialCustomers: searchValueStream.value.customers,
                  onSave: (selectedCustomer) {
                    var value = searchValueStream.value;
                    value.customers = selectedCustomer;
                    searchValueStream.add(value);
                  },
                ),
              );
            }),
      ),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
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
                  var val = searchValueStream.value;
                  filter ? val.number = value : val.fileSpecName = value;
                  searchValueStream.add(val);
                },
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchFilterStream.add(null);
                      controller.clear();
                      controller.text = "";
                      var val = searchValueStream.value;
                      filter ? val.number = "" : val.fileSpecName = "";
                      searchValueStream.add(val);
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
