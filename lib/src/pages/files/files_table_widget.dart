import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/files/add_folder_customer.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/src/subjects/subject.dart';

import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import 'file_picker_customer_folder.dart';

class FilesTableWidget extends StatefulWidget {
  final GlobalKey? tableKey;

  const FilesTableWidget({super.key, this.tableKey});

  @override
  State<FilesTableWidget> createState() => _FilesTableWidgetState();
}

class _FilesTableWidgetState extends BasicState<FilesTableWidget>
    with WidgetUtilsMixin {
  final filesService = GetIt.instance.get<FilesService>();
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();

  List<DataColumn> columns = [];
  bool initialized = false;
  final columnSpacing = 65.0;

  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.createdFileSpec)),
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
      DataCell(Text(data.number)),
      DataCell(TextButton(
          onPressed: () async {
            var customersList = await filesService.getFilesCustomers(data.id);
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: Container(
                          height: 50,
                          color: Colors.blue,
                          child: Center(child: Text(lang.customerList))),
                      content: Container(
                        padding: EdgeInsets.all(10),
                        height: 400,
                        width: double.maxFinite,
                        child: data.clientIds.length == 0
                            ? ListTile(
                                title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(lang.noCustomer.toUpperCase()),
                                ],
                              ))
                            : ListView.builder(
                                itemCount: data.clientIds.length,
                                itemBuilder: (context, int index) {
                                  return ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.man,
                                          color: Color.fromARGB(158, 3, 18, 27),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                            "${lang.lastName}  :  ${customersList[index].lastName}"),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                            "${lang.firstName}  :  ${customersList[index].firstName}"),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                            "${lang.dateOfBirth}  :  ${lang.formatDate(customersList[index].dateOfBirth)}"),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(lang.previous.toUpperCase())),
                      ],
                    ));
          },
          child: Text(lang.customerList))),
      DataCell(Text(data.specification.name)),
      DataCell(TextButton(
          onPressed: () async {
            var documentsUpload = await filesService.loadFileDocuments(data.id);
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: Container(
                          height: 50,
                          color: Colors.blue,
                          child: Center(child: Text(lang.fileList))),
                      content: Container(
                        padding: EdgeInsets.all(10),
                        height: 400,
                        width: double.maxFinite,
                        child: data.uploadedFiles.length == 0
                            ? ListTile(
                                title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(lang.noDocument.toUpperCase()),
                                ],
                              ))
                            : ListView.builder(
                                itemCount: documentsUpload.length,
                                itemBuilder: (context, int index) {
                                  return ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.file_download,
                                          color:
                                              Color.fromARGB(158, 135, 150, 6),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                            "${data.specification.documents[index].name}"),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(lang.previous.toUpperCase())),
                      ],
                    ));
          },
          child: Text(lang.fileList))),
      DataCell(TextButton(
          onPressed: () async {
            var customersList = await filesService.getFilesCustomers(data.id);
            Navigator.push<Files>(
                context,
                MaterialPageRoute(
                    builder: (context) => FilePickerCustomerFolder(
                          files: data,
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
                                  await filesService.deleteFile(data.id);
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
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
