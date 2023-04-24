import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/formula/range_input_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/range.dart';
import 'package:rxdart/src/subjects/subject.dart';

class RangeInputPage extends StatefulWidget {
  final Range? range;

  const RangeInputPage({super.key, this.range});

  @override
  State<RangeInputPage> createState() => RangeInputPageState();
}

class RangeInputPageState extends BasicState<RangeInputPage>
    with WidgetUtilsMixin {
  final rangeKey = GlobalKey<RangeInputWidgetState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          RangeInputWidget(
            key: rangeKey,
            range: widget.range,
          ),
          getButtons(
            saveLabel: lang.save,
            onSave: readRange,
            skipCancel: false,
          )
        ],
      ),
    );
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
