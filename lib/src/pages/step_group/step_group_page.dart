// import 'package:flutter/material.dart';
// import 'package:notary_admin/src/pages/step_group/add_step_group.dart';
// import 'package:notary_admin/src/pages/step_group/step_group_table_widget.dart';
// import 'package:notary_admin/src/widgets/basic_state.dart';
// import 'package:rxdart/src/subjects/subject.dart';

// import '../../utils/widget_utils.dart';
// import '../../widgets/mixins/button_utils_mixin.dart';

// class StepGroupPage extends StatefulWidget {
//   const StepGroupPage({super.key});

//   @override
//   State<StepGroupPage> createState() => _StepGroupPageState();
// }

// class _StepGroupPageState extends BasicState<StepGroupPage>
//     with WidgetUtilsMixin {
//   @override
//   Widget build(BuildContext context) {
//     return WidgetUtils.wrapRoute((context, type) => Scaffold(
//           appBar: AppBar(
//             title: Text(lang.stepGroup),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddStepGroup()),
//               );
//             },
//             child: Icon(Icons.add),
//           ),
//           body: Padding(
//               padding: EdgeInsets.all(20), child: StepGroupTableWidget()),
//         ));
//   }

//   @override
//   List<ChangeNotifier> get notifiers => [];

//   @override
//   List<Subject> get subjects => [];
// }
