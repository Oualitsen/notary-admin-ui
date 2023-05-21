import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ContractCalculatorInputWidget extends StatefulWidget {
  final FilesSpec filesSpec;
  final void Function(double value) onCall;
  const ContractCalculatorInputWidget(
      {super.key, required this.filesSpec, required this.onCall});

  @override
  State<ContractCalculatorInputWidget> createState() =>
      _ContractCalculatorInputWidgetState();
}

class _ContractCalculatorInputWidgetState
    extends BasicState<ContractCalculatorInputWidget> with WidgetUtilsMixin {
  List<TextEditingController> listInputContractCategoryCtrl = [];

  init() {
    listInputContractCategoryCtrl = List.generate(
        widget.filesSpec.contractCategory.listContractCategoryInput.length,
        (index) {
      return TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Form(
      onChanged: () {
        if (widget
                .filesSpec.contractCategory.listContractCategoryInput.length ==
            3) {
          var val1 =
              double.tryParse(listInputContractCategoryCtrl[1].text) ?? 0.0;
          var val2 =
              double.tryParse(listInputContractCategoryCtrl[2].text) ?? 0.0;
          var res = val1 * val2;
          widget.onCall(res);
          listInputContractCategoryCtrl[0].text = res.toString();
        }
        if (widget
                .filesSpec.contractCategory.listContractCategoryInput.length ==
            1) {
          var res =
              double.tryParse(listInputContractCategoryCtrl[0].text) ?? 0.0;
          widget.onCall(res);
        }
      },
      child: Row(
        children: [
          ...List.generate(
            widget.filesSpec.contractCategory.listContractCategoryInput.length,
            (index) {
              var list =
                  widget.filesSpec.contractCategory.listContractCategoryInput;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: (widget.filesSpec.contractCategory
                                  .listContractCategoryInput.length ==
                              3 &&
                          index == 0)
                      ? wrapInIgnorePointer(
                          onTap: () {},
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: getDecoration(list[index], true),
                            controller: listInputContractCategoryCtrl[index],
                          ),
                        )
                      : TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: getDecoration(list[index], true),
                          controller: listInputContractCategoryCtrl[index],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
