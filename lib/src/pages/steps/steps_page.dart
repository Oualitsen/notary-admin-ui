import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/steps/add_step_widget.dart';
import 'package:notary_admin/src/pages/steps/steps_table_widget.dart';
import 'package:notary_admin/src/services/admin/steps_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/step_input.dart';
import 'package:rxdart/src/subjects/subject.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends BasicState<StepsPage> with WidgetUtilsMixin {
  final service = GetIt.instance.get<StepsService>();
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();
  final stepKey = GlobalKey<AddStepWidgetState>();
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.steps),
          ),
          floatingActionButton: ElevatedButton(
            onPressed: () {
              addNewStep(context);
            },
            child: Text(lang.addSteps),
          ),
          body: Padding(
              padding: EdgeInsets.all(20),
              child: StepsTableWidget(tableKey: tableKey)),
        ));
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void addNewStep(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.addSteps),
            content: AddStepWidget(
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
        var res = await service.saveStep(value);
        tableKey.currentState?.add(res);
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
