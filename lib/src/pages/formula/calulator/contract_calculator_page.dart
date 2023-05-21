import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/pages/formula/calulator/formula_component_widget.dart';
import 'package:notary_admin/src/pages/formula/calulator/formula_select_widget.dart';
import 'package:notary_admin/src/pages/formula/calulator/formula_view_widget.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/contract_calculator_input_widget.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_formula.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';

class ContractCalculator extends StatefulWidget {
  const ContractCalculator({super.key});

  @override
  State<ContractCalculator> createState() => _ContractCalculatorState();
}

class _ContractCalculatorState extends BasicState<ContractCalculator>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<FileSpecService>();
  final listFileSpecSubject = BehaviorSubject<List<FilesSpec>>();
  final fileSpecStream = BehaviorSubject<FilesSpec>();
  final selectedFormula = BehaviorSubject<ContractFormula>();
  final valueInputStream = BehaviorSubject.seeded(0.0);
  final sumStream = BehaviorSubject.seeded(0.0);

  @override
  void initState() {
    service
        .getFileSpecs(pageIndex: 0, pageSize: 20)
        .then((list) => listFileSpecSubject.add(list));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.contractCalculator),
      ),
      body: Column(
        children: [
          StreamBuilder<FilesSpec?>(
              stream: fileSpecStream,
              initialData: fileSpecStream.valueOrNull,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                return ContractCalculatorInputWidget(
                  filesSpec: snapshot.data!,
                  onCall: (value) {
                    valueInputStream.add(value);
                  },
                );
              }),
          Container(
              padding: EdgeInsets.all(30),
              child: StreamBuilder<ContractFormula?>(
                  stream: selectedFormula,
                  initialData: selectedFormula.valueOrNull,
                  builder: (context, snapshot) {
                    return FormulaComponentWidget(
                      pageNumberValue: !selectedFormula.hasValue
                          ? 2
                          : selectedFormula.value.pageNumber,
                      assetPriceValue: !selectedFormula.hasValue
                          ? 0
                          : selectedFormula.value.assetPrice,
                      copyNumberValue: !selectedFormula.hasValue
                          ? 2
                          : selectedFormula.value.copyNumber,
                      copyPriceValue: !selectedFormula.hasValue
                          ? 0
                          : selectedFormula.value.copyPrice,
                    );
                  })),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<ContractFormula?>(
                    stream: selectedFormula,
                    initialData: selectedFormula.valueOrNull,
                    builder: (context, snapshot) {
                      var formula = snapshot.data;
                      if (formula == null) {
                        return Text(lang.selectAformula);
                      }
                      return StreamBuilder<double>(
                          //////////
                          stream: valueInputStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                Expanded(
                                  child: FormulaViewWidget(formula,
                                      callBackCal: (sum) {
                                    sumStream.add(sum);
                                  }, valueInput: snapshot.data!),
                                ),
                                Card(
                                  child: StreamBuilder<double>(
                                      stream: sumStream,
                                      builder: (context, snapshot) {
                                        return ListTile(
                                          title: Text(
                                              lang.amountDue.toUpperCase()),
                                          trailing: Text("${snapshot.data}"),
                                        );
                                      }),
                                )
                              ],
                            );
                          });
                    },
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: StreamBuilder<List<FilesSpec>?>(
                    stream: listFileSpecSubject,
                    initialData: listFileSpecSubject.valueOrNull,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      var list = snapshot.data!;
                      return FormulaSelectWidget(
                        list,
                        onfileSpecChange: (fileSpec) {
                          fileSpecStream.add(fileSpec);
                          selectedFormula.add(fileSpec.formula!);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(label: "print", icon: Icon(Icons.print)),
          BottomNavigationBarItem(label: "print", icon: Icon(Icons.print))
        ],
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
