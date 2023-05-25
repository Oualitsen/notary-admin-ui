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
  final String defaultName;
  final bool showName;
  final Range? range;
  final bool canAddRanges;
  final bool hideSave;
  final Function(ContractFunction) onRead;
  final ContractFunction? contractFunction;
  const ContractFunctionInputWidget({
    super.key,
    required this.defaultName,
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
  final minvalueCtrl = TextEditingController();
  final isPercentage = BehaviorSubject.seeded(true);
  final key = GlobalKey<FormState>();
  final rangeStream = BehaviorSubject.seeded(<Range>[]);

  @override
  void initState() {
    var f = widget.contractFunction;
    if (f != null) {
      nameCtl.text = f.name;
      minvalueCtrl.text = "${f.minValue}";
      if (f.ranngeList != null) {
        rangeStream.add(reorderRangeList(f.ranngeList));
        print(rangeStream.value[0].upperBound);
        print(rangeStream.value[1].upperBound);
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
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: minvalueCtrl,
                    decoration: getDecoration(
                      lang.minValueTax,
                      true,
                    ),
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                  ),
                ),
              ],
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
                      child: Text(lang.addRange),
                      onPressed: () {
                        push<Range>(context, RangeInputPage()).listen((range) {
                          List<Range> rangeList = rangeStream.value;
                          rangeList.add(range);
                          rangeStream.add(rangeList);
                        });
                      },
                    ),
                  SizedBox(
                    width: 10,
                  ),
                  getButtons(
                      onSave: () {
                        if (key.currentState!.validate()) {
                          ContractFunction f = ContractFunction(
                              ranngeList: reorderRangeList(rangeStream.value),
                              //ranngeList: rangeStream.valueOrNull ?? [],
                              minValue: double.parse(minvalueCtrl.text),
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
      var value = double.parse(minvalueCtrl.text);

      return ContractFunction(
          ranngeList: reorderRangeList(rangeStream.value),
          // ranngeList: rangeStream.valueOrNull ?? [],

          minValue: value,
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

  List<Range> reorderRangeList(List<Range> ranges) {
    if (ranges.isNotEmpty)
      ranges.sort(((a, b) => a.lowerBound.compareTo(b.lowerBound)));
    return ranges;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
