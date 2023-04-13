import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:notary_admin/src/pages/range_input_widget.dart';
import 'package:notary_admin/src/pages/range_page.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/widgets/range_widget.dart';
import 'package:notary_model/model/contract_function.dart';
import 'package:notary_model/model/range.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ContractInputFunctionWidget extends StatefulWidget {
  final bool showName;
  final Range? range;
  final bool canAddRanges;
  const ContractInputFunctionWidget(
      {super.key, this.showName = true, this.canAddRanges = true, this.range});

  @override
  State<ContractInputFunctionWidget> createState() =>
      ContractInputFunctionWidgetState();
}

class ContractInputFunctionWidgetState
    extends BasicState<ContractInputFunctionWidget> with WidgetUtilsMixin {
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
                      decoration: getDecoration(lang.name, true),
                      validator: (text) {
                        return ValidationUtils.requiredField(text, context);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                ],
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: valueCtrl,
                    decoration: getDecoration(lang.value, true),
                    validator: (text) {
                      return ValidationUtils.requiredField(text, context);
                    },
                  ),
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
            // add list range button
            if (widget.canAddRanges)
              ElevatedButton(
                onPressed: () async {
                  var range = await push<Range>(context, RangePage()).first;
                  List<Range> rangeList = rangeStream.value;
                  rangeList.add(range);
                  rangeStream.add(rangeList);
                },
                child: Text('Add range'),
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
                            ))
                        .toList(),
                  );
                })
          ],
        ),
      ),
    );
  }

  ContractFunction? read() {
    if (key.currentState!.validate()) {
      var contract = ContractFunction(
          value: double.parse(valueCtrl.text), percentage: isPercentage.value);
      return contract;
    }
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
