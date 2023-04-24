import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/formula/range_input_page.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/range.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';

class RangeWidget extends StatefulWidget {
  final Range range;
  final Function(Range range) onDelete;

  RangeWidget({super.key, required this.range, required this.onDelete});

  @override
  State<RangeWidget> createState() => _RangeWidgetState();
}

class _RangeWidgetState extends BasicState<RangeWidget> with WidgetUtilsMixin {
  final streamRange = BehaviorSubject<Range>();

  @override
  void initState() {
    streamRange.add(widget.range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Range>(
        stream: streamRange,
        initialData: streamRange.value,
        builder: (context, snapshot) {
          var range = snapshot.data;
          if (range == null) {
            return SizedBox.shrink();
          }

          return ListTile(
            onTap: () async {
              Range _range = await push<Range>(
                  context,
                  RangeInputPage(
                    range: range,
                  )).first;
              print(_range.upperBound);
              streamRange.add(_range);
            },
            title: Text("${range.lowerBound} - ${range.upperBound} "),
            subtitle: Text("${range.contractFunction.value}"),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      widget.onDelete(widget.range);
                    },
                    icon: Icon(Icons.delete))
              ],
            ),
          );
        });
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
