import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/formula/range_input_page.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/pages/formula/range_widget.dart';
import 'package:notary_model/model/contract_function.dart';
import 'package:notary_model/model/range.dart';
import 'package:rxdart/rxdart.dart';

class ContractFunctionInputWidget extends StatefulWidget {
  final String? defaultName;
  final bool showName;
  final Range? range;
  final bool canAddRanges;
  final bool hideSave;
  final Function(ContractFunction) onRead;
  final ContractFunction? contractFunction;
  const ContractFunctionInputWidget({
    super.key,
    this.defaultName,
    this.showName = true,
    this.canAddRanges = true,
    this.range,
    this.hideSave = false,
    required this.onRead,
    this.contractFunction,
  });

  @override
  State<ContractFunctionInputWidget> createState() =>
      ContractFunctionInputWidgetState();
}

class ContractFunctionInputWidgetState
    extends BasicState<ContractFunctionInputWidget> with WidgetUtilsMixin {
  final nameCtl = TextEditingController();
  final valueCtrl = TextEditingController();
  final isPercentage = BehaviorSubject.seeded(false);
  final key = GlobalKey<FormState>();
  final rangeStream = BehaviorSubject.seeded(<Range>[]);

  @override
  void initState() {
    var c = widget.range;
    if (c != null) {
      valueCtrl.text = c.contractFunction.value.toString();
      isPercentage.add(c.contractFunction.percentage);
    }

    var f = widget.contractFunction;
    if (f != null) {
      nameCtl.text = f.name!;
      valueCtrl.text = "${f.value}";
      isPercentage.add(f.percentage);
      if (f.rangeList != null) {
        rangeStream.add(f.rangeList!);
      }
    }

    super.initState();
  }

  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                if (widget.showName) ...[
                  Expanded(
                      child: TextFormField(
                    controller: nameCtl,
                    decoration: getDecoration(
                      lang.name,
                      true,
                    ),
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                  )),
                  SizedBox(width: 10),
                ],
                Expanded(
                  child: StreamBuilder<bool>(
                      initialData: isPercentage.value,
                      stream: isPercentage,
                      builder: (context, snapshot) {
                        var isP = snapshot.data!;
                        return TextFormField(
                          keyboardType: TextInputType.number,
                          controller: valueCtrl,
                          decoration: getDecoration(
                              lang.value, true, '', isP ? Text("%") : null),
                          validator: (text) {
                            if (isPercentage.value) {
                              return ValidationUtils.doubleValidator(
                                  text, context,
                                  required: true, minValue: 0, maxValue: 100);
                            }
                            return ValidationUtils.doubleValidator(
                                text, context,
                                required: true);
                          },
                        );
                      }),
                )
              ],
            ),
            StreamBuilder<bool>(
              stream: isPercentage,
              builder: (context, snapshot) {
                return CheckboxListTile(
                  title: Text(lang.percentage),
                  value: isPercentage.value,
                  onChanged: (value) {
                    if (value != null) {
                      isPercentage.add(value);
                    }
                  },
                );
              },
            ),
            StreamBuilder<List<Range>>(
              stream: rangeStream,
              initialData: rangeStream.valueOrNull,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                var ranges = snapshot.data!;
                return Column(
                  children: ranges
                      .map((e) => RangeWidget(
                            range: e,
                            onDelete: (range) {
                              ranges.remove(range);
                              rangeStream.add(ranges);
                            },
                            onEdit: (range) {
                              ranges.remove(e);
                              ranges.add(range);
                              rangeStream.add(ranges);
                            },
                          ))
                      .toList(),
                );
              },
            ),
            if (!widget.hideSave)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.canAddRanges)
                    ElevatedButton(
                      onPressed: () {
                        push<Range>(context, RangeInputPage()).listen((range) {
                          List<Range> rangeList = rangeStream.value;
                          rangeList.add(range);
                          rangeStream.add(rangeList);
                        });
                      },
                      child: Text(lang.addRange),
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  getButtons(
                      onSave: () {
                        //create a contract function and call widget.onRead()
                        //
                        if (key.currentState!.validate()) {
                          ContractFunction f = ContractFunction(
                              rangeList: rangeStream.valueOrNull ?? [],
                              value: double.parse(valueCtrl.text),
                              percentage: isPercentage.value,
                              name: widget.showName
                                  ? nameCtl.text
                                  : widget.defaultName);
                          widget.onRead(f);
                        }
                      },
                      skipCancel: true),
                ],
              )
          ],
        ),
      ),
    );
  }

  ContractFunction? read() {
    if (key.currentState!.validate()) {
      var _isPercentage = isPercentage.value;
      var value = double.parse(valueCtrl.text);
      if (_isPercentage) {
        value = value / 100;
      }
      return ContractFunction(
          value: value,
          percentage: _isPercentage,
          name: widget.showName ? nameCtl.text : "");
    }
    return null;
  }

  bool validatePercentage(double value) {
    if (value <= 100)
      return true;
    else
      return false;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
