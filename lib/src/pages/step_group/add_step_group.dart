import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/step_group/step_group_page.dart';
import 'package:notary_admin/src/pages/steps/step_selection_widget.dart';
import 'package:notary_admin/src/services/admin/step_group_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:notary_model/model/step_group.dart';
import 'package:notary_model/model/step_group_input.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/subjects.dart';

class AddStepGroup extends StatefulWidget {
  const AddStepGroup({super.key});

  @override
  State<AddStepGroup> createState() => _AddStepGroupState();
}

class _AddStepGroupState extends BasicState<AddStepGroup>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<StepGroupService>();
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _listStepsStream = BehaviorSubject.seeded(<Steps>[]);
  final templateIdStream = BehaviorSubject.seeded('');
  final GlobalKey<FormState> _stepGroupNameKey = GlobalKey<FormState>();
  final _nameStepGroupCtrl = TextEditingController();
  late StepGroup stepGroup;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.addStepGroup),
        ),
        body: StreamBuilder<int>(
          stream: _currentStepStream,
          initialData: _currentStepStream.value,
          builder: (context, snapshot) {
            int activeState = snapshot.data ?? 0;

            return Stepper(
              physics: ScrollPhysics(),
              currentStep: activeState,
              onStepTapped: (step) => tapped(step),
              controlsBuilder: (context, _) {
                return SizedBox.shrink();
              },
              steps: <Step>[
                Step(
                  title: Text(lang.name.toUpperCase()),
                  content: Column(
                    children: [
                      Form(
                        key: _stepGroupNameKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _nameStepGroupCtrl,
                              decoration:
                                  getDecoration(lang.name, true, lang.name),
                              validator: (text) {
                                return ValidationUtils.requiredField(
                                    text, context);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      getButtons(
                          onSave: continued,
                          skipCancel: true,
                          saveLabel: lang.next.toUpperCase()),
                    ],
                  ),
                  isActive: activeState == 0,
                  state: getState(0),
                ),
                Step(
                  title: Row(
                    children: [
                      Text(lang.steps.toUpperCase()),
                      SizedBox(
                        width: 40,
                      ),
                      ElevatedButton(
                        onPressed: snapshot.data == 1
                            ? () {
                                Navigator.push<List<Steps>>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StepsSelection(
                                            selectionType:
                                                SelectionType.MULTIPLE,
                                          )),
                                ).then((value) async {
                                  if (value != null) {
                                    _listStepsStream.add(value);
                                    if (_listStepsStream.value.isEmpty) {
                                      await showSnackBar2(
                                          context, lang.noCustomer);
                                    }
                                  }
                                });
                              }
                            : null,
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  content: StreamBuilder<List<Steps>>(
                      stream: _listStepsStream,
                      initialData: _listStepsStream.value,
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            SizedBox(
                                height: 400,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    var currentStep = snapshot.data![index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                          child: Text("${(index + 1)}")),
                                      title: Text("${currentStep.name}"),
                                      trailing: TextButton.icon(
                                          onPressed: () {
                                            deleteStep(index);
                                          },
                                          icon: Icon(Icons.delete),
                                          label: Text(lang.delete)),
                                    );
                                  },
                                )),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: previous,
                                    child: Text(lang.previous)),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                    onPressed: _listStepsStream.value.isNotEmpty
                                        ? save
                                        : null,
                                    child: Text(lang.submit)),
                              ],
                            ),
                          ],
                        );
                      }),
                  isActive: activeState == 1,
                  state: getState(1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  tapped(int step) {
    _currentStepStream.add(step);
  }

  previous() {
    int value = _currentStepStream.value;
    value > 0 ? value -= 1 : value = 0;
    _currentStepStream.add(value);
  }

  continued() async {
    var value = _currentStepStream.value;

    switch (value) {
      case 0:
        {
          if (_stepGroupNameKey.currentState?.validate() ?? false) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {}
        break;
    }
  }

  StepState getState(int currentState) {
    final value = _currentStepStream.value;
    if (value >= currentState) {
      return StepState.complete;
    } else {
      return StepState.disabled;
    }
  }

  save() async {
    try {
      // if (widget.stepGroup == null) {

      var input = StepGroupInput(
          id: null,
          name: _nameStepGroupCtrl.text,
          steps: _listStepsStream.value);
      if (_listStepsStream.value.isNotEmpty) {
        await service.saveStepGroup(input);
        await showSnackBar2(context, lang.savedSuccessfully);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => StepGroupPage()));
      } else {
        await showSnackBar2(context, "${lang.stepsEmptyError}");
      }
   
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  deleteStep(int currentStepIndex) {
    var list = _listStepsStream.value;
    list.removeAt(currentStepIndex);
    _listStepsStream.add(list);
  }
}
