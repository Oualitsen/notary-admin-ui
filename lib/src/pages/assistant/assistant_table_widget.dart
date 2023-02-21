import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/assistant/assistant_detail_page.dart';
import 'package:notary_admin/src/services/assistant/assistant_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AssistantTableWidget extends StatefulWidget {
  final GlobalKey? tableKey;
  AssistantTableWidget({super.key, this.tableKey});

  @override
  State<AssistantTableWidget> createState() => _AssistantTableWidgetState();
}

class _AssistantTableWidgetState extends BasicState<AssistantTableWidget> {
  final service = GetIt.instance.get<AssistantService>();
  bool initialized = false;
  final columnSpacing = 65.0;
  List<DataColumn> columns = [];

  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.firstName.toUpperCase())),
      DataColumn(label: Text(lang.lastName.toUpperCase())),
      DataColumn(label: Text(lang.gender.toUpperCase())),
      DataColumn(label: Text(lang.assistantDetails.toUpperCase()))
    ];

    return LazyPaginatedDataTable<Assistant>(
        key: widget.tableKey,
        columnSpacing: columnSpacing,
        getData: getData,
        getTotal: getTotal,
        columns: columns,
        dataToRow: dataToRow);
  }

  Future<List<Assistant>> getData(PageInfo page) {
    return service.getAssistants(index: page.pageIndex, size: page.pageSize);
  }

  Future<int> getTotal() {
    return service.getAssistantsCount();
  }

  DataRow dataToRow(Assistant data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(data.firstName)),
      DataCell(Text(data.lastName)),
      DataCell(Text(lang.genderName(data.gender))),
      DataCell(TextButton(
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
      )),
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
