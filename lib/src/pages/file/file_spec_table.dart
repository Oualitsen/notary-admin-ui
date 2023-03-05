import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/file/add_file_spec.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';
import '../../widgets/mixins/button_utils_mixin.dart';

class FileSpecTable extends StatefulWidget {
  const FileSpecTable({super.key});

  @override
  State<FileSpecTable> createState() => _FileSpecTableState();
}

class _FileSpecTableState extends BasicState<FileSpecTable>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<FileSpecService>();
  final columnSpacing = 65.0;
  bool initialized = false;
  List<DataColumn> columns = [];
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();
  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.createdFileSpec)),
      DataColumn(label: Text(lang.fileSpec)),
      DataColumn(label: Text(lang.list)),
      DataColumn(label: Text(lang.edit)),
      DataColumn(label: Text(lang.delete)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LazyPaginatedDataTable<FilesSpec>(
        key: tableKey,
        columnSpacing: columnSpacing,
        getData: getData,
        getTotal: getTotal,
        columns: columns,
        dataToRow: dataToRow,
        checkboxHorizontalMargin: 20,
        sortAscending: true,
        dataRowHeight: 40,
      ),
    );
  }

  Future<List<FilesSpec>> getData(PageInfo page) {
    return service.getFileSpecs(
        pageIndex: page.pageIndex, pageSize: page.pageSize);
  }

  Future<int> getTotal() {
    return service.getFilesSpecCount();
  }

  DataRow dataToRow(FilesSpec data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.creationDate))),
      DataCell(Text(data.name)),
      DataCell(TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                actions: [
                  Center(
                    child: ElevatedButton(
                      child: Text(lang.ok.toUpperCase()),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ],
                title: Container(
                    height: 50,
                    color: Colors.blue,
                    child: Center(child: Text(lang.listDocumentsFileSpec))),
                content: Container(
                  padding: EdgeInsets.all(10),
                  height: 400,
                  width: double.maxFinite,
                  child: data.documents.length == 0
                      ? ListTile(
                          title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(lang.noDocument.toUpperCase()),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: data.documents.length,
                          itemBuilder: (context, int index) {
                            return ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: Color.fromARGB(158, 3, 18, 27),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(" ${data.documents[index].name}"),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                      "${lang.createdFileSpec} : ${data.documents[index].creationDate.toString()}"),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(data.documents[index].optional == true
                                      ? "${lang.originalDocument} : ${lang.yes}"
                                      : "${lang.originalDocument} : ${lang.no}"),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(data.documents[index].original == true
                                      ? "${lang.requiredDocument} : ${lang.yes}"
                                      : "${lang.requiredDocument} : ${lang.no}"),
                                ],
                              ),
                            );
                          }),
                ),
              ),
            );
          },
          child: Text(lang.listDocumentsFileSpec))),
      DataCell(
        TextButton(
          onPressed: () async {
            Navigator.push<DocumentSpecInput>(
              context,
              MaterialPageRoute(
                  builder: (context) => AddFileSpec(
                        fileSpec: data,
                      )),
            ).then((value) {
              if (value != null) {}
            });
          },
          child: Text(lang.edit),
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(lang.confirm),
                content: Text(lang.confirmDelete),
                actions: <Widget>[
                  TextButton(
                    child: Text(lang.no.toUpperCase()),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                      child: Text(lang.yes.toUpperCase()),
                      onPressed: () async {
                        await service.deleteFileSpec(data.id);
                        Navigator.of(context).pop(true);
                        tableKey.currentState?.refreshPage();
                        await showSnackBar2(context, lang.delete);
                      }),
                ],
              ),
            );
          },
          icon: Icon(
            Icons.delete,
          ),
        ),
      ),
    ];
    return DataRow(cells: cellList);
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
