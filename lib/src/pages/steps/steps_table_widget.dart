import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/steps/add_step.dart';
import 'package:notary_admin/src/services/admin/steps_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/step_input.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/src/subjects/subject.dart';

class StepsTableWidget extends StatefulWidget {
  final GlobalKey<LazyPaginatedDataTableState>? tableKey;
  StepsTableWidget({super.key, this.tableKey});

  @override
  State<StepsTableWidget> createState() => _StepsTableWidgetState();
}

class _StepsTableWidgetState extends BasicState<StepsTableWidget>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<StepsService>();
  final columnSpacing = 65.0;
  bool initialized = false;
  List<DataColumn> columns = [];
  final stepKey = GlobalKey<AddStepWidgetState>();

  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.createdFileSpec)),
      DataColumn(label: Text(lang.name)),
      DataColumn(label: Text(lang.estimationTime)),
      DataColumn(label: Text(lang.edit)),
      DataColumn(label: Text(lang.delete)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LazyPaginatedDataTable<Steps>(
        key: widget.tableKey,
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

  Future<List<Steps>> getData(PageInfo page) {
    return service.getStepList(index: page.pageIndex, size: page.pageSize);
  }

  Future<int> getTotal() {
    return service.getStepCount();
  }

  DataRow dataToRow(Steps data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.creationDate))),
      DataCell(Text(data.name)),
      DataCell(Text("${data.estimatedTime}")),
      DataCell(
        TextButton(
          onPressed: () => editSteps(data, context),
          child: Text(lang.edit),
        ),
      ),
      DataCell(
        TextButton(
          onPressed: () => deleteSteps(data.id),
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

  deleteSteps(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                try {
                  await service.delete(id);
                  Navigator.of(context).pop(true);
                  widget.tableKey?.currentState?.refreshPage();
                  await showSnackBar2(context, lang.delete);
                } catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                }
              }),
        ],
      ),
    );
  }

  editSteps(Steps data, BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.addSteps),
            content: AddStepWidget(
              step: data,
              key: stepKey,
            ),
            actions: <Widget>[
              getButtons(onSave: saveStep),
            ],
          );
        });
  }

  void saveStep() async {
    Navigator.pop(context);
    StepInput? value = stepKey.currentState?.read();
    if (value != null) {
      try {
        progressSubject.add(true);
        await service.saveStep(value);
        widget.tableKey?.currentState?.refreshPage();
        await showSnackBar2(context, lang.savedSuccessfully);
      } catch (error, stacktrace) {
        showServerError(context, error: error);
        print(stacktrace);
      } finally {
        progressSubject.add(false);
      }
    }
  }
}
