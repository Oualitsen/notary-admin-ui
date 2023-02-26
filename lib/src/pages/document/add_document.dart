import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/files_spec_input.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

import '../../utils/validation_utils.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import '../document/add_document.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({
    super.key,
  });

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends BasicState<AddDocument> with WidgetUtilsMixin {
  int currentStep = 0;
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _isOriginalDocumentStream = BehaviorSubject.seeded(false);
  final _isRequiredDocumentStream = BehaviorSubject.seeded(false);

  final GlobalKey<FormState> _documentNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _detailDocumentKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _dateExpirationKey = GlobalKey<FormState>();

  final _nameDocumentCtrl = TextEditingController();
  final _expiryDateDocumentCtrl = TextEditingController();
  bool _isOriginalDocumentCtrl = false;
  bool _isRequiredCtrl = false;
  final selectDateExpiration = BehaviorSubject<DateTime>();

  @override
  void initState() {
    super.initState();

    selectDateExpiration.listen((date) {
      _expiryDateDocumentCtrl.text =
          lang.formatDate(date.millisecondsSinceEpoch);
    });
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
                title: Text(lang.documentName.toUpperCase()),
                content: Column(
                  children: [
                    Form(
                      key: _documentNameKey,
                      child: TextFormField(
                        controller: _nameDocumentCtrl,
                        decoration:
                            InputDecoration(hintText: lang.documentName),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return lang.requiredField;
                          }
                          return null;
                        },
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
                title: Text(lang.general.toUpperCase()),
                content: Column(
                  children: [
                    Form(
                      key: _detailDocumentKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 50,
                            child: StreamBuilder<bool>(
                                stream: _isOriginalDocumentStream,
                                initialData: _isOriginalDocumentCtrl,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData == false) {
                                    return SizedBox.shrink();
                                  }
                                  return Checkbox(
                                    value: _isOriginalDocumentCtrl,
                                    onChanged: (value) {
                                      if (value != null) {
                                        print(value);
                                        _isOriginalDocumentCtrl = value;
                                        _isOriginalDocumentStream.add(value);
                                      }
                                    },
                                  );
                                }),
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: 200,
                              height: 50,
                              child: Text(
                                lang.originalDocument,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 40,
                            height: 50,
                            child: StreamBuilder<bool>(
                                stream: _isRequiredDocumentStream,
                                initialData: _isRequiredCtrl,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData == false) {
                                    return SizedBox.shrink();
                                  }
                                  return Checkbox(
                                    value: _isRequiredCtrl,
                                    onChanged: (value) {
                                      print(value);
                                      if (value != null) {
                                        _isRequiredCtrl = value;
                                        _isRequiredDocumentStream.add(value);
                                      }
                                    },
                                  );
                                }),
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: 200,
                              height: 50,
                              child: Text(
                                lang.requiredDocument,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    getButtons(
                      onSave: continued,
                      onCancel: previous,
                      saveLabel: lang.next.toUpperCase(),
                      cancelLabel: lang.previous.toUpperCase(),
                    ),
                  ],
                ),
                isActive: activeState == 1,
                state: getState(1),
              ),
              Step(
                title: Text(lang.expiryDate.toUpperCase()),
                content: Column(
                  children: [
                    Form(
                      key: _dateExpirationKey,
                      child: wrapInIgnorePointer(
                        onTap: selectDate,
                        child: TextFormField(
                            controller: _expiryDateDocumentCtrl,
                            validator: (text) {
                              return ValidationUtils.requiredField(
                                  text, context);
                            },
                            decoration: getDecoration(lang.expiryDate, true)),
                      ),
                    ),
                    SizedBox(height: 16),
                    getButtons(
                        onSave: continued,
                        onCancel: previous,
                        cancelLabel: lang.previous.toUpperCase(),
                        saveLabel: lang.submit.toUpperCase()),
                  ],
                ),
                isActive: activeState == 2,
                state: getState(2),
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
          if (_documentNameKey.currentState?.validate() ?? false) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {
          _currentStepStream.add(_currentStepStream.value + 1);
        }
        break;
      case 2:
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
      if (_documentNameKey.currentState!.validate() &&
              _detailDocumentKey.currentState!.validate() &&
              _dateExpirationKey.currentState!.validate() ||
          true) {
        // Process data.
        Navigator.of(context).pop(DocumentSpecInput(
          id: null,
          name: _nameDocumentCtrl.text,
          optional: _isRequiredCtrl,
          original: _isOriginalDocumentCtrl,
          //a voir avec l'expiration des documents
          // expiryDate: selectDateExpiration.value.millisecondsSinceEpoch
        ));
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  selectDate() {
    final now = selectDateExpiration.valueOrNull ?? DateTime.now();
    showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime.now(),
      lastDate: now.add(Duration(days: 365 * 10000)),
    )
        .asStream()
        .where((event) => event != null)
        .map((event) => event!)
        .listen(selectDateExpiration.add);
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
