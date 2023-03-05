import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/file/file_spec_List.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/files_spec_input.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

import '../../widgets/mixins/button_utils_mixin.dart';
import '../document/add_document.dart';
import '../document/document_table.dart';

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
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _listDocumentsInputStream = BehaviorSubject.seeded(<DocumentSpecInput>[]);
  final GlobalKey<FormState> _fileSpecNameKey = GlobalKey<FormState>();
  final _nameFileSpecCtrl = TextEditingController();
  List<DocumentSpecInput> listDocumentsInput = [];
  late FilesSpec fileSpec;

  @override
  void initState() {
    var fileSpec = widget.fileSpec;

    if (fileSpec != null) {
      _nameFileSpecCtrl.text = fileSpec.name;
      listDocumentsInput = fileSpec.documents
          .map((e) => DocumentSpecInput(
              id: e.id,
              name: e.name,
              optional: e.optional,
              original: e.original))
          .toList();
      _listDocumentsInputStream.add(listDocumentsInput);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.addFileSpec),
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
                title: Text(lang.nameFileSpec.toUpperCase()),
                content: Column(
                  children: [
                    Form(
                      key: _fileSpecNameKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            controller: _nameFileSpecCtrl,
                            decoration: InputDecoration(
                              hintText: lang.nameFileSpec,
                            ),
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
                title: Row(
                  children: [
                    Text(lang.listDocumentsFileSpec.toUpperCase()),
                    SizedBox(
                      width: 40,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push<DocumentSpecInput>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddDocument()),
                        ).then((value) {
                          if (value != null) {
                            var list = _listDocumentsInputStream.value;
                            list.add(value);
                            _listDocumentsInputStream.add(list);
                          }
                        });
                      },
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
                content: StreamBuilder<List<DocumentSpecInput>>(
                    stream: _listDocumentsInputStream,
                    initialData: _listDocumentsInputStream.value,
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return SizedBox.shrink();
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          DocumentsTable(
                            listDocument: snapshot.data!,
                            onChanged: (List<DocumentSpecInput> listDoc) {
                              _listDocumentsInputStream.add(listDoc);
                            },
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
                isActive: activeState == 1,
                state: getState(1),
              ),
            ],
          );
        },
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
            if (_listDocumentsInputStream.value.isEmpty) {
              await showSnackBar2(context, lang.noDocument);
            }
          }
        }
        break;
      case 1:
        {
          await save();
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
            name: _nameFileSpecCtrl.text,
            documentInputs: _listDocumentsInputStream.value,
            id: null);
        if (_listDocumentsInputStream.value.isNotEmpty) {
          await service.saveFileSpec(input);
          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FileSpecList()));
        } else {
          await showSnackBar2(
              context, " ${lang.listDocumentsFileSpec}   ${lang.empty}");
        }
      } else {
        var update = FilesSpecInput(
            name: _nameFileSpecCtrl.text,
            documentInputs: _listDocumentsInputStream.value,
            id: widget.fileSpec!.id);
        if (_listDocumentsInputStream.value.isNotEmpty) {
          await service.saveFileSpec(update);
          await showSnackBar2(context, lang.updatedSuccessfully);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FileSpecList()));
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

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
