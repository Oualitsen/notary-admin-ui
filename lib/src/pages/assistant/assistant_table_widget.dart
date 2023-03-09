import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/assistant/assistant_detail_page.dart';
import 'package:notary_admin/src/services/assistant/assistant_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AssistantTableWidget extends StatefulWidget {
  final GlobalKey<LazyPaginatedDataTableState>? tableKey;
  AssistantTableWidget({super.key, this.tableKey});

  @override
  State<AssistantTableWidget> createState() => AssistantTableWidgetState();
}

class AssistantTableWidgetState extends BasicState<AssistantTableWidget>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<AssistantService>();
  bool initialized = false;
  final columnSpacing = 65.0;
  List<DataColumn> columns = [];
  //final tableKey = GlobalKey<AssistantTableWidgetState>();

  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.firstName.toUpperCase())),
      DataColumn(label: Text(lang.lastName.toUpperCase())),
      DataColumn(label: Text(lang.gender.toUpperCase())),
      DataColumn(label: Text(lang.assistantDetails.toUpperCase())),
      DataColumn(label: Text(lang.delete.toUpperCase()))
    ];

    return LazyPaginatedDataTable<Admin>(
        key: widget.tableKey,
        columnSpacing: columnSpacing,
        getData: getData,
        getTotal: getTotal,
        columns: columns,
        dataToRow: dataToRow);
  }

  Future<List<Admin>> getData(PageInfo page) {
    return service.getAssistants(index: page.pageIndex, size: page.pageSize);
  }

  Future<int> getTotal() {
    return service.getAssistantsCount();
  }

  DataRow dataToRow(Admin data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(data.firstName)),
      DataCell(Text(data.lastName)),
      DataCell(Text(lang.genderName(data.gender))),
      DataCell(
        TextButton(
          child: Text(lang.assistantDetails),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AssistantDetailsPage(
                        assistant: data,
                      )),
            );
          },
        ),
      ),
      DataCell(
        TextButton(
          child: Text(lang.delete),
          onPressed: () {
            deleteConfirmation(data.id);
          },
        ),
      ),
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
  void deleteConfirmation(String assistantId) {
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
            onPressed: (() => delete(assistantId)),
          ),
        ],
      ),
    );
  }

  void delete(String assistantId) async {
    progressSubject.add(true);
    try {
      var result = await service.deleteAssistant(assistantId);
      Navigator.of(context).pop(false);
      widget.tableKey?.currentState?.refreshPage();
      showSnackBar2(context, lang.savedSuccessfully);
    } catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                } finally {
      progressSubject.add(false);
    }
  }
}
