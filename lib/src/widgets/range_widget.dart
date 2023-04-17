import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/range_page.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/range.dart';
import 'package:rxdart/src/subjects/subject.dart';

class RangeWidget extends StatefulWidget {
  final Range range;
  final Function(Range range) onDelete;
  const RangeWidget({super.key, required this.range, required this.onDelete});

  @override
  State<RangeWidget> createState() => _RangeWidgetState();
}

class _RangeWidgetState extends BasicState<RangeWidget> with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${widget.range.lowerBound} - ${widget.range.upperBound} "),
      subtitle: Text("${widget.range.contractFunction.value}"),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () => push(
                  context,
                  RangePage(
                    range: widget.range,
                  )),
              icon: Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                widget.onDelete(widget.range);
              },
              icon: Icon(Icons.delete))
        ],
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => throw UnimplementedError();

  @override
  List<Subject> get subjects => throw UnimplementedError();
}
