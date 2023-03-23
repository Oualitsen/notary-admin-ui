import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/utils/widget_utils_new.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/printed_doc_input.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/rxdart.dart';
import '../../services/admin/template_document_service.dart';
import '../../services/files/file_spec_service.dart';
import '../../services/files/files_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import '../templates/form_and_view_html.dart';
import 'list_files_customer.dart';

class AddFolderCustomer extends StatefulWidget {
  const AddFolderCustomer({
    super.key,
  });
  @override
  State<AddFolderCustomer> createState() => _AddFolderCustomerState();
}

class _AddFolderCustomerState extends BasicState<AddFolderCustomer>
    with WidgetUtilsMixin, WidgetUtilsFile {
  int currentStep = 0;
  //services
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  final serviceTemplateDocument = GetIt.instance.get<TemplateDocumentService>();
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  //Stream
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _printedDocInputStream = BehaviorSubject<PrintedDocInput>();
  final _listcustomerStream = BehaviorSubject.seeded(<Customer>[]);
  final _folderValidateStream = BehaviorSubject.seeded(false);
  final _filesSpecStream = BehaviorSubject<FilesSpec>();
  final _pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final _allUploadedStream = BehaviorSubject.seeded(false);
  //Key
  final GlobalKey<FormState> _selectFileSpecKey = GlobalKey();
  //controlers
  final _selectFileSpecCtrl = TextEditingController();
  final _numberFileCtrl = TextEditingController();
  //var
  void initState() {
    _folderValidateStream.add(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.addfolder),
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
                    title: Text(lang.selectFileSpec.toUpperCase()),
                    content: Form(
                        key: _selectFileSpecKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _numberFileCtrl,
                              decoration: getDecoration(
                                  lang.filesNumber, true, lang.filesNumber),
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
                            TextFormField(
                                readOnly: true,
                                controller: _selectFileSpecCtrl,
                                decoration: getDecoration(lang.selectFileSpec,
                                    true, lang.selectFileSpec),
                                onTap: selectFileSpec,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return lang.requiredField;
                                  }
                                  return null;
                                }),
                            SizedBox(
                              height: 20,
                            ),
                            getButtons(
                                onSave: continued,
                                skipCancel: true,
                                saveLabel: lang.next)
                          ],
                        )),
                    isActive: activeState == 0,
                    state: getState(0),
                  ),
                  Step(
                    title: Row(
                      children: [
                        Text(lang.selectCustomer.toUpperCase()),
                        SizedBox(
                          width: 20,
                        ),
                        StreamBuilder<int>(
                            stream: _currentStepStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }
                              return ButtonBar(children: [
                                ElevatedButton(
                                  onPressed: snapshot.data == 1
                                      ? () {
                                          Navigator.push<List<Customer>>(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomerSelection(
                                                      selectionType:
                                                          SelectionType
                                                              .MULTIPLE,
                                                    )),
                                          ).then((value) async {
                                            if (value != null) {
                                              _listcustomerStream.add(value);
                                              if (_listcustomerStream
                                                  .value.isEmpty) {
                                                await showSnackBar2(
                                                    context, lang.noCustomer);
                                              }
                                            }
                                          });
                                        }
                                      : null,
                                  child: Icon(Icons.add),
                                ),
                              ]);
                            }),
                      ],
                    ),
                    content: Column(
                      children: [
                        StreamBuilder<List<Customer>>(
                            stream: _listcustomerStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              //
                              return ListCustomers(
                                listCustomers: _listcustomerStream.value,
                              );
                            }),
                        getButtons(
                            onSave: continued,
                            onCancel: previous,
                            saveLabel: lang.next,
                            cancelLabel: lang.previous),
                      ],
                    ),
                    isActive: activeState == 1,
                    state: getState(1),
                  ),
                  Step(
                    title: Text(lang.selectDocuments.toUpperCase()),
                    content: Column(
                      children: [
                        StreamBuilder<List<PathsDocuments>>(
                            stream: _pathDocumentsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }

                              return SizedBox(
                                height: 200,
                                child: widgetListFiles(
                                  pathDocumentsStream: _pathDocumentsStream,
                                  allUploadedStream: _allUploadedStream,
                                  filesSpecStream: _filesSpecStream,
                                ),
                              );
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        getButtons(
                          onSave: continued,
                          onCancel: previous,
                          saveLabel: lang.next,
                          cancelLabel: lang.previous,
                        )
                      ],
                    ),
                    isActive: activeState == 2,
                    state: getState(2),
                  ),
                  Step(
                    title: Row(
                      children: [
                        Text(lang.addFiles.toUpperCase()),
                        SizedBox(
                          width: 20,
                        ),
                        StreamBuilder<int>(
                            stream: _currentStepStream,
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
                            stream: _printedDocInputStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return Text(
                                    lang.noCreatedDocumentprint.toUpperCase());
                              }

                              return ListTile(
                                subtitle: Text("${lang.documentName}"),
                                title: Text("${snapshot.data!.name}"),
                              );
                            }),
                        StreamBuilder<bool>(
                            stream: _folderValidateStream,
                            initialData: false,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return SizedBox.shrink();
                              }
                              return ButtonBar(
                                children: [
                                  ElevatedButton(
                                      onPressed: previous,
                                      child: Text(lang.previous)),
                                  ElevatedButton(
                                      onPressed: snapshot.data! ? save : null,
                                      child: Text(lang.submit.toUpperCase())),
                                ],
                              );
                            }),
                      ],
                    ),
                    isActive: activeState == 3,
                    state: getState(3),
                  ),
                ],
              );
            }),
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
          if (_selectFileSpecKey.currentState?.validate() ?? false) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {
          if (_listcustomerStream.value.isNotEmpty) {
            _currentStepStream.add(_currentStepStream.value + 1);
          } else {
            await showSnackBar2(context, lang.noCustomer);
          }
        }

        break;
      case 2:
        {
          print(_allUploadedStream.value);
          if (_allUploadedStream.value) {
            _currentStepStream.add(_currentStepStream.value + 1);
          } else {
            showSnackBar2(context, lang.noDocument);
          }
        }
        break;
      case 3:
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

  Future<List<FilesSpec>> getTemplates(int index) {
    var result = serviceFileSpec.getFileSpecs(pageIndex: index, pageSize: 10);
    return result;
  }

  save() async {
    try {
      progressSubject.add(true);
      if (_selectFileSpecKey.currentState!.validate() &&
              _listcustomerStream.value.isNotEmpty &&
              _folderValidateStream.value ||
          false) {
        // Process data.
        var listCustomersIds =
            _listcustomerStream.value.map((e) => e.id).toList();

        var files = await serviceFiles.saveFiles(FilesInput(
            id: null,
            number: _numberFileCtrl.text,
            imageIds: [],
            clientIds: listCustomersIds,
            uploadedFiles: [],
            specification: _filesSpecStream.value,
            printedDocInput: _printedDocInputStream.value));

        if (files != null) {
          uploadFiles(context, files, _pathDocumentsStream.value);
          await showSnackBar2(context, lang.createdsuccssfully);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ListFilesCustomer()));
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

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void selectFileSpec() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Container(
                height: 50,
                child: Wrap(alignment: WrapAlignment.spaceBetween, children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(lang.selectFileSpec.toUpperCase()),
                  ),
                  Tooltip(
                    message: lang.cancel,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.cancel,
                          size: 26,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ]),
              ),
              content: SizedBox(
                width: 400,
                height: 300,
                child: InfiniteScrollListView(
                    elementBuilder: ((context, element, index, animation) {
                      return ListTile(
                        title: Text("${element.name}"),
                        onTap: () {
                          _selectFileSpecCtrl.text = element.name;
                          _filesSpecStream.add(element);
                          _pathDocumentsStream
                              .add(_filesSpecStream.value.documents
                                  .map(
                                    (e) => PathsDocuments(
                                      idDocument: e.id,
                                      document: null,
                                      selected: false,
                                      namePickedDocument: null,
                                      path: null,
                                      nameDocument: e.name,
                                    ),
                                  )
                                  .toList());
                          Navigator.of(context).pop(true);
                        },
                      );
                    }),
                    refreshable: true,
                    pageLoader: getTemplates),
              ),
            ));
  }

  generateForm() async {
    try {
      var finalList = [];
      var list = await serviceTemplateDocument
          .formGenerating(_filesSpecStream.value.templateId);
      for (var res in list) {
        finalList.add(res.replaceAll(" ", "_"));
      }
      var data = await serviceTemplateDocument
          .replacements(_filesSpecStream.value.templateId);

      Navigator.push<PrintedDocInput>(
          context,
          MaterialPageRoute(
              builder: (context) => FormAndViewHtml(
                    listFormField: finalList,
                    text: data,
                  ))).then((value) {
        if (value != null) {
          _printedDocInputStream.add(value);
          _folderValidateStream.add(true);
        }
      });
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }
}
