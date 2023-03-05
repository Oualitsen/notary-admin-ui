import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/customer/file_picker_customer_folder.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';
import 'package:select_form_field/select_form_field.dart';
import '../../services/files/file_spec_service.dart';
import '../../services/files/files_service.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';

class AddFolderCustomer extends StatefulWidget {
  final Files? files;
  final List<Customer>? customersList;
  const AddFolderCustomer({super.key, this.files, this.customersList});
  @override
  State<AddFolderCustomer> createState() => _AddFolderCustomerState();
}

class _AddFolderCustomerState extends BasicState<AddFolderCustomer>
    with WidgetUtilsMixin {
  final serviceCustomer = GetIt.instance.get<CustomerService>();
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  final _currentStepStream = BehaviorSubject.seeded(0);
  final _listcustomerStream = BehaviorSubject.seeded(<Customer>[]);
  final _listFileStream = BehaviorSubject.seeded(<FilesSpec>[]);
  final GlobalKey<FormState> _addFolderKey = GlobalKey();
  final _selectCustomerCtrl = TextEditingController();
  final _selectFileSpecCtrl = TextEditingController();
  final _numberFileCtrl = TextEditingController();

  late Customer customer;
  late final FilesSpec fileSpec;
  void initState() {
    var files = widget.files;
    var customersList = widget.customersList;
    serviceCustomer.getCustomers().then(_listcustomerStream.add);
    serviceFileSpec.getFileSpecs().then(_listFileStream.add);
    if (files != null) {
      _selectCustomerCtrl.text = customersList!.first.lastName;
      _selectFileSpecCtrl.text = files.specification.name;

      _numberFileCtrl.text = files.number;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.addfolder),
          ),
          body: StreamBuilder(
            stream: _currentStepStream,
            initialData: _currentStepStream.value,
            builder: (context, snapshot) {
              int activeState = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                    key: _addFolderKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _numberFileCtrl,
                          decoration:
                              InputDecoration(hintText: lang.filesNumber,icon:Icon(Icons.code)),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return lang.requiredField;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        StreamBuilder<List<Customer>>(
                            stream: _listcustomerStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              return SelectFormField(
                                controller: _selectCustomerCtrl,
                                type: SelectFormFieldType.dialog,
                                dialogTitle: lang.selectCustomer,
                                dialogSearchHint:
                                    lang.search, // or can be dialog
                                labelText: lang.selectCustomer,
                                enableSuggestions: true,
                                enableSearch: true,
                                dialogCancelBtn: lang.cancel,
                                icon: Icon(Icons.man),
                                items: snapshot.data!.map((customer) {
                                  Map<String, dynamic> customerMap =
                                      new Map<String, dynamic>();
                                  customerMap["value"] = customer.id;
                                  customerMap["label"] =
                                      "${customer.firstName} ${customer.lastName}";
                                  // same for xpos and ypos
                                  return customerMap;
                                }).toList(),
                                onChanged: (val) {
                                  customer = snapshot.data!
                                      .where((element) => element.id == val)
                                      .first;
                                },
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return lang.selectCustomer;
                                  }
                                  return null;
                                },
                              );
                            }),
                        SizedBox(
                          height: 30,
                        ),
                        StreamBuilder<List<FilesSpec>>(
                            stream: _listFileStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              return SelectFormField(
                                controller: _selectFileSpecCtrl,
                                type: SelectFormFieldType.dialog,
                                dialogTitle: lang.selectCustomer,
                                dialogSearchHint:
                                    lang.search, // or can be dialog
                                labelText: lang.selectFileSpec,
                                enableSearch: true,
                                enableSuggestions: true,

                                dialogCancelBtn: lang.cancel,
                                icon: Icon(Icons.file_open),
                                items: snapshot.data!.map((file) {
                                  Map<String, dynamic> fileMap =
                                      new Map<String, dynamic>();
                                  fileMap["value"] = file.id;
                                  fileMap["label"] = file.name;

                                  return fileMap;
                                }).toList(),
                                onChanged: (val) {
                                  fileSpec = snapshot.data!
                                      .where((element) => element.id == val)
                                      .first;
                                },
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return lang.selectFileSpec;
                                  }
                                  return null;
                                },
                              );
                            }),
                        SizedBox(height: 40),
                        Center(
                          child: getButtons(
                              onSave: save,
                              skipCancel: true,
                              saveLabel: lang.selectDocuments.toUpperCase()),
                        ),
                      ],
                    )),
              );
            },
          ),
        ));
  }

  save() async {
    try {
      if (_addFolderKey.currentState!.validate() || false) {
        // Process data.
        Files files = await serviceFiles.saveFiles(FilesInput(
            id: null,
            number: _numberFileCtrl.text,
            imageIds: [],
            clientIds: [customer.id],
            uploadedFiles: [],
            specification: fileSpec));

        if (files != null) {
          await showSnackBar2(context, lang.selectDocuments);
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FilePickerCustomerFolder(
                      files: files,
                    )));
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
