import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/pages/templates/upload_template.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:notary_model/model/files_archive_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/rxdart.dart';

class AddArchivePage extends StatefulWidget {
  final DateTime? initDate;
  const AddArchivePage({this.initDate, super.key});
  @override
  State<AddArchivePage> createState() => _AddArchivePageState();
}

class _AddArchivePageState extends BasicState<AddArchivePage>
    with WidgetUtilsMixin {
  int currentStep = 0;
  //services
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesArchiveService>();
  final uploadService = GetIt.instance.get<UploadService>();

  //Stream
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _listcustomerStream = BehaviorSubject.seeded(<Customer>[]);
  final _filesSpecStream = BehaviorSubject<FilesSpec>();
  final selectedDay = BehaviorSubject.seeded(DateTime.now());
  final scannedDocumentsStream = BehaviorSubject.seeded(<UploadData>[]);

  //Key
  final GlobalKey<FormState> _selectFileSpecKey = GlobalKey();
  //controlers
  final _selectFileSpecCtrl = TextEditingController();
  final _numberFileCtrl = TextEditingController();
  final archvingDateCtrl = TextEditingController();
  //var
  bool initialized = false;

  late FilesArchive archive;
  void init() {
    if (initialized) return;
    initialized = true;
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
          title: Text(lang.addArchive),
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
                    title: Text(lang.general.toUpperCase()),
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
                        ButtonBar(
                          children: [
                            ElevatedButton(
                              onPressed:
                                  snapshot.data == 1 ? selectCustomers : null,
                              child: Icon(Icons.add),
                            ),
                          ],
                        ),
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
                              return WidgetMixin.ListCustomers(
                                context,
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
                    title: Row(
                      children: [
                        Text(lang.additionalDocuments.toUpperCase()),
                        SizedBox(width: 20),
                        ButtonBar(children: [
                          ElevatedButton(
                            onPressed:
                                snapshot.data == 2 ? uploadTemplate : null,
                            child: Icon(Icons.add_outlined),
                          ),
                        ]),
                      ],
                    ),
                    content: StreamBuilder<List<UploadData>>(
                      stream: scannedDocumentsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var element = snapshot.data![index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                        child: Text("${(index + 1)}")),
                                    title: Text(element.name),
                                    trailing: Wrap(
                                      children: [
                                        StreamBuilder<double>(
                                            stream: element.progress,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return IconButton(
                                                    onPressed: () {
                                                      upload(archive.id,
                                                              element)
                                                          .listen((event) {});
                                                    },
                                                    icon: Icon(
                                                      Icons.refresh,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ));
                                              }
                                              if (snapshot.hasData) {
                                                return Text(
                                                    "${snapshot.data} %");
                                              }
                                              return IconButton(
                                                  icon: Icon(Icons.cancel),
                                                  onPressed: () {
                                                    delete(element);
                                                  });
                                            }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            getButtons(
                                onSave: scannedDocumentsStream.value.isNotEmpty
                                    ? save
                                    : null,
                                onCancel: previous,
                                saveLabel: lang.submit,
                                cancelLabel: lang.previous),
                          ],
                        );
                      },
                    ),
                    isActive: activeState == 2,
                    state: getState(2),
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
        if (_selectFileSpecKey.currentState?.validate() ?? false) {
          _currentStepStream.add(_currentStepStream.value + 1);
        }
        break;

      case 1:
        if (_listcustomerStream.value.isNotEmpty) {
          _currentStepStream.add(_currentStepStream.value + 1);
        }
        break;

      case 2:
        if (scannedDocumentsStream.value.isNotEmpty) {
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

  Future<List<FilesSpec>> getFilesSpec(int index) {
    var result = serviceFileSpec.getFileSpecs(pageIndex: index, pageSize: 10);
    return result;
  }

  void save() async {
    try {
      progressSubject.add(true);
      if (_selectFileSpecKey.currentState!.validate() &&
          _listcustomerStream.value.isNotEmpty) {
        var input = FilesArchiveInput(
            id: null,
            number: _numberFileCtrl.text,
            specification: _filesSpecStream.value,
            customers: _listcustomerStream.value,
            uploadedFiles: [],
            archvingDate: selectedDay.value.millisecondsSinceEpoch);

        archive = await serviceFiles.saveFilesArchive(input);
        if (scannedDocumentsStream.value.isNotEmpty) {
          await uploadScannedDocuments(archive.id);
          await showSnackBar2(context, lang.createdsuccssfully);
          Navigator.of(context).pop(archive);
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
    WidgetMixin.showDialog2(
      context,
      label: lang.selectFileSpec.toUpperCase(),
      content: SizedBox(
        width: 400,
        height: 300,
        child: listFilesSpecWidget(),
      ),
    );
  }

  Widget listFilesSpecWidget() {
    return InfiniteScrollListView(
        elementBuilder: ((context, element, index, animation) {
          return ListTile(
            leading: Text("${lang.formatDate(element.creationDate)}"),
            title: Text("${element.name}"),
            onTap: () {
              _selectFileSpecCtrl.text = element.name;
              _filesSpecStream.add(element);

              Navigator.of(context).pop(true);
            },
          );
        }),
        pageLoader: getFilesSpec);
  }

  void selectCustomers() {
    push<List<Customer>>(
        context,
        CustomerSelection(
          selectionType: SelectionType.MULTIPLE,
        )).listen((event) async {
      if (event.isNotEmpty) {
        _listcustomerStream.add(event);
      }
    });
  }

  void uploadTemplate() async {
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
      var list = scannedDocumentsStream.value;
      list.add(data);
      scannedDocumentsStream.add(list);
    }
  }

  Future uploadScannedDocuments(String archiveId) async {
    var uri = "/admin/archive/upload/document/${archiveId}";
    Rx.combineLatest(
        scannedDocumentsStream.value.map((ud) => upload(uri, ud)).toList(),
        (values) => values).doOnListen(() {
      progressSubject.add(true);
    }).doOnDone(() {
      progressSubject.add(false);
    });
  }

  Stream<dynamic> upload(String uri, UploadData data) {
    print("@@@@@@@@@@@@@@@@@@@@@@@@ called");

    try {
      if (kIsWeb && data.data != null) {
        return uploadService
            .upload(
              uri,
              data.data!,
              data.name,
              callBack: (percentage) {
                data.progress.add(percentage);
              },
            )
            .asStream()
            .doOnError(
              (p0, p1) {
                data.progress.addError(p0);
              },
            );
      } else if (!kIsWeb && data.path != null) {
        return uploadService
            .uploadFileDynamic(
              uri,
              data.path!,
              callBack: (percentage) {
                data.progress.add(percentage);
              },
            )
            .asStream()
            .doOnError(
              (p0, p1) {
                data.progress.addError(p0);
              },
            );
      }
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    }
    return Stream.empty();
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  delete(UploadData data) {
    var list = scannedDocumentsStream.value;
    list.remove(data);
    scannedDocumentsStream.add(list);
  }
}
