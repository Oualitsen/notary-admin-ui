import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/assistant/assistant_details_input.dart';
import 'package:notary_admin/src/pages/assistant/assistant_credentials_input.dart';
import 'package:notary_admin/src/services/assistant/assistant_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:notary_model/model/role.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';

class AddAssistantPage extends StatefulWidget {
  const AddAssistantPage({super.key});

  @override
  State<AddAssistantPage> createState() => _AddAssistantPageState();
}

class _AddAssistantPageState extends BasicState<AddAssistantPage>
    with WidgetUtilsMixin {
  final assistantCredentilasKey = GlobalKey<AssistantCredentailsInputState>();
  final assistantDetailsKey = GlobalKey<AssistantDetailsInputState>();
  final _currentStepStream = BehaviorSubject.seeded(0);
  late AssistantDetails assistantDetails;
  late AssistantCredentials assistantCredentials;
  final service = GetIt.instance.get<AssistantService>();
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.newAssistant),
        ),
        body: StreamBuilder<int>(
          stream: _currentStepStream,
          initialData: _currentStepStream.value,
          builder: (context, snapshot) {
            int activeState = snapshot.data ?? 0;
            return Stepper(
              //type: getStepperType(type),
              physics: ScrollPhysics(),
              currentStep: activeState,
              onStepTapped: (step) => tapped(step),
              controlsBuilder: (context, _) {
                return SizedBox.shrink();
              },
              steps: <Step>[
                Step(
                  title: Text(lang.general.toUpperCase()),
                  content: Column(
                    children: [
                      AssistantDetailsInput(
                        key: assistantDetailsKey,
                        //   assistant: widget.assistant,
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
                  title: Text(lang.credentails.toUpperCase()),
                  content: Column(children: [
                    AssistantCredentailsInput(
                      key: assistantCredentilasKey,
                      //      assistant: widget.assistant,
                    ),
                    SizedBox(height: 16),
                    getButtons(
                        onSave: continued,
                        saveLabel: lang.submit.toUpperCase(),
                        cancelLabel: lang.previous.toUpperCase(),
                        onCancel: previous),
                  ]),
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
          var details = assistantDetailsKey.currentState?.readDetails();
          if (details != null) {
            assistantDetails = details;
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {
          try{
          var credentials =
              await assistantCredentilasKey.currentState!.readCredentails();

          if (credentials != null) {
            assistantCredentials = credentials;
            await save();
          } else {
            print("@@@@@@@@@@@@@ error");
          }
 } catch (error, stacktrace) {
                  showServerError(context, error: error);
                  print(stacktrace);
                }
        }
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
      var input = AssistantInput(
          firstName: assistantDetails.firstName,
          lastName: assistantDetails.lastName,
          username: assistantCredentials.username,
          password: assistantCredentials.password,
          roles: Set.of([Role.ASSISTANT]),
          gender: assistantDetails.gender);
      var res = await service.saveAssistant(input);
      await showSnackBar2(context, lang.updatedSuccessfully);
      Navigator.of(context).pop(res);
    } catch (error, stackTrace) {
      showServerError(context, error: error);
      print(stackTrace);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
