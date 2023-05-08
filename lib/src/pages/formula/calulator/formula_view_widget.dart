import 'package:flutter/material.dart';
import 'package:notary_model/model/contract_formula.dart';

class FormulaViewWidget extends StatelessWidget {
  final ContractFormula formula;
  const FormulaViewWidget(this.formula, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        children: formula.functions
            .where((element) => element.name != null)
            .map((e) => ListTile(
                  title: Text(e.name!),
                  trailing: Text("${e.value}"),
                ))
            .toList(),
      ),
    );
  }
}
