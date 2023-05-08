import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/file-spec/document/add_parts_spec.dart';
import 'package:notary_admin/src/pages/file-spec/file_spec_page.dart';
import 'package:notary_admin/src/pages/steps/step_selection_widget.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/contractc_category_list_widget.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/files_spec_input.dart';
import 'package:notary_model/model/parts_spec_input.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:notary_model/model/steps.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rxdart/rxdart.dart';

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
  //service
  final fileSpecService = GetIt.instance.get<FileSpecService>();
  final templateService = GetIt.instance.get<TemplateDocumentService>();
  //stream
  final currentStepStream = BehaviorSubject.seeded(0);
  final partsSpecInputStream = BehaviorSubject.seeded(<PartsSpecInput>[]);
  final templateIdStream = BehaviorSubject.seeded('');
  final stepsStream = BehaviorSubject.seeded(<Steps>[]);
  //key
  final GlobalKey<FormState> inputKey = GlobalKey<FormState>();
  //controller
  final fileSpecNameCtrl = TextEditingController();
  final fileSpecTemplateCtrl = TextEditingController();
  //late final List<ContractCategory> contractCategories = [];
  final contractCategories = BehaviorSubject<ContractCategory>();

  //variables
  List<PartsSpecInput> listPartsSpecInput = [];
  late FilesSpec fileSpec;
  int currentStep = 0;

  @override
  void initState() {
    var fileSpec = widget.fileSpec;
    if (fileSpec != null) {
      stepsStream.add(fileSpec.steps);
      fileSpecNameCtrl.text = fileSpec.name;
      listPartsSpecInput = fileSpec.partsSpecs
          .map((e) =>
              PartsSpecInput(id: e.id, name: e.name, documentSpecInputs: []))
          .toList();
      partsSpecInputStream.add(listPartsSpecInput);
      templateIdStream.add(fileSpec.templateId);
      templateService
          .getTemplate(fileSpec.templateId)
          .then((value) => fileSpecTemplateCtrl.text = value.name);
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
          stream: currentStepStream,
          initialData: currentStepStream.value,
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
                        key: inputKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: fileSpecNameCtrl,
                              decoration:
                                  getDecoration(lang.name, true, lang.name),
                              validator: (text) {
                                return ValidationUtils.requiredField(
                                    text, context);
                              },
                            ),
                            SizedBox(height: 16),
                            wrapInIgnorePointer(
                              child: TextFormField(
                                  controller: fileSpecTemplateCtrl,
                                  decoration: getDecoration(lang.selectTemplate,
                                      true, lang.selectTemplate),
                                  validator: (text) {
                                    return ValidationUtils.requiredField(
                                        text, context);
                                  }),
                              onTap: selectTemplate,
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
                        onPressed: snapshot.data == 1 ? selectCustomers : null,
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                  content: StreamBuilder<List<Steps>>(
                      stream: stepsStream,
                      initialData: stepsStream.value,
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return SizedBox.shrink();
                        }
                        if (snapshot.data!.isEmpty) {
                          return Row(
                            children: [
                              Icon(Icons.warning_outlined),
                              SizedBox(width: 16),
                              Text(lang.noStepsSelected.toUpperCase()),
                            ],
                          );
                        }
                        var index = -1;
                        return Column(
                          children: [
                            Column(
                                children: snapshot.data!.map((step) {
                              index++;
                              return ListTile(
                                leading:
                                    CircleAvatar(child: Text("${(index + 1)}")),
                                title: Text("${step.name}"),
                                trailing: TextButton.icon(
                                    onPressed: () {
                                      deleteStep(index);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(context).canvasColor,
                                    ),
                                    label: Text(lang.delete.toUpperCase())),
                              );
                            }).toList()),
                            SizedBox(height: 16),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: previous,
                                    child: Text(lang.previous.toUpperCase())),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                    onPressed: snapshot.data!.isNotEmpty
                                        ? continued
                                        : null,
                                    child: Text(lang.next.toUpperCase())),
                              ],
                            ),
                          ],
                        );
                      }),
                  isActive: activeState == 1,
                  state: getState(1),
                ),
                Step(
                  title: Text(lang.selecteContractCategory.toUpperCase()),
                  content: Column(
                    children: [
                      SizedBox(height: 50),
                      SizedBox(
                        height: 250,
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: ContractCategoryListWidget(
                            selectContractCategory: (contractCategory) {
                              contractCategories.add(contractCategory);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: previous,
                              child: Text(lang.previous.toUpperCase())),
                          SizedBox(
                            width: 20,
                          ),
                          StreamBuilder<ContractCategory?>(
                              stream: contractCategories,
                              builder: (context, snapshot) {
                                return ElevatedButton(
                                    onPressed: snapshot.data != null
                                        ? continued
                                        : null,
                                    child: Text(lang.next.toUpperCase()));
                              }),
                        ],
                      ),
                    ],
                  ),
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
                        if (snapshot.data!.isEmpty) {
                          return Row(
                            children: [
                              Icon(Icons.warning_outlined),
                              SizedBox(width: 16),
                              Text(lang.noSelectedParts.toUpperCase()),
                            ],
                          );
                        }
                        var index = -1;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: partsSpecInputStream.value.map((part) {
                                index++;
                                return ListTile(
                                  leading: CircleAvatar(
                                      child: Text("${(index + 1)}")),
                                  title: Text("${part.name}"),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      var list = partsSpecInputStream.value;
                                      list.removeAt(index);
                                      partsSpecInputStream.add(list);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 16),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: previous,
                                    child: Text(lang.previous.toUpperCase())),
                                SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                    onPressed:
                                        snapshot.data!.isNotEmpty ? save : null,
                                    child: Text(lang.submit.toUpperCase())),
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
    currentStepStream.add(step);
  }

  previous() {
    int value = currentStepStream.value;
    value > 0 ? value -= 1 : value = 0;
    currentStepStream.add(value);
  }

  continued() async {
    var value = currentStepStream.value;
    switch (value) {
      case 0:
        if (inputKey.currentState?.validate() ?? false) {
          currentStepStream.add(currentStepStream.value + 1);
        }
        break;

      case 1:
        if (stepsStream.value.isNotEmpty) {
          currentStepStream.add(currentStepStream.value + 1);
        }
        break;
      case 2:
        if (contractCategories.valueOrNull != null) {
          currentStepStream.add(currentStepStream.value + 1);
        }

        break;
      case 3:
        save();
        break;
    }
  }

  StepState getState(int currentState) {
    final value = currentStepStream.value;
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
            contractCategoryId: contractCategories.value.id,
            steps: stepsStream.value,
            name: fileSpecNameCtrl.text,
            partsSpecInput: partsSpecInputStream.value,
            id: null,
            templateId: templateIdStream.value);
        await fileSpecService.saveFileSpec(input);
        await showSnackBar2(context, lang.savedSuccessfully);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FileSpecPage()));
      } else {
        var update = FilesSpecInput(
            contractCategoryId: null,
            steps: stepsStream.value,
            name: fileSpecNameCtrl.text,
            partsSpecInput: partsSpecInputStream.value,
            id: widget.fileSpec!.id,
            templateId: templateIdStream.value);
        if (partsSpecInputStream.value.isNotEmpty) {
          await fileSpecService.saveFileSpec(update);
          await showSnackBar2(context, lang.updatedSuccessfully);
          push(context, FileSpecPage());
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
      var result = templateService.getTemplates(pageIndex: index, pageSize: 10);

      return result;
    }
    return Future.value([]);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void selectTemplate() {
    ReusedWidgets.showDialog2(
      context,
      label: lang.selectTemplate,
      content: InfiniteScrollListView(
          elementBuilder: ((context, element, index, animation) {
            return ListTile(
              title: Text(element.name),
              onTap: () {
                fileSpecTemplateCtrl.text = element.name;
                templateIdStream.add(element.id);
                Navigator.of(context).pop(true);
              },
            );
          }),
          refreshable: true,
          pageLoader: getTemplates),
    );
  }

  void deleteStep(int currentStepIndex) {
    var list = stepsStream.value;
    list.removeAt(currentStepIndex);
    stepsStream.add(list);
  }

  selectCustomers() {
    Navigator.push<List<Steps>>(
      context,
      MaterialPageRoute(
          builder: (context) => StepsSelection(
                selectionType: SelectionType.MULTIPLE,
              )),
    ).then((value) async {
      if (value != null) {
        stepsStream.add(value);
        if (stepsStream.value.isEmpty) {
          await showSnackBar2(context, lang.noSteps);
        }
      }
    });
  }
}
