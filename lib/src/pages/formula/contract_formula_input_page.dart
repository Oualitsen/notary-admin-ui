import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/pages/formula/contract_function_input_page.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_formula_input.dart';
import 'package:notary_model/model/contract_function.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class ContractFormulaPage extends StatefulWidget {
  const ContractFormulaPage({super.key});

  @override
  State<ContractFormulaPage> createState() => _ContractFormulaPageState();
}

class _ContractFormulaPageState extends BasicState<ContractFormulaPage>
    with WidgetUtilsMixin {
  final copyPriceCtrl = TextEditingController();
  final assetPriceCtrl = TextEditingController();
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
                        children: [
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
                            controller: assetPriceCtrl,
                            validator: (text) {
                              return ValidationUtils.doubleValidator(
                                  text, context);
                            },
                            decoration: getDecoration(lang.assetPrice, true),
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
                    child: getButtons(
                      onSave: () async {
                        if (key.currentState!.validate()) {
                          ContractFormulaInput contractFormulaInput =
                              new ContractFormulaInput(
                                  id: id,
                                  copyPrice: double.parse(copyPriceCtrl.text),
                                  assetPrice: double.parse(assetPriceCtrl.text),
                                  stamp: double.parse(stampCtrl.text),
                                  vat: double.parse(vatCtrl.text),
                                  functions:
                                      functionSubject.value.values.toList());
                          await service.addContractFormulaToFileSpec(
                              "643ff577459bb6533ca62103", contractFormulaInput);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
