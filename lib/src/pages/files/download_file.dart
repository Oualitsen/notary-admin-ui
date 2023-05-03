import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/formula/contract_function_input_widget.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/src/subjects/subject.dart';

class DowloadFile extends StatefulWidget {
  const DowloadFile({super.key});

  @override
  State<DowloadFile> createState() => _DowloadFileState();
}

class _DowloadFileState extends BasicState<DowloadFile> with WidgetUtilsMixin {
  final lowerBoundCrl = TextEditingController();
  final upperBoundCtl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(body: ContractFunctionInputWidget(onRead: (ContractFunction ) {  },)),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
