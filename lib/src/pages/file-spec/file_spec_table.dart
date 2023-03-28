import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/file-spec/add_file_spec.dart';
import 'package:notary_admin/src/pages/steps/add_step_widget.dart';
import 'package:notary_admin/src/services/admin/steps_service.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/step_input.dart';
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
  final stepService = GetIt.instance.get<StepsService>();
  final stepKey = GlobalKey<AddStepWidgetState>();
  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.createdFileSpec)),
      DataColumn(label: Text(lang.name)),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
      DataColumn(label: Text(lang.steps)),
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
      DataCell(
        TextButton(
          onPressed: () => documentList(context, data),
          child: Text(lang.listDocumentsFileSpec),
        ),
      ),
      DataCell(
        TextButton(
          onPressed: () => stepsList(context, data),
          child: Text(lang.steps),
        ),
      ),
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
        TextButton(
          onPressed: () => deleteFileSpec(data),
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

  void documentList(BuildContext context, FilesSpec data) {
    WidgetMixin.showDialog2(
      context,
      label: lang.listDocumentsFileSpec,
      content: Container(
        height: 400,
        width: 400,
        child: ListView.builder(
          itemCount: data.documents.length,
          itemBuilder: (context, int index) {
            var isRequired = data.documents[index].optional
                ? lang.isNotRequired
                : lang.isNotRequired;
            var isOriginal = data.documents[index].original
                ? lang.isOriginal
                : lang.isNotOriginal;
            return ListTile(
              leading: CircleAvatar(
                child: Text("${(index + 1)}"),
              ),
              title: Text("${data.documents[index].name}"),
              subtitle: Text("${isRequired} , ${isOriginal}"),
            );
          },
        ),
      ),
    );
  }

  void stepsList(BuildContext context, FilesSpec data) {
    WidgetMixin.showDialog2(
      context,
      label: lang.steps,
      content: Container(
        padding: EdgeInsets.all(10),
        height: 400,
        width: 400,
        child: ListView.builder(
            itemCount: data.steps.length,
            itemBuilder: (context, int index) {
              var step = data.steps.toList()[index];
              return ListTile(
                  leading: CircleAvatar(child: Text("${(index + 1)}")),
                  title: Text("${step.name}"));
            }),
      ),
    );
  }

  deleteFileSpec(FilesSpec data) {
    WidgetMixin.showDialog2(
      context,
      label: lang.confirm,
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
              await service.deleteFileSpec(data.id);
              Navigator.of(context).pop(true);
              tableKey.currentState?.refreshPage();
              await showSnackBar2(context, lang.delete);
            } catch (error, stacktrace) {
              showServerError(context, error: error);
              print(stacktrace);
            }
          },
        ),
      ],
    );
  }
}
