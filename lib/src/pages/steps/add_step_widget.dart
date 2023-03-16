import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/step_input.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AddStepWidget extends StatefulWidget {
  final Steps? step;
  const AddStepWidget({super.key, this.step});

  @override
  State<AddStepWidget> createState() => AddStepWidgetState();
}

class AddStepWidgetState extends BasicState<AddStepWidget>
    with WidgetUtilsMixin {
  final key = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final estimatedTimeController = TextEditingController();

  @override
  void initState() {
    if (widget.step != null) {
      nameController.text = widget.step!.name;
      estimatedTimeController.text = widget.step!.estimatedTime.toString();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (text) {
                return ValidationUtils.requiredField(text, context);
              },
              controller: nameController,
              decoration: (getDecoration(lang.name, true, lang.name))),
          const SizedBox(height: 16),
          TextFormField(
            validator: (text) {
              return ValidationUtils.requiredField(text, context);
            },
            controller: estimatedTimeController,
            decoration:
                (getDecoration(lang.estimationTime, true, lang.estimationTime)),
          ),
        ],
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  StepInput? read() {
    if (key.currentState?.validate() ?? false) {
      String? id = widget.step?.id ?? null;

      return StepInput(
          id: id,
          name: nameController.text,
          estimatedTime: int.tryParse(estimatedTimeController.text) ?? 0);
    }
    return null;
  }
}
