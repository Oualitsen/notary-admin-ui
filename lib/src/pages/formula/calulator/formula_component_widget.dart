import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/src/subjects/subject.dart';

class FormulaComponentWidget extends StatefulWidget {
  FormulaComponentWidget(
      {super.key,
      required this.assetPriceValue,
      required this.copyPriceValue,
      required this.pageNumberValue,
      required this.copyNumberValue});

  final double assetPriceValue;
  final double copyPriceValue;
  final double pageNumberValue;
  final double copyNumberValue;

  @override
  State<FormulaComponentWidget> createState() => _FormulaComponentWidgetState();
}

class _FormulaComponentWidgetState extends BasicState<FormulaComponentWidget>
    with WidgetUtilsMixin {
  final assetPriceCtrl = TextEditingController();
  final copyPriceCtrl = TextEditingController();
  final pageNumberCtrl = TextEditingController();
  final copyNumberCtrl = TextEditingController();

  void init() {
    assetPriceCtrl.text = widget.assetPriceValue.toString();
    copyPriceCtrl.text = widget.copyPriceValue.toString();
    pageNumberCtrl.text = widget.pageNumberValue.toString();
    copyNumberCtrl.text = widget.copyNumberValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Form(
      child: Row(children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: getDecoration(lang.pageNumber, false),
                  controller: pageNumberCtrl,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: getDecoration(lang.assetPrice, false),
            controller: assetPriceCtrl,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: getDecoration(lang.copyNumber, false),
            controller: copyNumberCtrl,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: getDecoration(lang.copyPrice, false),
            controller: copyPriceCtrl,
          ),
        )
      ]),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
