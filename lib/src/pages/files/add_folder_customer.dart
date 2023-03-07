import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/rxdart.dart';
import 'package:select_form_field/select_form_field.dart';
import '../../services/files/file_spec_service.dart';
import '../../services/files/files_service.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import 'file_picker_customer_folder.dart';

class AddFolderCustomer extends StatefulWidget {
  const AddFolderCustomer({
    super.key,
  });
  @override
  State<AddFolderCustomer> createState() => _AddFolderCustomerState();
}

class _AddFolderCustomerState extends BasicState<AddFolderCustomer>
    with WidgetUtilsMixin {
  final serviceFileSpec = GetIt.instance.get<FileSpecService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  final _listcustomerStream = BehaviorSubject.seeded(<Customer>[]);
  final _listFileStream = BehaviorSubject.seeded(<FilesSpec>[]);
  final _listCustomersNotEmpty = BehaviorSubject.seeded(false);
  final GlobalKey<FormState> _addFolderKey = GlobalKey();
  final _selectFileSpecCtrl = TextEditingController();
  final _numberFileCtrl = TextEditingController();
  late final FilesSpec fileSpec;
  void initState() {
    serviceFileSpec.getFileSpecs().then(_listFileStream.add);
    _listCustomersNotEmpty.add(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.addfolder),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
                key: _addFolderKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _numberFileCtrl,
                      decoration: InputDecoration(
                          hintText: lang.filesNumber, icon: Icon(Icons.code)),
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
                            dialogSearchHint: lang.search, // or can be dialog
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
                    SizedBox(
                      height: 20,
                    ),
                    ButtonBar(children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push<List<Customer>>(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerSelection(
                                      selectionType: SelectionType.MULTIPLE,
                                    )),
                          ).then((value) async {
                            if (value != null) {
                              _listcustomerStream.add(value);
                              if (_listcustomerStream.value.isNotEmpty) {
                                _listCustomersNotEmpty.add(true);
                              } else {
                                _listCustomersNotEmpty.add(false);
                                await showSnackBar2(context, lang.noCustomer);
                              }
                            }
                          });
                        },
                        child: Text(lang.selectCustomer),
                      ),
                    ]),
                    StreamBuilder<List<Customer>>(
                        stream: _listcustomerStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          return snapshot.data!.isNotEmpty
                              ? Expanded(
                                  child: ListView.builder(
                                      itemCount: snapshot.data!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          leading: Text(
                                              "${index + 1}-  ${snapshot.data![index].lastName}   ${snapshot.data![index].firstName}"),
                                          title: Text(
                                              "${lang.formatDate(snapshot.data![index].dateOfBirth)}"),
                                        );
                                      }),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(lang.noCustomer.toUpperCase()),
                                );
                        }),
                  ],
                )),
          ),
          bottomNavigationBar: StreamBuilder<bool>(
              stream: _listCustomersNotEmpty,
              initialData: _listCustomersNotEmpty.value,
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return SizedBox.shrink();
                }
                return ButtonBar(
                  children: [
                    ElevatedButton(
                        onPressed: snapshot.data! ? save : null,
                        child: Text(lang.selectDocuments)),
                  ],
                );
              }),
        ));
  }

  save() async {
    try {
      if (_addFolderKey.currentState!.validate() || false) {
        // Process data.
        var listCustomersIds =
            _listcustomerStream.value.map((e) => e.id).toList();
        if (listCustomersIds.isNotEmpty) {
          Files files = await serviceFiles.saveFiles(FilesInput(
              id: null,
              number: _numberFileCtrl.text,
              imageIds: [],
              clientIds: listCustomersIds,
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