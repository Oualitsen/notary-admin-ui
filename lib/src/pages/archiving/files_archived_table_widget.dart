import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/printed_docs/printed_doc_view.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/utils/widget_utils_new.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:rxdart/subjects.dart';
import '../../services/admin/printed_docs_service.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';

class FilesArchiveTableWidget extends StatefulWidget {
  final int startDate;
  final int endDate;
  const FilesArchiveTableWidget({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<FilesArchiveTableWidget> createState() =>
      _FilesArchiveTableWidgetState();
}

class _FilesArchiveTableWidgetState extends BasicState<FilesArchiveTableWidget>
    with WidgetUtilsMixin, WidgetUtilsFile {
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
      DataColumn(label: Text(lang.customer)),
      DataColumn(label: Text(lang.template)),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
      DataColumn(label: Text(lang.delete)),
    ];
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text("${lang.monthName(widget.startDate)}"),
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
                                ));
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
      DataCell(Text(lang.formatDate(data.creationDate))),
      DataCell(Text(data.number)),
      DataCell(Text(data.specification.name)),
      DataCell(TextButton(
          onPressed: () => customerDetails(data),
          child: Text(lang.customerList))),
      DataCell(
        TextButton(
            child: Text(lang.print), onPressed: (() => onPrint(data.id))),
      ),
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

  void onPrint(String id) async {
    try {
      var doc = await archiveService.getPrintedDocsById(id);
      push(context, PrintedDocViewHtml(title: doc.name, text: doc.htmlData));
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
      throw (error);
    }
  }

  customerDetails(FilesArchive data) async {
    try {
      //   var customersList = await archiveService.getFilesCustomers(data.id);
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Container(
                    height: 50,
                    child:
                        Wrap(alignment: WrapAlignment.spaceBetween, children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(lang.customerList),
                      ),
                      Tooltip(
                        message: lang.cancel,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            child: Icon(Icons.cancel),
                            onTap: () => Navigator.of(context).pop(false),
                          ),
                        ),
                      ),
                    ])),
                content: ListCustomers(
                  listCustomers: data.customers,
                  width: 300,
                ),
              ));
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  deleteFiles(FilesArchive data) {
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
            ));
  }

  void documentList(FilesArchive data) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Container(
          height: 50,
          child: Wrap(alignment: WrapAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(lang.listDocumentsFileSpec),
            ),
            Tooltip(
              message: lang.cancel,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.cancel,
                    size: 26,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ]),
        ),
        content: Container(
          height: 400,
          width: 400,
          child: data.specification.documents.length == 0
              ? ListTile(title: Text(lang.noDocument.toUpperCase()))
              : ListView.builder(
                  itemCount: data.specification.documents.length,
                  itemBuilder: (context, int index) {
                    var isRequired =
                        data.specification.documents[index].optional
                            ? lang.isNotRequired
                            : lang.isNotRequired;
                    var isOriginal =
                        data.specification.documents[index].original
                            ? lang.isOriginal
                            : lang.isNotOriginal;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text("${(index + 1)}"),
                      ),
                      title:
                          Text("${data.specification.documents[index].name}"),
                      subtitle: Text("${isRequired} , ${isOriginal}"),
                    );
                  }),
        ),
      ),
    );
  }
}
