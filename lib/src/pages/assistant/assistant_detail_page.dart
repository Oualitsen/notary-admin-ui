import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/assistant/add_assistant_page.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:notary_model/model/gender.dart';
import 'package:notary_model/model/role.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

import '../../services/assistant/assistant_service.dart';
import '../../widgets/password_input.dart';
import 'assistant_credentials_input.dart';

class AssistantDetailsPage extends StatefulWidget {
  static const home = "/";
  final Assistant assistant;
  AssistantDetailsPage({Key? key, required this.assistant}) : super(key: key);

  @override
  State<AssistantDetailsPage> createState() => _AssistantDetailsPageState();
}

class _AssistantDetailsPageState extends BasicState<AssistantDetailsPage>
    with WidgetUtilsMixin {
  final _currentStepStream = BehaviorSubject.seeded(0);
  final service = GetIt.instance.get<AssistantService>();
  //late Assistant assistant;
  final newPwdCtr = TextEditingController();
  final GlobalKey<FormState> _formKeyNewPassword = GlobalKey<FormState>();
  late Assistant assistant;

  @override
  void initState() {
    assistant = widget.assistant;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var assistant = widget.assistant;

    var myTabs = [
      Tab(
        text: "Informations",
        height: 50,
      ),
    ];
    return DefaultTabController(
      length: myTabs.length,
      child: WidgetUtils.wrapRoute(
        (context, type) => Scaffold(
          appBar: AppBar(
            title: Text("${assistant.firstName} ${assistant.lastName}"),
            actions: [
              TextButton.icon(
                label: Text(
                  lang.edit.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  push<Assistant>(context, AddAssistantPage())
                      .listen((c) => setState(() => assistant = c));
                },
              ),
              TextButton.icon(
                label: Text(
                  lang.resetPassword.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  Icons.restore,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            width: 400,
                            height: 50,
                            color: Colors.blue,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  assistant.lastName,
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                                SizedBox(width: 30),
                                Text(assistant.firstName,
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white)),
                              ],
                            ),
                          ),
                          content: Container(
                            height: 200,
                            width: 400,
                            child: Column(
                              children: [
                                Text(lang.resetPassword.toUpperCase()),
                                Column(children: [
                                  Form(
                                    key: _formKeyNewPassword,
                                    child: PasswordInput(
                                      controller: newPwdCtr,
                                      label: Text(lang.newPassword),
                                      validator: (text) {
                                        if (text?.isEmpty ?? true) {
                                          return lang.requiredField;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  getButtons(
                                    onSave: setPasswordAssistant,
                                    saveLabel: lang.submit.toUpperCase(),
                                    cancelLabel: lang.cancel.toUpperCase(),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
            bottom: TabBar(tabs: myTabs),
          ),
          body: TabBarView(
            children: [
              Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(right: 30),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(lang.lastName),
                        subtitle: Text(assistant.lastName),
                      ),
                      ListTile(
                        title: Text(lang.firstName),
                        subtitle: Text(assistant.firstName),
                      ),
                      ListTile(
                        title: Text(lang.gender),
                        subtitle: Text(assistant.gender.name),
                      ),
                    ],
                  ))
            ],
          ),
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

  continued() async {}

  StepState getState(int currentState) {
    final value = _currentStepStream.value;
    if (value >= currentState) {
      return StepState.complete;
    } else {
      return StepState.disabled;
    }
  }

  setPasswordAssistant() async {
    if (_formKeyNewPassword.currentState!.validate() || true) {
      // Process data.
      var result =
          await service.ResetPasswordAssistant(assistant.id, newPwdCtr.text);
      showSnackBar2(context, lang.passwordChanged);

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      Navigator.pop(context);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
