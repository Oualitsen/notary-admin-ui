import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/file-spec/document/add_parts_spec.dart';
import 'package:notary_admin/src/pages/file-spec/file_spec_List.dart';
import 'package:notary_admin/src/pages/steps/step_selection_widget.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/files_spec_input.dart';
import 'package:notary_model/model/parts_spec_input.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:notary_model/model/steps.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rxdart/rxdart.dart';

import 'document/add_document.dart';
import 'document/document_table_widget.dart';

class AddFileSpec extends StatefulWidget {
  final FilesSpec? fileSpec;
  const AddFileSpec({
    super.key,
    this.fileSpec,
  });

  @override
  State<AddFileSpec> createState() => _AddFileSpecState();
}

class _AddFileSpecState extends BasicState<AddFileSpec> with WidgetUtilsMixin {
  int currentStep = 0;
  final service = GetIt.instance.get<FileSpecService>();
  final serviceTemplate = GetIt.instance.get<TemplateDocumentService>();
  final _currentStepStream = BehaviorSubject.seeded(0);
  final partsSpecInputStream = BehaviorSubject.seeded(<PartsSpecInput>[]);
  final templateIdStream = BehaviorSubject.seeded('');
  final _listStepsStream = BehaviorSubject.seeded(<Steps>[]);
  final GlobalKey<FormState> _fileSpecNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _templateFileSpecKey = GlobalKey<FormState>();
  final _nameFileSpecCtrl = TextEditingController();
  final _templateFileSpecCtrl = TextEditingController();
  List<PartsSpecInput> listPartsSpecInput = [];
  late FilesSpec fileSpec;

  @override
  void initState() {
    var fileSpec = widget.fileSpec;
    if (fileSpec != null) {
      _listStepsStream.add(fileSpec.steps);
      _nameFileSpecCtrl.text = fileSpec.name;

      listPartsSpecInput = fileSpec.partsSpecs
          .map((e) =>
              PartsSpecInput(id: e.id, name: e.name, documentSpecInputs: []))
          .toList();
      partsSpecInputStream.add(listPartsSpecInput);
      templateIdStream.add(fileSpec.templateId);
      serviceTemplate
          .getTemplate(fileSpec.templateId)
          .then((value) => _templateFileSpecCtrl.text = value.name);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.addPart),
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
                        key: _fileSpecNameKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _nameFileSpecCtrl,
                              decoration:
                                  getDecoration(lang.name, true, lang.name),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return lang.requiredField;
                                }
                                return null;
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
                  title: Text(lang.templates.toUpperCase()),
                  content: Column(
                    children: [
                      Form(
                        key: _templateFileSpecKey,
                        child: TextFormField(
                            readOnly: true,
                            controller: _templateFileSpecCtrl,
                            decoration: getDecoration(
                                lang.selectTemplate, true, lang.selectTemplate),
                            onTap: selectTemplate,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return lang.requiredField;
                              }
                              return null;
                            }),
                      ),
                      SizedBox(height: 16),
                      getButtons(
                        onSave: continued,
                        onCancel: previous,
                        saveLabel: lang.next,
                        cancelLabel: lang.previous,
                      ),
                    ],
                  ),
                  isActive: activeState == 1,
                  state: getState(1),
                ),
                Step(
                  title: Row(
                    children: [
                      Text(lang.steps.toUpperCase()),
                      SizedBox(
                        width: 40,
                      ),
                      ElevatedButton(
                        onPressed: snapshot.data == 2
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
                                          context, lang.noSteps);
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
                                height: 200,
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
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: previous,
                                    child: Text(lang.previous)),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                    onPressed: snapshot.data!.isNotEmpty
                                        ? continued
                                        : null,
                                    child: Text(lang.next)),
                              ],
                            ),
                          ],
                        );
                      }),
                  isActive: activeState == 2,
                  state: getState(2),
                ),
                Step(
                  title: Row(
                    children: [
                      Text(lang.listPart.toUpperCase()),
                      SizedBox(
                        width: 40,
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: snapshot.data == 3
                            ? () {
                                Navigator.push<PartsSpecInput>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddPartsSpecPage()),
                                ).then((value) {
                                  if (value != null) {
                                    var list = partsSpecInputStream.value;
                                    list.add(value);
                                    partsSpecInputStream.add(list);
                                  }
                                });
                              }
                            : null,
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  content: StreamBuilder<List<PartsSpecInput>>(
                      stream: partsSpecInputStream,
                      initialData: partsSpecInputStream.value,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: partsSpecInputStream.value.length,
                                itemBuilder: (context, index) {
                                  var part = partsSpecInputStream.value[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                        child: Text("${(index + 1)}")),
                                    title: Text("${part.name}"),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => null,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: previous,
                                    child: Text(lang.previous)),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                    onPressed:
                                        snapshot.data!.isNotEmpty ? save : null,
                                    child: Text(lang.submit)),
                              ],
                            ),
                          ],
                        );
                      }),
                  isActive: activeState == 3,
                  state: getState(3),
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
          if (_fileSpecNameKey.currentState?.validate() ?? false) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {
          if (_templateFileSpecKey.currentState?.validate() ?? false) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 2:
        if (_listStepsStream.value.isNotEmpty) {
          _currentStepStream.add(_currentStepStream.value + 1);
        }
        break;
      case 3:
        {
          save();
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
      if (widget.fileSpec == null) {
        var input = FilesSpecInput(
            steps: _listStepsStream.value,
            name: _nameFileSpecCtrl.text,
            partsSpecInput: partsSpecInputStream.value,
            id: null,
            templateId: templateIdStream.value);
        await service.saveFileSpec(input);
        await showSnackBar2(context, lang.savedSuccessfully);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FileSpecList()));
      } else {
        var update = FilesSpecInput(
            steps: _listStepsStream.value,
            name: _nameFileSpecCtrl.text,
            partsSpecInput: partsSpecInputStream.value,
            id: widget.fileSpec!.id,
            templateId: templateIdStream.value);
        if (partsSpecInputStream.value.isNotEmpty) {
          await service.saveFileSpec(update);
          await showSnackBar2(context, lang.updatedSuccessfully);
          push(context, FileSpecList());
        } else {
          await showSnackBar2(
              context, " ${lang.listDocumentsFileSpec}   ${lang.empty}");
        }
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  Future<List<TemplateDocument>> getTemplates(int index) {
    if (index == 0) {
      var result = serviceTemplate.getTemplates(pageIndex: index, pageSize: 10);

      return result;
    }
    return Future.value([]);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void selectTemplate() {
    WidgetMixin.showDialog2(
      context,
      label: lang.selectTemplate,
      content: SizedBox(
        width: 400,
        height: 300,
        child: InfiniteScrollListView(
            elementBuilder: ((context, element, index, animation) {
              return ListTile(
                title: Text(element.name),
                onTap: () {
                  _templateFileSpecCtrl.text = element.name;
                  templateIdStream.add(element.id);
                  Navigator.of(context).pop(true);
                },
              );
            }),
            refreshable: true,
            pageLoader: getTemplates),
      ),
    );
  }

  void deleteStep(int currentStepIndex) {
    var list = _listStepsStream.value;
    list.removeAt(currentStepIndex);
    _listStepsStream.add(list);
  }
}
