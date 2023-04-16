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
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/parts_spec.dart';
import 'package:rxdart/rxdart.dart';

class FileSpecTable extends StatefulWidget {
  final GlobalKey<LazyPaginatedDataTableState>? tableKey;
  final String? searchValue;
  const FileSpecTable({super.key, this.tableKey, required this.searchValue});

  @override
  State<FileSpecTable> createState() => _FileSpecTableState();
}

class _FileSpecTableState extends BasicState<FileSpecTable>
    with WidgetUtilsMixin {
  //service
  final service = GetIt.instance.get<FileSpecService>();
  final stepService = GetIt.instance.get<StepsService>();
  //key
  final stepKey = GlobalKey<AddStepWidgetState>();
  //variables
  final columnSpacing = 65.0;
  bool initialized = false;
  late List<DataColumn> columns;

  init() {
    if (initialized) return;
    initialized = true;
    columns = [
      DataColumn(label: Text(lang.creationDate)),
      DataColumn(label: Text(lang.name)),
      DataColumn(label: Text(lang.listDocumentsFileSpec)),
      DataColumn(label: Text(lang.steps)),
      DataColumn(label: Text(lang.edit)),
      DataColumn(label: Text(lang.delete)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LazyPaginatedDataTable<FilesSpec>(
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

  Future<List<FilesSpec>> getData(PageInfo page) {
    if (widget.searchValue == null || widget.searchValue!.isEmpty) {
      return service.getFileSpecs(
          pageIndex: page.pageIndex, pageSize: page.pageSize);
    }

    return service.searchFilesSpec(
        name: widget.searchValue!, index: page.pageIndex, size: page.pageSize);
  }

  Future<int> getTotal() {
    if (widget.searchValue == null || widget.searchValue!.isEmpty) {
      return service.getFilesSpecCount();
    }
    return service.searchCount(name: widget.searchValue!);
  }

  DataRow dataToRow(FilesSpec data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(lang.formatDate(data.creationDate))),
      DataCell(Text(data.name)),
      DataCell(
        TextButton(
          onPressed: () => documentList(context, data),
          child: Text(lang.listPart),
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
      label: lang.listPart,
      content: ListView.builder(
        itemCount: data.partsSpecs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text("${(index + 1)}")),
            title: Text("${data.partsSpecs[index].name}"),
            trailing: Icon(Icons.arrow_forward),
            onTap: (() => showDocuments(data.partsSpecs[index])),
          );
        },
      ),
    );
  }

  void stepsList(BuildContext context, FilesSpec data) {
    WidgetMixin.showDialog2(
      context,
      label: lang.steps,
      content: Padding(
        padding: const EdgeInsets.all(10),
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
                await service.deleteFileSpec(data.id);
                Navigator.of(context).pop(true);
                widget.tableKey?.currentState?.refreshPage();
                await showSnackBar2(context, lang.delete);
              } catch (error, stacktrace) {
                showServerError(context, error: error);
                print(stacktrace);
              }
            },
          ),
        ],
      ),
    );
  }

  showDocuments(PartsSpec data) {
    WidgetMixin.showDialog2(
      context,
      label: lang.listDocumentsFileSpec,
      content: ListView.builder(
        itemCount: data.documentSpec.length,
        itemBuilder: (context, int index) {
          var isRequired = data.documentSpec[index].optional
              ? lang.isNotRequired
              : lang.isNotRequired;
          var isOriginal = data.documentSpec[index].original
              ? lang.isOriginal
              : lang.isNotOriginal;
          var isDoubleSide = data.documentSpec[index].doubleSided
              ? lang.isDoubleSided
              : lang.isNotDoubleSided;
          return ListTile(
            leading: CircleAvatar(
              child: Text("${(index + 1)}"),
            ),
            title: Text("${data.documentSpec[index].name}"),
            subtitle: Text("${isRequired} , ${isOriginal} , ${isDoubleSide}"),
          );
        },
      ),
    );
  }
}
