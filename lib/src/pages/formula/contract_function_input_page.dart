import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/formula/contract_function_input_widget.dart';
import 'package:notary_model/model/contract_function.dart';

class ContactFunctionInputPage extends StatelessWidget {
  final String title;
  final bool? showName;
  final ContractFunction? contractFunction;
  const ContactFunctionInputPage(
      {super.key, required this.title, this.showName, this.contractFunction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ContractFunctionInputWidget(
          contractFunction: contractFunction,
          showName: showName != null ? showName! : false,
          onRead: (function) => Navigator.of(context).pop(function),
          defaultName: title,
        ),
      ),
    );
  }
}
