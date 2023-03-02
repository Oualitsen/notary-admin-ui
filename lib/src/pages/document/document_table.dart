import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/file/add_file_spec.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';
import '../../widgets/mixins/button_utils_mixin.dart';

class DocumentsTable extends StatefulWidget {
  final List<DocumentSpecInput> listDocument;
  const DocumentsTable({super.key, required this.listDocument});

  @override
  State<DocumentsTable> createState() => _DocumentsTableState();
}

class _DocumentsTableState extends BasicState<DocumentsTable>
    with WidgetUtilsMixin {
  final columnSpacing = 30.0;
  bool initialized = false;
  final _listDocumentsStream = BehaviorSubject.seeded(<DocumentSpecInput>[]);
  List<DataColumn> columns = [];
  late List<DocumentSpecInput> listDocument;
  @override
  void initState() {
    listDocument = widget.listDocument;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 300,
      alignment: Alignment.topLeft,
      child: StreamBuilder<List<DocumentSpecInput>>(
          stream: _listDocumentsStream,
          initialData: listDocument,
          builder: (context, snapshot) {
            return listDocument.length == 0
                ? ListTile(
                    title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(lang.noDocument.toUpperCase()),
                    ],
                  ))
                : ListView.builder(
                    itemCount: listDocument.length,
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
                            Text("${listDocument[index].name}"),
                            SizedBox(
                              width: 10,
                            ),

                            Text(listDocument[index].optional == true
                                ? "${lang.originalDocument} : ${lang.yes}"
                                : "${lang.originalDocument} : ${lang.no}"),
                            SizedBox(
                              width: 10,
                            ),
                            Text(listDocument[index].original == true
                                ? "${lang.requiredDocument} : ${lang.yes}"
                                : "${lang.requiredDocument} : ${lang.no}"),
//a voir avec l'expiration des documents
                            // Text(
                            //   lang.expiryDate +
                            //       " : " +
                            //       lang.formatDate(listDocument[index].expiryDate),
                            // ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(lang.confirm),
                                content: Text(lang.confirmDelete),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(lang.no.toUpperCase()),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                      child: Text(lang.yes.toUpperCase()),
                                      onPressed: () {
                                        listDocument
                                            .remove(listDocument[index]);
                                        _listDocumentsStream.add(listDocument);
                                        Navigator.of(context).pop(true);
                                      })
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                          ),
                        ),
                      );
                    },
                  );
          }),
    );
  }

  Future<List<DocumentSpecInput>> getData(int page) {
    return Future<List<DocumentSpecInput>>(
      () {
        return listDocument;
      },
    );
  }

  Future<int> getTotal() {
    return Future<int>(
      () {
        return listDocument.length;
      },
    );
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
