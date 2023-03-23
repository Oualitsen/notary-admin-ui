import 'package:extended_image_library/extended_image_library.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/pages/files/list_files_customer.dart';
import 'package:notary_admin/src/pages/templates/upload_template.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/utils/widget_utils_new.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:notary_model/model/files_archive_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:notary_model/model/steps.dart';
import 'package:rxdart/rxdart.dart';
import '../../services/admin/template_document_service.dart';
import '../../services/files/file_spec_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import '../templates/form_and_view_html.dart';

class AddArchivePage extends StatefulWidget {
  final DateTime? initDate;
  const AddArchivePage({this.initDate, super.key});
  @override
  State<AddArchivePage> createState() => _AddArchivePageState();
}

class _AddArchivePageState extends BasicState<AddArchivePage>
    with WidgetUtilsMixin, WidgetUtilsFile {
  int currentStep = 0;
  //services
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesArchiveService>();
  final serviceTemplateDocument = GetIt.instance.get<TemplateDocumentService>();
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  final printedDocService = GetIt.instance.get<PrintedDocService>();
  //Stream
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _listcustomerStream = BehaviorSubject.seeded(<Customer>[]);
  final _folderValidateStream = BehaviorSubject.seeded(false);
  final _documentNameStream = BehaviorSubject.seeded("");
  final _filesSpecStream = BehaviorSubject<FilesSpec>();
  final _pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final _allUploadedStream = BehaviorSubject.seeded(false);
  final selectedDay = BehaviorSubject.seeded(DateTime.now());
  final templateFileStream = BehaviorSubject<UploadData?>();

  //Key
  final GlobalKey<FormState> _selectFileSpecKey = GlobalKey();
  //controlers
  final _selectFileSpecCtrl = TextEditingController();
  final _numberFileCtrl = TextEditingController();
  final archvingDateCtrl = TextEditingController();
  //var
  bool initialized = false;
  void init() {
    if (initialized) return;
    initialized = true;
    _folderValidateStream.add(false);
    if (widget.initDate != null) {
      selectedDay.add(widget.initDate!);
      archvingDateCtrl.text = lang.formatDateDate(widget.initDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
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
                            wrapInIgnorePointer(
                              onTap: selectDate,
                              child: TextFormField(
                                  controller: archvingDateCtrl,
                                  validator: (text) {
                                    return ValidationUtils.requiredField(
                                        text, context);
                                  },
                                  decoration: getDecoration(
                                      lang.selectArchivingDate, true)),
                            ),
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
                                      ? selectCustomers
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
                                      ? uploadTemplate
                                      : null,
                                  child: Icon(Icons.add_outlined),
                                ),
                              ]);
                            }),
                      ],
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        StreamBuilder<String>(
                            stream: _documentNameStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return Text(
                                    lang.noCreatedDocumentprint.toUpperCase());
                              }

                              return ListTile(
                                leading: Text("${lang.documentName} : "),
                                title: Text("${snapshot.data!}"),
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
        var printedDocId = "";

        var input = FilesArchiveInput(
            id: null,
            currentStep: Steps("", 0, 0, name: "archived", estimatedTime: 0),
            printedDocId: printedDocId,
            number: _numberFileCtrl.text,
            specification: _filesSpecStream.value,
            customers: _listcustomerStream.value,
            uploadedFiles: [],
            archvingDate: selectedDay.value.millisecondsSinceEpoch);

        var archive = await serviceFiles.saveFilesArchive(input);

        if (templateFileStream.valueOrNull != null) {
          upload(archive.id, templateFileStream.value!);
        }
        uploadFiles2(context, archive, _pathDocumentsStream.value);
        await showSnackBar2(context, lang.createdsuccssfully);
        Navigator.pop(context);
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  void selectDate() {
    final now = selectedDay.value;
    showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime.now().add(Duration(days: -365 * 100)),
            lastDate: DateTime.now())
        .asStream()
        .where((event) => event != null)
        .map((event) => event!)
        .listen(((event) {
      selectedDay.add(event);
      archvingDateCtrl.text = lang.formatDateDate(event);
    }));
  }

  void selectFileSpec() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Center(child: Text(lang.selectFileSpec.toUpperCase())),
              titlePadding: EdgeInsets.all(30),
              content: SizedBox(
                width: 400,
                height: 300,
                child: InfiniteScrollListView(
                    elementBuilder: ((context, element, index, animation) {
                      return ListTile(
                        leading:
                            Text("${lang.formatDate(element.creationDate)}"),
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
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(lang.previous))
              ],
            ));
  }

  void selectCustomers() {
    Navigator.push<List<Customer>>(
      context,
      MaterialPageRoute(
          builder: (context) => CustomerSelection(
                selectionType: SelectionType.MULTIPLE,
              )),
    ).then((value) async {
      if (value != null) {
        _listcustomerStream.add(value);
        if (_listcustomerStream.value.isEmpty) {
          await showSnackBar2(context, lang.noCustomer);
        }
      }
    });
  }

  void uploadTemplate() async {
    _folderValidateStream.add(false);

    var pickedFile = await FilePicker.platform.pickFiles();
    if (pickedFile != null) {
      var path = null;
      if (!kIsWeb) {
        path = pickedFile.files.first.path;
      }
      var data = UploadData(
        data: pickedFile.files.first.bytes,
        name: pickedFile.files.first.name,
        path: path,
      );
      _documentNameStream.add(data.name);
      templateFileStream.add(data);
      _folderValidateStream.add(true);
    }
  }

  void upload(String archiveId, UploadData data) async {
    try {
      var uri = "/admin/archive/upload-template/${archiveId}";
      if (kIsWeb && data.data != null) {
        await serviceUploadDocument.upload(
          uri,
          data.data!,
          data.name,
          callBack: (percentage) {
            data.progress.add(percentage);
          },
        );
      } else if (!kIsWeb && data.path != null) {
        await serviceUploadDocument.uploadFileDynamic(
          uri,
          data.path!,
          callBack: (percentage) {
            data.progress.add(percentage);
          },
        );
      }
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  uploadFiles2(BuildContext context, FilesArchive finalFiles,
      List<PathsDocuments> _pathDocumentsStream) async {
    final serviceUploadDocument = GetIt.instance.get<UploadService>();
    try {
      if (_pathDocumentsStream.isNotEmpty) {
        if (kIsWeb) {
          for (var pathDoc in _pathDocumentsStream) {
            if (pathDoc.selected) {
              await serviceUploadDocument.upload(
                "/admin/archive/upload/${finalFiles.id}/${finalFiles.specification.id}/${pathDoc.idDocument}",
                pathDoc.document!,
                pathDoc.nameDocument!,
                callBack: (percentage) {
                  pathDoc.progress.add(percentage);
                },
              );
            }
          }
        } else {
          for (var pathDoc in _pathDocumentsStream) {
            if (pathDoc.selected) {
              await serviceUploadDocument.uploadFileDynamic(
                "/admin/archive/upload/${finalFiles.id}/${finalFiles.specification.id}/${pathDoc.idDocument}",
                pathDoc.path!,
                callBack: (percentage) {
                  pathDoc.progress.add(percentage);
                },
              );
            }
          }
        }
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {}
  }
}
