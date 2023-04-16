import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:notary_admin/src/pages/range_input_widget.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/range.dart';
import 'package:rxdart/src/subjects/subject.dart';

class RangePage extends StatefulWidget {
  final Range? range;
  
  const RangePage({super.key, this.range});

  @override
  State<RangePage> createState() => _RangePageState();
}

class _RangePageState extends BasicState<RangePage> with WidgetUtilsMixin {
  final rangeKey = GlobalKey<RangeInputWidgetState>();
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(),
          body: ListView(
            children: [
              RangeInputWidget(
                key: rangeKey,
                range: widget.range,
              ),
              getButtons(
                onSave: readRange,
                skipCancel: true,
              )
            ],
          ),
        ));
  }

  readRange() {
    var range = rangeKey.currentState?.range();
    if (range != null) {
      Navigator.of(context).pop(range);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
