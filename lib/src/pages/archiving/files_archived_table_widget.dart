import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/pdf/pdf_images.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:rxdart/subjects.dart';
import '../../widgets/basic_state.dart';
import 'package:universal_html/html.dart' as html;
import '../../widgets/mixins/button_utils_mixin.dart';

class FilesArchiveTableWidget extends StatefulWidget {
  final int startDate;
  final int endDate;
  final String title;
  const FilesArchiveTableWidget({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<FilesArchiveTableWidget> createState() =>
      _FilesArchiveTableWidgetState();
}

class _FilesArchiveTableWidgetState extends BasicState<FilesArchiveTableWidget>
    with WidgetUtilsMixin {
  final archiveService = GetIt.instance.get<FilesArchiveService>();
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
      columns = [
        DataColumn(label: Text(lang.archivingDate)),
        DataColumn(label: Text(lang.filesNumber)),
        DataColumn(label: Text(lang.fileSpec)),
        DataColumn(label: Text(lang.customer)),
        DataColumn(label: Text(lang.listDocumentsFileSpec)),
        DataColumn(label: Text(lang.delete)),
      ];
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              ElevatedButton(
                onPressed:
                    widget.startDate < DateTime.now().millisecondsSinceEpoch
                        ? () {
                            push(
                                context,
                                AddArchivePage(
                                  initDate: DateTime.fromMillisecondsSinceEpoch(
                                      widget.startDate),
                                )).listen((_) {
                              tableKey.currentState?.refreshPage();
                            });
                          }
                        : null,
                child: Text(lang.addFiles),
              )
            ],
          ),
          body: ListView(
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
        ));
  }

  Future<List<FilesArchive>> getData(PageInfo page) {
    if (page.pageIndex == 0) {
      var result = archiveService.getFilesArchiveByDate(
          widget.startDate, widget.endDate);

      return result;
    } else {
      return Future.value([]);
    }
  }

  Future<int> getTotal() {
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
          width: 300,
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
                tableKey.currentState?.refreshPage();
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
      content: Container(
        height: 300,
        width: 400,
        child: InfiniteScrollListView<String>(
          elementBuilder: (context, element, index, animation) {
            return ListTile(
              leading: CircleAvatar(child: Text("${(index + 1)}")),
              title: Text("$element"),
              trailing: Icon(Icons.download),
              onTap: () => downloadDocument(element, data.uploadedFiles[index]),
            );
          },
          pageLoader: ((index) => getDataDocuments(index, data)),
        ),
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
        var imageIds = await archiveService.getPdfImages(id);
        push(context, PdfImages(name: name, id: id, imageIds: imageIds));
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError(context, error: error);
      }
    } else {
      html.AnchorElement anchor = new html.AnchorElement(
          href: "${getUrlBase()}/admin/grid/content/pdf/${name}");
      anchor.click();
    }
  }
}
