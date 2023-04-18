import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_dialog.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_parts_documents.dart';
import 'package:notary_admin/src/pages/templates/form_and_view_html.dart';
import 'package:notary_admin/src/pages/templates/upload_template.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/printed_doc_input.dart';
import 'package:rxdart/rxdart.dart';

import 'files_page.dart';

class AddFilesCustomer extends StatefulWidget {
  const AddFilesCustomer({
    super.key,
  });
  @override
  State<AddFilesCustomer> createState() => _AddFilesCustomerState();
}

class _AddFilesCustomerState extends BasicState<AddFilesCustomer>
    with WidgetUtilsMixin {
  int currentStep = 0;
  //services
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  final serviceTemplateDocument = GetIt.instance.get<TemplateDocumentService>();
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  //Stream
  final currentStepStream = BehaviorSubject.seeded(0);
  final printedDocInputStream = BehaviorSubject<PrintedDocInput>();
  final customersStream = BehaviorSubject.seeded(<Customer>[]);

  final folderValidateStream = BehaviorSubject.seeded(false);
  final filesSpecStream = BehaviorSubject<FilesSpec>();
  final additionalDocumentsStream = BehaviorSubject.seeded(<UploadData>[]);
  final _pathDocumentsStream = BehaviorSubject.seeded(<DocumentUploadInfos>[]);
  //Key
  final selectFileSpecKey = GlobalKey<FormState>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  //controlers
  final _selectFileSpecCtrl = TextEditingController();
  final _numberFileCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.addfolder),
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
                    title: Text(lang.general.toUpperCase()),
                    content: generalFormWidget(),
                    isActive: activeState == 0,
                    state: getState(0),
                  ),
                  Step(
                    title: selectCustomerTitleWidget(),
                    content: Column(
                      children: [
                        StreamBuilder<List<Customer>>(
                            stream: customersStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              //
                              return WidgetMixin.ListCustomers(
                                context,
                                listCustomers: customersStream.value,
                              );
                            }),
                        getButtons(
                            onSave: continued,
                            onCancel: previous,
                            saveLabel: lang.next.toUpperCase(),
                            cancelLabel: lang.previous.toUpperCase()),
                      ],
                    ),
                    isActive: activeState == 1,
                    state: getState(1),
                  ),
                  Step(
                    title: Text(lang.selectDocuments.toUpperCase()),
                    content: Column(
                      children: [
                        StreamBuilder<FilesSpec>(
                            stream: filesSpecStream,
                            initialData: filesSpecStream.valueOrNull,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }

                              return UploadPartsDocumentsWidget(
                                filesSpec: snapshot.data!,
                                onNext: (pathDocumentList) {
                                  _pathDocumentsStream.add(pathDocumentList);
                                },
                              );
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        getButtons(
                          onSave: continued,
                          onCancel: previous,
                          saveLabel: lang.next.toUpperCase(),
                          cancelLabel: lang.previous.toUpperCase(),
                        )
                      ],
                    ),
                    isActive: activeState == 2,
                    state: getState(2),
                  ),
                  Step(
                    title: Row(
                      children: [
                        Text(lang.completeTemplate.toUpperCase()),
                        SizedBox(
                          width: 20,
                        ),
                        StreamBuilder<int>(
                            stream: currentStepStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }
                              return ButtonBar(children: [
                                ElevatedButton(
                                  onPressed: snapshot.data == 3
                                      ? () => generateForm()
                                      : null,
                                  child: Icon(Icons.add),
                                ),
                              ]);
                            }),
                      ],
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        StreamBuilder<PrintedDocInput>(
                            stream: printedDocInputStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return Text(
                                    lang.noTemplateInstance.toUpperCase());
                              }

                              return ListTile(
                                subtitle: Text("${lang.documentName}"),
                                title: Text("${snapshot.data!.name}"),
                              );
                            }),
                        StreamBuilder<bool>(
                            stream: folderValidateStream,
                            initialData: false,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }
                              return getButtons(
                                onSave: snapshot.data! ? continued : null,
                                onCancel: previous,
                                saveLabel: lang.next.toUpperCase(),
                                cancelLabel: lang.previous.toUpperCase(),
                              );
                            }),
                      ],
                    ),
                    isActive: activeState == 3,
                    state: getState(3),
                  ),
                  Step(
                    title: Row(
                      children: [
                        Text(lang.additionalDocuments.toUpperCase()),
                        SizedBox(
                          width: 20,
                        ),
                        StreamBuilder<int>(
                            stream: currentStepStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }
                              return ButtonBar(children: [
                                ElevatedButton(
                                  onPressed:
                                      snapshot.data == 4 ? loadFiles : null,
                                  child: Icon(Icons.add),
                                ),
                              ]);
                            }),
                      ],
                    ),
                    content: Column(
                      children: [
                        StreamBuilder<List<UploadData>>(
                            stream: additionalDocumentsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }
                              var index = -1;
                              return Column(
                                children: snapshot.data!.map((data) {
                                  index++;
                                  return ListTile(
                                    leading: CircleAvatar(
                                        child: Text("${(index + 1)}")),
                                    title: Text("${data.name}"),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        var list =
                                            additionalDocumentsStream.value;
                                        list.remove(data);
                                        additionalDocumentsStream.add(list);
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            }),
                        getButtons(
                            onSave: save,
                            onCancel: previous,
                            saveLabel: lang.submit.toUpperCase(),
                            cancelLabel: lang.previous.toUpperCase())
                      ],
                    ),
                    isActive: activeState == 4,
                    state: getState(4),
                  )
                ],
              );
            }),
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
        {
          if (selectFileSpecKey.currentState?.validate() ?? false) {
            currentStepStream.add(currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {
          if (customersStream.value.isNotEmpty) {
            currentStepStream.add(currentStepStream.value + 1);
          } else {
            await showSnackBar2(context, lang.noCustomer);
          }
        }

        break;
      case 2:
        {
          currentStepStream.add(currentStepStream.value + 1);
        }
        break;
      case 3:
        currentStepStream.add(currentStepStream.value + 1);

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

  Future<List<FilesSpec>> getFilesSpec(int index) {
    var result = serviceFileSpec.getFileSpecs(pageIndex: index, pageSize: 10);
    return result;
  }

  save() async {
    try {
      progressSubject.add(true);
      if (selectFileSpecKey.currentState!.validate() &&
          customersStream.value.isNotEmpty &&
          folderValidateStream.value) {
        var listCustomersIds = customersStream.value.map((e) => e.id).toList();

        var input = FilesInput(
          id: null,
          number: _numberFileCtrl.text,
          customerIds: listCustomersIds,
          uploadedFiles: [],
          specification: filesSpecStream.value,
          printedDocInput: printedDocInputStream.value,
          additionalDocumentIds: [],
        );
        var files = await serviceFiles.saveFiles(input);

        if (_pathDocumentsStream.value.isNotEmpty) {
          await WidgetMixin.uploadFiles(
              context, files.id, _pathDocumentsStream.value);
        }
        if (additionalDocumentsStream.value.isNotEmpty) {
          await WidgetMixin.uploadAdditionalData(
              context, files.id, additionalDocumentsStream.value);
        }
        await showSnackBar2(context, lang.createdsuccssfully);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FilesPage()));
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

  void selectFileSpec() {
    WidgetMixin.showDialog2(
      context,
      label: lang.selectFileSpec.toUpperCase(),
      content: InfiniteScrollListView(
          elementBuilder: ((context, element, index, animation) {
            return ListTile(
              title: Text("${element.name}"),
              onTap: () {
                _selectFileSpecCtrl.text = element.name;
                filesSpecStream.add(element);
                Navigator.of(context).pop(true);
              },
            );
          }),
          refreshable: true,
          pageLoader: getFilesSpec),
    );
  }

  generateForm() async {
    try {
      var finalList = <String>[];
      var list = await serviceTemplateDocument
          .formGenerating(filesSpecStream.value.templateId);
      for (var res in list) {
        finalList.add(res.replaceAll(RegExp(r' '), "_"));
      }
      var data = await serviceTemplateDocument
          .replacements(filesSpecStream.value.templateId);

      Navigator.push<PrintedDocInput>(
          context,
          MaterialPageRoute(
              builder: (context) => FormAndViewHtml(
                    listFormField: finalList,
                    text: data,
                  ))).then((value) {
        if (value != null) {
          printedDocInputStream.add(value);
          folderValidateStream.add(true);
        }
      });
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  Future loadFiles() async {
    try {
      var pickedFile = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      if (pickedFile != null) {
        var path = null;
        if (!kIsWeb) {
          path = pickedFile.files.first.path;
        }
        var data = UploadData(
            data: pickedFile.files.first.bytes,
            name: pickedFile.files.first.name,
            path: path);
        var list = additionalDocumentsStream.value;
        list.add(data);
        additionalDocumentsStream.add(list);
      }
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
      throw error;
    }
  }

  Widget generalFormWidget() {
    return Form(
        key: selectFileSpecKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _numberFileCtrl,
              decoration:
                  getDecoration(lang.filesNumber, true, lang.filesNumber),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return lang.requiredField;
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            wrapInIgnorePointer(
              child: TextFormField(
                controller: _selectFileSpecCtrl,
                decoration: getDecoration(
                    lang.selectFileSpec, true, lang.selectFileSpec),
                validator: (text) =>
                    ValidationUtils.requiredField(text, context),
              ),
              onTap: selectFileSpec,
            ),
            SizedBox(
              height: 20,
            ),
            getButtons(
                onSave: continued,
                skipCancel: true,
                saveLabel: lang.next.toUpperCase())
          ],
        ));
  }

  Widget selectCustomerTitleWidget() {
    return Row(
      children: [
        Text(lang.selectCustomer.toUpperCase()),
        SizedBox(
          width: 20,
        ),
        StreamBuilder<int>(
            stream: currentStepStream,
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return SizedBox.shrink();
              }
              return ButtonBar(children: [
                ElevatedButton(
                  onPressed: snapshot.data == 1
                      ? (() => selectCustomerDialog())
                      : null,
                  child: Icon(Icons.add),
                ),
              ]);
            }),
      ],
    );
  }

  selectCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomerSelectionDialog(
        initialCustomers: customersStream.value,
        onSave: (selectedCustomer) {
          customersStream.add(selectedCustomer);
          if (customersStream.value.isEmpty) {
            showSnackBar2(context, lang.noCustomer);
          }
        },
      ),
    );
  }
}
