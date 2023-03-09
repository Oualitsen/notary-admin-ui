import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/pages/files/widget_document_picked.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/rxdart.dart';
import '../../services/admin/printed_docs_service.dart';
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
    with WidgetUtilsMixin {
  int currentStep = 0;
  //services
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  final serviceTemplateDocument = GetIt.instance.get<TemplateDocumentService>();
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  //Stream
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _printedDocIdStream = BehaviorSubject<PrintedDoc>();
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
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: Center(
                                                child: Text(lang.selectFileSpec
                                                    .toUpperCase())),
                                            titlePadding: EdgeInsets.all(30),
                                            content: SizedBox(
                                              width: 400,
                                              height: 300,
                                              child: InfiniteScrollListView(
                                                  elementBuilder: ((context,
                                                      element,
                                                      index,
                                                      animation) {
                                                    return ListTile(
                                                      leading: Text(
                                                          "${lang.formatDate(element.creationDate)}"),
                                                      title: Text(
                                                          "${element.name}"),
                                                      onTap: () {
                                                        _selectFileSpecCtrl
                                                                .text =
                                                            element.name;
                                                        _filesSpecStream
                                                            .add(element);
                                                        _pathDocumentsStream
                                                            .add(
                                                                _filesSpecStream
                                                                    .value
                                                                    .documents
                                                                    .map(
                                                                      (e) =>
                                                                          PathsDocuments(
                                                                        idDocument:
                                                                            e.id,
                                                                        document:
                                                                            null,
                                                                        selected:
                                                                            false,
                                                                        namePickedDocument:
                                                                            null,
                                                                        path:
                                                                            null,
                                                                        nameDocument:
                                                                            e.name,
                                                                      ),
                                                                    )
                                                                    .toList());
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                    );
                                                  }),
                                                  refreshable: true,
                                                  pageLoader: getTemplates),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text(lang.previous))
                                            ],
                                          ));
                                },
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
                              return SizedBox(
                                height: 200,
                                child: snapshot.data!.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ListTile(
                                            leading: Text(
                                                "${index + 1}-  ${snapshot.data![index].lastName}   ${snapshot.data![index].firstName}"),
                                            title: Text(
                                                "${lang.formatDate(snapshot.data![index].dateOfBirth)}"),
                                          );
                                        })
                                    : Padding(
                                        padding: const EdgeInsets.all(10),
                                        child:
                                            Text(lang.noCustomer.toUpperCase()),
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
                                child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        leading: Icon(Icons.file_download),
                                        title: Text(
                                          " ${_filesSpecStream.value.documents[index].name} ",
                                          style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                          maxLines: 50,
                                        ),
                                        subtitle: Row(
                                          children: [
                                            snapshot.data![index].selected ==
                                                    true
                                                ? Flexible(
                                                    child: Text(
                                                      snapshot.data![index]
                                                          .namePickedDocument
                                                          .toString(),
                                                      softWrap: true,
                                                    ),
                                                  )
                                                : Text(lang.noUpload),
                                          ],
                                        ),
                                        trailing: Wrap(
                                          direction: Axis.horizontal,
                                          alignment: WrapAlignment.end,
                                          spacing: 10,
                                          children: [
                                            snapshot.data![index].selected ==
                                                    true
                                                ? TextButton(
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder:
                                                              (BuildContext) =>
                                                                  AlertDialog(
                                                                    title: Text(
                                                                        lang.confirm),
                                                                    content:
                                                                        Text(lang
                                                                            .confirmDelete),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop(false);
                                                                          },
                                                                          child: Text(lang
                                                                              .no
                                                                              .toUpperCase())),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            var list =
                                                                                snapshot.data!;
                                                                            list.removeAt(index);
                                                                            list.insert(
                                                                                index,
                                                                                addPathDocument(
                                                                                  _filesSpecStream.value.documents[index].id,
                                                                                  null,
                                                                                  false,
                                                                                  '',
                                                                                  '',
                                                                                  null,
                                                                                ));
                                                                            _pathDocumentsStream.add(list);
                                                                            Navigator.of(context).pop(true);
                                                                            allUploaded();
                                                                          },
                                                                          child: Text(lang
                                                                              .confirm
                                                                              .toUpperCase())),
                                                                    ],
                                                                  ));
                                                    },
                                                    child: Text(lang.delete))
                                                : SizedBox.shrink(),
                                            TextButton(
                                              onPressed: () async {
                                                var picked = await FilePicker
                                                    .platform
                                                    .pickFiles();

                                                if (picked != null) {
                                                  var pickedPath = null;
                                                  if (!kIsWeb) {
                                                    pickedPath =
                                                        picked.files.first.path;
                                                  }
                                                  final pickedBytes =
                                                      picked.files.first.bytes;

                                                  final namePickedFile =
                                                      picked.files.first.name;

                                                  if (pickedBytes != null ||
                                                      pickedPath != null) {
                                                    var list =
                                                        _pathDocumentsStream
                                                            .value;
                                                    list.removeAt(index);
                                                    list.insert(
                                                        index,
                                                        addPathDocument(
                                                          _filesSpecStream
                                                              .value
                                                              .documents[index]
                                                              .id,
                                                          pickedBytes,
                                                          true,
                                                          namePickedFile,
                                                          _filesSpecStream
                                                              .value
                                                              .documents[index]
                                                              .name,
                                                          pickedPath,
                                                        ));
                                                    _pathDocumentsStream
                                                        .add(list);
                                                    allUploaded();
                                                  } else {}
                                                }
                                              },
                                              child: Text(lang.uploadFile),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
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
                                      ? () async {
                                          try {
                                            var finalList = [];
                                            var list =
                                                await serviceTemplateDocument
                                                    .formGenerating(
                                                        _filesSpecStream
                                                            .value.templateId);
                                            for (var res in list) {
                                              finalList.add(
                                                  res.replaceAll(" ", "_"));
                                            }
                                            var data =
                                                await serviceTemplateDocument
                                                    .replacements(
                                                        _filesSpecStream
                                                            .value.templateId);

                                            Navigator.push<PrintedDoc>(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        _printedDocIdStream
                                                                    .valueOrNull !=
                                                                null
                                                            ? FormAndViewHtml(
                                                                listFormField:
                                                                    finalList,
                                                                text: data,
                                                                idPrintDocument:
                                                                    _printedDocIdStream
                                                                        .value
                                                                        .id)
                                                            : FormAndViewHtml(
                                                                listFormField:
                                                                    finalList,
                                                                text: data,
                                                              ))).then((value) {
                                              if (value != null) {
                                                _printedDocIdStream.add(value);
                                                _folderValidateStream.add(true);
                                              }
                                            });
                                          } catch (error, stacktrace) {
                                            showServerError(context,
                                                error: error);
                                            print(stacktrace);
                                          }
                                        }
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
                        StreamBuilder<PrintedDoc>(
                            stream: _printedDocIdStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData == false) {
                                return Text(
                                    lang.noCreatedDocumentprint.toUpperCase());
                              }

                              return ListTile(
                                leading: Text("${lang.documentName} : "),
                                title: Text(
                                    "${snapshot.data!.name}   ${lang.formatDate(snapshot.data!.creationDate)}"),
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

  uploadFiles(Files finalFiles) async {
    try {
      if (_pathDocumentsStream.value.isNotEmpty) {
        if (kIsWeb) {
          for (var pathDoc in _pathDocumentsStream.value) {
            await serviceUploadDocument.upload(
              "/admin/files/upload/${finalFiles.id}/${finalFiles.specification.id}/${pathDoc.idDocument}",
              pathDoc.document!,
              pathDoc.nameDocument!,
              callBack: (percentage) {
                pathDoc.progress.add(percentage);
              },
            );
          }
        } else {
          for (var pathDoc in _pathDocumentsStream.value) {
            await serviceUploadDocument.uploadFileDynamic(
              "/admin/files/upload/${finalFiles.id}/${finalFiles.specification.id}/${pathDoc.idDocument}",
              pathDoc.path!,
              callBack: (percentage) {
                pathDoc.progress.add(percentage);
              },
            );
          }
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

  save() async {
    try {
      if (_selectFileSpecKey.currentState!.validate() &&
              _listcustomerStream.value.isNotEmpty &&
              _folderValidateStream.value ||
          false) {
        // Process data.
        var listCustomersIds =
            _listcustomerStream.value.map((e) => e.id).toList();

        Files files = await serviceFiles.saveFiles(FilesInput(
            id: null,
            number: _numberFileCtrl.text,
            imageIds: [],
            clientIds: listCustomersIds,
            uploadedFiles: [],
            specification: _filesSpecStream.value,
            printedDocId: _printedDocIdStream.value.id));

        if (files != null) {
          uploadFiles(files);
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

  void allUploaded() {
    for (var pathDoc in _pathDocumentsStream.value) {
      if (!pathDoc.selected) {
        _allUploadedStream.add(false);
        return;
      } else {
        _allUploadedStream.add(true);
      }
    }
  }

  PathsDocuments addPathDocument(
      String idDocument,
      Uint8List? document,
      bool selected,
      String namePickedDocument,
      String nameDocument,
      String? path) {
    var result;
    result = PathsDocuments(
      idDocument: idDocument,
      selected: selected,
      document: document,
      namePickedDocument: namePickedDocument,
      nameDocument: nameDocument,
      path: path,
    );

    return result;
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
