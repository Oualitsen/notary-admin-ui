import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/assistant/add_assistant_page.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:notary_model/model/gender.dart';
import 'package:notary_model/model/role.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

class FormConvertMap extends StatefulWidget {
  static const home = "/";
  final listFormField;
  FormConvertMap({
    Key? key,
    required this.listFormField,
  }) : super(key: key);

  @override
  State<FormConvertMap> createState() => _FormConvertMapState();
}

class _FormConvertMapState extends BasicState<FormConvertMap>
    with WidgetUtilsMixin {
  //final _currentStepStream = BehaviorSubject.seeded(0);
  //final service = GetIt.instance.get<AssistantService>();
  //late Assistant assistant;
  final lastNameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final dateOfBirthCtrl = TextEditingController();
  late List listFormField;

  Map map = Map<String, String>();

  final GlobalKey<FormState> _formKeyListNames = GlobalKey<FormState>();
  final GlobalKey<FormState> _keylastName = GlobalKey<FormState>();
  late List<TextEditingController> _controller =
      List.generate(listFormField.length, (i) => TextEditingController());

  @override
  void initState() {
    List<TextEditingController> _controller = [];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Convert To map"),
        actions: [],
      ),
      body: Container(
          padding: EdgeInsets.all(30),
          width: 400,
          height: double.maxFinite,
          child: Form(
              key: _formKeyListNames,
              child: Column(
                children: [
                  Container(
                    width: 400,
                    height: 300,
                    child: ListView.builder(
                      itemCount: listFormField.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: listFormField[index],
                              ),
                              controller: _controller[index],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your text';
                                }
                                map[listFormField[index]] =
                                    _controller[index].text;
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        convertToMap();
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ))),
    );
  }

  convertToMap() {
    if (_formKeyListNames.currentState!.validate() || true) {
      // Process data.
      print(map);

      showSnackBar2(context, "Convert succes");

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      return map;
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
