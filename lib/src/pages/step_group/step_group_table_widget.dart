// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:http_error_handler/error_handler.dart';
// import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
// import 'package:notary_admin/src/services/admin/step_group_service.dart';
// import 'package:notary_admin/src/widgets/basic_state.dart';
// import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
// import 'package:notary_model/model/step_group.dart';
// import 'package:rxdart/src/subjects/subject.dart';

// class StepGroupTableWidget extends StatefulWidget {
//   final GlobalKey? tableKey;
//   StepGroupTableWidget({super.key, this.tableKey});

//   @override
//   State<StepGroupTableWidget> createState() => _StepGroupTableWidgetState();
// }

// class _StepGroupTableWidgetState extends BasicState<StepGroupTableWidget>
//     with WidgetUtilsMixin {
//   final service = GetIt.instance.get<StepGroupService>();
//   final columnSpacing = 65.0;
//   bool initialized = false;
//   List<DataColumn> columns = [];
//   final tableKey = GlobalKey<LazyPaginatedDataTableState>();
//   @override
//   Widget build(BuildContext context) {
//     columns = [
//       DataColumn(label: Text(lang.createdFileSpec)),
//       DataColumn(label: Text(lang.stepGroup)),
//       DataColumn(label: Text(lang.steps)),
//       DataColumn(label: Text(lang.edit)),
//       DataColumn(label: Text(lang.delete)),
//     ];
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: LazyPaginatedDataTable<StepGroup>(
//         key: tableKey,
//         columnSpacing: columnSpacing,
//         getData: getData,
//         getTotal: getTotal,
//         columns: columns,
//         dataToRow: dataToRow,
//         checkboxHorizontalMargin: 20,
//         sortAscending: true,
//         dataRowHeight: 40,
//       ),
//     );
//   }

//   Future<List<StepGroup>> getData(PageInfo page) {
//     return service.getStepGroupList(index: page.pageIndex, size: page.pageSize);
//   }

//   Future<int> getTotal() {
//     return service.getStepGroupCount();
//   }

//   DataRow dataToRow(StepGroup data, int indexInCurrentPage) {
//     var cellList = [
//       DataCell(Text(lang.formatDate(data.creationDate))),
//       DataCell(Text(data.name)),
//       DataCell(
//         TextButton(
//           onPressed: () => showSteps(data),
//           child: Text(lang.steps),
//         ),
//       ),
//       DataCell(
//         TextButton(
//           onPressed: () => editStepGroup(data),
//           child: Text(lang.edit),
//         ),
//       ),
//       DataCell(
//         TextButton(
//           onPressed: () => deleteStepGroup(data.id),
//           child: Text(lang.delete),
//         ),
//       ),
//     ];
//     return DataRow(cells: cellList);
//   }

//   @override
//   List<ChangeNotifier> get notifiers => [];

//   @override
//   List<Subject> get subjects => [];

//   deleteStepGroup(String id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(lang.confirm),
//         content: Text(lang.confirmDelete),
//         actions: <Widget>[
//           TextButton(
//             child: Text(lang.no.toUpperCase()),
//             onPressed: () => Navigator.of(context).pop(false),
//           ),
//           TextButton(
//               child: Text(lang.yes.toUpperCase()),
//               onPressed: () async {
//                 try {
//                   await service.delete(id);
//                   Navigator.of(context).pop(true);
//                   tableKey.currentState?.refreshPage();
//                   await showSnackBar2(context, lang.delete);
//                 } catch (error, stacktrace) {
//                   showServerError(context, error: error);
//                   print(stacktrace);
//                 }
//               }),
//         ],
//       ),
//     );
//   }

//   editStepGroup(StepGroup data) {}

//   showSteps(StepGroup data) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           actions: [
//             Center(
//               child: ElevatedButton(
//                 child: Text(lang.ok.toUpperCase()),
//                 onPressed: () => Navigator.of(context).pop(false),
//               ),
//             ),
//           ],
//           title: Container(height: 50, child: Center(child: Text(lang.steps))),
//           content: Container(
//             padding: EdgeInsets.all(10),
//             height: 400,
//             width: 400,
//             child: data.steps.length == 0
//                 ? ListTile(title: Text(lang.noSteps.toUpperCase()))
//                 : ListView.builder(
//                     itemCount: data.steps.length,
//                     itemBuilder: (context, int index) {
//                       var step = data.steps.toList()[index];
//                       return ListTile(
//                         title: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Icon(
//                               Icons.folder,
//                               color: Color.fromARGB(158, 3, 18, 27),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(" ${step.name}"),
//                             SizedBox(
//                               width: 10,
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//           ),
//         );
//       },
//     );
//   }
// }
