import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/contract_category_service.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/add_contract_category_widget.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:notary_model/model/contract_category_input.dart';
import 'package:rapidoc_utils/alerts/alert_info_widget.dart';
import 'package:rapidoc_utils/alerts/alert_vertical_widget.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class AddContractCategoryPage extends StatefulWidget {
  final ContractCategory? contractCategory;
  const AddContractCategoryPage({super.key, this.contractCategory});

  @override
  State<AddContractCategoryPage> createState() =>
      AddContractCategoryPageState();
}

class AddContractCategoryPageState extends BasicState<AddContractCategoryPage>
    with WidgetUtilsMixin {
  final contractCategoryinfoKey = GlobalKey<AddContractCategoryWidgetState>();
  final ContractCategoryService service =
      GetIt.instance.get<ContractCategoryService>();
  final nameContractCaytegoryInputCtrl = TextEditingController();
  final key = GlobalKey<FormState>();
  final contractCategoryInputStream = BehaviorSubject.seeded(<String>[]);
  final checkedStream = BehaviorSubject.seeded(false);
  @override
  void initState() {
    if (widget.contractCategory != null) {
      // List<String>? a = contractCategoryInputStream.value;
      // var b = widget.contractCategory?.listContractCategoryInput;
      // a = b;
      contractCategoryInputStream.value =
          widget.contractCategory!.listContractCategoryInput;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.addContractCategory),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            AddContractCategoryWidget(
              key: contractCategoryinfoKey,
              contractCategory: widget.contractCategory,
            ),
            StreamBuilder<List<String>>(
                stream: contractCategoryInputStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  return Column(
                    children: List.generate(snapshot.data!.length, (index) {
                      return ListTile(
                        title: Text(snapshot.data![index]),
                        trailing: Wrap(
                          spacing: 40,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showAlertDialog(
                                  context: context,
                                  title: lang.confirm,
                                  message: lang.confirmDeleteItem,
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text(lang.cancel.toUpperCase())),
                                    TextButton(
                                        onPressed: () {
                                          //////////////////
                                          var listContractCategory =
                                              contractCategoryInputStream.value;
                                          listContractCategory
                                              .remove(snapshot.data![index]);
                                          contractCategoryInputStream
                                              .add(listContractCategory);
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text(lang.ok.toUpperCase()))
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      );
                    }),
                  );
                }),
            TextButton(
              child: Text(lang.addContractCategoryInput.toUpperCase()),
              onPressed: () {
                ReusedWidgets.showDialog2(
                  context,
                  label: lang.addContractCategoryInput,
                  height: 300,
                  content: ListView(
                    children: [
                      SizedBox(
                        child: Form(
                          key: key,
                          child: TextFormField(
                            validator: (text) {
                              return ValidationUtils.requiredField(
                                  text, context);
                            },
                            controller: nameContractCaytegoryInputCtrl,
                            decoration: getDecoration(
                                lang.nameContractCategoryInput, true),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                      getButtons(
                          onSave: () {
                            if (key.currentState!.validate()) {
                              var list = contractCategoryInputStream.value;
                              list.add(nameContractCaytegoryInputCtrl.text);
                              contractCategoryInputStream.add(list);
                              nameContractCaytegoryInputCtrl.text = "";
                              Navigator.of(context).pop();
                            }
                            ;
                          },
                          skipCancel: true)
                    ],
                  ),
                );
              },
            ),
            StreamBuilder<bool>(
                stream: checkedStream,
                initialData: checkedStream.value,
                builder: (context, snapshot) {
                  if (snapshot.data!) {
                    return AlertVerticalWidget.createWarning(
                        lang.contractCategoryNumber);
                  }
                  return SizedBox.shrink();
                }),
          ],
        ),
      ),
      floatingActionButton: getButtons(onSave: save),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
  bool isvalidate() {
    return key.currentState!.validate();
  }

  save() async {
    var contractCategoryInfo =
        contractCategoryinfoKey.currentState?.readContractCategoryInput();
    if (contractCategoryInfo != null) {
      if (contractCategoryInputStream.value.length == 0 ||
          contractCategoryInputStream.value.length == 1 ||
          contractCategoryInputStream.value.length == 3) {
        var contractCategoryInput = ContractCategoryInput(
          id: widget.contractCategory?.id ?? null,
          name: contractCategoryInfo.name,
          nameAr: contractCategoryInfo.nameAr,
          nameFr: contractCategoryInfo.nameFr,
          listContractCategoryInput: contractCategoryInputStream.value,
        );
        try {
          var result =
              await service.saveContractCategory(contractCategoryInput);
          Navigator.of(context).pop(result);
          await showSnackBar2(context, lang.savedSuccessfully);
        } catch (error, stacktrace) {
          print(stacktrace);
          showServerError(context, error: error);
        }
      } else {
        checkedStream.add(true);
      }
    }
  }
}
