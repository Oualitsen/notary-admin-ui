// import 'package:flutter/material.dart';
// import 'package:notary_admin/src/init.dart';
// import 'package:notary_admin/src/utils/widget_utils.dart';
// import 'package:notary_admin/src/widgets/basic_state.dart';
// import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
// import 'package:rxdart/src/subjects/subject.dart';
// import 'package:universal_html/html.dart' as html;

// class DowloadFile extends StatefulWidget {
//   const DowloadFile({super.key});

//   @override
//   State<DowloadFile> createState() => _DowloadFileState();
// }

// class _DowloadFileState extends BasicState<DowloadFile> with WidgetUtilsMixin {
//   final controller = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return WidgetUtils.wrapRoute(
//       (context, type) => Scaffold(
//         body: Column(
//           children: [
//             TextFormField(
//               controller: controller,
//             ),
//             TextButton(onPressed: () => dowload(), child: Text("dowload"))
//           ],
//         ),
//       ),
//     );
//   }

//   dowload() {
//     html.AnchorElement anchor = new html.AnchorElement(
//         href: "${getUrlBase()}/admin/grid/content/${controller.text}");
//     anchor.click();
//   }

//   @override
//   List<ChangeNotifier> get notifiers => throw UnimplementedError();

//   @override
//   List<Subject> get subjects => throw UnimplementedError();
// }
