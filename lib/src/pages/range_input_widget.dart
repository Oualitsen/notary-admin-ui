import 'package:flutter/material.dart';

import 'package:notary_admin/src/pages/contract_function_input_widget.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/range.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/src/subjects/subject.dart';

class RangeInputWidget extends StatefulWidget {
  final Range? range;

  const RangeInputWidget({super.key, this.range});

  @override
  State<RangeInputWidget> createState() => RangeInputWidgetState();
}

class RangeInputWidgetState extends BasicState<RangeInputWidget>
    with WidgetUtilsMixin {
  final lowerBoundCrl = TextEditingController();
  final upperBoundCtl = TextEditingController();
  final key = GlobalKey<FormState>();
  final cifKey = GlobalKey<ContractInputFunctionWidgetState>();
  @override
  void initState() {
    final r = widget.range;
    if (r != null) {
      lowerBoundCrl.text = r.lowerBound.toString();
      upperBoundCtl.text = r.upperBound.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: lowerBoundCrl,
                    decoration: getDecoration(lang.lowerBound, true),
                    validator: (text) {
                      return ValidationUtils.doubleValidator(text, context);
                    },
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: upperBoundCtl,
                    decoration: getDecoration(lang.upperBound, true),
                    validator: (text) {
                      return ValidationUtils.doubleValidator(text, context);
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            ContractInputFunctionWidget(
              range: widget.range,
              showName: false,
              canAddRanges: false,
              key: cifKey,
            )
          ],
        ),
      ),
    );
  }

  // must have a method that returns a nullable range.
  Range? range() {
    var state = key.currentState!;
    var function = cifKey.currentState?.read();
    var lowerBound = double.parse(lowerBoundCrl.text);
    var upperBound = double.parse(upperBoundCtl.text);
    if (state.validate() && function != null) {
      if (compare(lowerBound, upperBound) == true) {
        var range = Range(
            lowerBound: lowerBound,
            upperBound: upperBound,
            contractFunction: function);
        return range;
      } else {
        print("lower bound must be ");
        showAlertDialog(
            context: context,
            message: "Lower bound must be lower than pper bound");
      }
    }
    return null;
  }

  bool compare(double lower, double upper) {
    if (lower < upper)
      return true;
    else
      return false;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
