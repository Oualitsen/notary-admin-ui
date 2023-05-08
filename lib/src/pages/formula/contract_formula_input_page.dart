import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/formula/contract_function_input_page.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_formula_input.dart';
import 'package:notary_model/model/contract_function.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class ContractFormulaPage extends StatefulWidget {
  final FilesSpec fileSpec;
  const ContractFormulaPage({super.key, required this.fileSpec});

  @override
  State<ContractFormulaPage> createState() => _ContractFormulaPageState();
}

class _ContractFormulaPageState extends BasicState<ContractFormulaPage>
    with WidgetUtilsMixin {
  final copyPriceCtrl = TextEditingController();
  final assetPriceCtrl = TextEditingController();
  final pageNumberCtrl = TextEditingController();
  final copyNumberCtrl = TextEditingController();
  final stampCtrl = TextEditingController();
  final vatCtrl = TextEditingController();
  final key = GlobalKey<FormState>();
  String? id;
  double? copyPrice;
  double? assetPrice;
  double? stamp;
  double? vat;
  List<String> contractFunctionList = [];

  final functionSubject = BehaviorSubject<Map<String, ContractFunction>>();

  final service = GetIt.instance.get<FileSpecService>();
  static final noOp = ContractFunction(percentage: false, value: 0);
  bool inited = false;
  void init() {
    if (inited) {
      return;
    }
    inited = true;
    final functionMap = <String, ContractFunction>{};

    contractFunctionList = [
      lang.notarizationTax,
      lang.publishingAndAdvertisingArticle5,
      lang.wagesForTheDurationOfWorkArticle75,
      lang.consultationArticle79,
      lang.otherServices,
      lang.registrationTax,
      lang.publicityTax,
      lang.advertisement,
      lang.deposit,
      lang.boal,
      lang.registrationOrDeletion
    ];
    contractFunctionList.forEach((name) {
      functionMap[name] = noOp;
    });

    var f = widget.fileSpec.formula;
    if (f != null) {
      pageNumberCtrl.text = f.pageNumber.toString();
      assetPriceCtrl.text = f.assetPrice.toString();
      copyNumberCtrl.text = f.copyNumber.toString();
      copyPriceCtrl.text = f.copyPrice.toString();
      stampCtrl.text = f.stamp.toString();
      vatCtrl.text = f.vat.toString();

      f.functions.forEach((e) => functionMap[e.name ?? ""] = e);
      //functionSubject.add(functionMap);
    }

    functionSubject.add(functionMap);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(title: Text(lang.contractFormuaPageTitle), actions: []),
        body: Form(
          key: key,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<Map<String, ContractFunction>>(
                    stream: functionSubject,
                    initialData: functionSubject.valueOrNull,
                    builder: (context, snapshot) {
                      var map = snapshot.data ?? {};
                      return ListView(
                        padding: EdgeInsets.only(top: 20),
                        children: [
                          TextFormField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: pageNumberCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.pageNumber, true),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: assetPriceCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.assetPrice, true),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: copyNumberCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.copyNumber, true),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: copyPriceCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.copyPrice, true),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: stampCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.stamp, true),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: vatCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.vat, true),
                          ),
                          ...map.keys.map((name) {
                            ContractFunction? fn = map[name];

                            return ListTile(
                              title: Text(name),
                              subtitle: fn != noOp
                                  ? Text("${lang.fuctionValue(fn!)}")
                                  : Text(lang.na),
                              onTap: () {
                                if (fn == noOp) {
                                  push<ContractFunction>(
                                      context,
                                      ContactFunctionInputPage(
                                        title: name,
                                      )).listen((function) {
                                    map[name] = function;
                                    functionSubject.add(map);
                                  });
                                } else {
                                  push<ContractFunction?>(
                                          context,
                                          ContactFunctionInputPage(
                                            contractFunction: fn,
                                            title: lang.editContractFunction,
                                            showName: true,
                                          ))
                                      .where((event) => event != null)
                                      .listen((event) {
                                    var list = functionSubject.value;
                                    list.remove(name);
                                    list.putIfAbsent(
                                        event?.name ?? name, () => event!);
                                    functionSubject.add(list);
                                  });
                                }
                              },
                              trailing: IconButton(
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
                                            child: Text(
                                                lang.cancel.toUpperCase())),
                                        TextButton(
                                            onPressed: () {
                                              var list = functionSubject.value;
                                              list.remove(name);
                                              functionSubject.add(list);
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text(lang.ok.toUpperCase()))
                                      ]);
                                },
                              ),
                            );
                          }).toList()
                        ],
                      );
                    }),
              ),
              Row(
                children: [
                  OutlinedButton(
                      onPressed: () {
                        push<ContractFunction?>(
                                context,
                                ContactFunctionInputPage(
                                  title: lang.newContractFunction.toUpperCase(),
                                  showName: true,
                                ))
                            .where((event) => event != null)
                            .listen((contract) {
                          var map = functionSubject.value;
                          map[contract!.name!] = contract;
                          functionSubject.add(map);
                        });
                      },
                      child: Text(lang.addContractFunction.toUpperCase())),
                  Expanded(
                    child: getButtons(onSave: save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ContractFormulaInput? readContractFormulaInput() {
    var state = key.currentState!;
    if (state.validate()) {
      ContractFormulaInput contractFormulaInput = new ContractFormulaInput(
          id: id,
          copyPrice: double.parse(copyPriceCtrl.text),
          pageNumber: double.parse(pageNumberCtrl.text),
          copyNumber: double.parse(copyNumberCtrl.text),
          assetPrice: double.parse(assetPriceCtrl.text),
          stamp: double.parse(stampCtrl.text),
          vat: double.parse(vatCtrl.text),
          functions: functionSubject.value.values.toList());
      return contractFormulaInput;
    }
    return null;
  }

  save() async {
    final contractFormulaInput = readContractFormulaInput();
    if (contractFormulaInput != null) {
      try {
        progressSubject.add(true);

        var fileSpec = await service.addContractFormulaToFileSpec(
            widget.fileSpec.id, contractFormulaInput);
        await showSnackBar2(context, lang.savedSuccessfully);
        Navigator.of(context).pop(fileSpec);
      } catch (error, stackTrace) {
        showServerError(context, error: error);
        print(stackTrace);
        throw error;
      } finally {
        progressSubject.add(false);
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
