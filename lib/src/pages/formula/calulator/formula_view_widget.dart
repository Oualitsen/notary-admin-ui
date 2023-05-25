import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_formula.dart';
import 'package:rxdart/src/subjects/subject.dart';

class FormulaViewWidget extends StatefulWidget {
  final ContractFormula formula;
  final double valueInput;
  final void Function(double sum) callBackCal;

  const FormulaViewWidget(this.formula,
      {super.key, required this.valueInput, required this.callBackCal});

  @override
  State<FormulaViewWidget> createState() => _FormulaViewWidgetState();
}

class _FormulaViewWidgetState extends BasicState<FormulaViewWidget>
    with WidgetUtilsMixin {
  double notarisationTax = 0.0;
  double registrationTax = 0.0;
  double publicityTax = 0.0;
  double stamp = 0.0;
  double vat = 0.0;

  void init() {
    notarisationTax = widget.formula.functions
        .firstWhere((element) => element.name == lang.notarizationTax)
        .getTax(widget.valueInput);

    registrationTax = (widget.formula.functions
            .firstWhere((element) => element.name == lang.registrationTax))
        .getTax(widget.valueInput);

    publicityTax = widget.formula.functions
        .firstWhere((element) => element.name == lang.publicityTax)
        .getTax(widget.valueInput);

    stamp = (widget.formula.pageNumber) *
        (widget.formula.copyNumber + 1) *
        (widget.formula.stamp);
    vat = (widget.formula.vat) * notarisationTax;
    sum();
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Card(
      child: ListView(
        children: [
          ListTile(
            title: Text(lang.stamp),
            trailing: Text("${stamp}"),
          ),
          ListTile(
            title: Text(lang.vat),
            trailing: Text("${vat.round()}"),
          ),
          ...widget.formula.functions
              .where((element) => element.name != null)
              .map((e) {
            if (e.name == lang.notarizationTax) {
              return ListTile(
                title: Text(e.name),
                trailing: Text("${notarisationTax.round()}"),
              );
            }
            if (e.name == lang.registrationTax) {
              return ListTile(
                title: Text(e.name),
                trailing: Text("${registrationTax}"),
              );
            }
            if (e.name == lang.publicityTax) {
              return ListTile(
                title: Text(e.name),
                trailing: Text("${publicityTax}"),
              );
            }
            return ListTile(
              title: Text(e.name),
              trailing: Text("${e.minValue}"),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
  sum() {
    var a = notarisationTax.round() +
        registrationTax +
        publicityTax +
        stamp +
        vat.round() +
        widget.formula.assetPrice +
        widget.formula.copyPrice;
    widget.callBackCal(a);
  }
}
