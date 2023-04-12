import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

class DateRangePickerWidget extends StatefulWidget {
  final Function(List<int> range) onSave;
  final int? startDate;
  final int? endDate;
  DateRangePickerWidget(
      {super.key, required this.onSave, this.endDate, this.startDate});
  @override
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends BasicState<DateRangePickerWidget>
    with WidgetUtilsMixin {
  final _startDate = BehaviorSubject<DateTime?>();
  final _endDate = BehaviorSubject<DateTime?>();
  //input controller
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  @override
  void initState() {
    print("end date = ${widget.endDate}");
    if (widget.startDate != null) {
      _startDate.add(DateTime.fromMillisecondsSinceEpoch(widget.startDate!));
    }

    if (widget.endDate != null) {
      _endDate.add(DateTime.fromMillisecondsSinceEpoch(widget.endDate!));
    }

    _startDate.listen((value) {
      if (value == null) {
        startDateCtrl.text = "";
      } else {
        startDateCtrl.text = lang.formatDateDate(value);
      }
    });
    _endDate.listen((value) {
      if (value == null) {
        endDateCtrl.text = "";
      } else {
        endDateCtrl.text = lang.formatDateDate(value);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(lang.selectDateRange),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: wrapInIgnorePointer(
                  child: TextFormField(
                    controller: startDateCtrl,
                    decoration: getDecoration(lang.startDate, false),
                  ),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              IconButton(
                onPressed: () {
                  _startDate.add(null);
                },
                icon: Icon(Icons.cancel),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: wrapInIgnorePointer(
                  child: TextFormField(
                    controller: endDateCtrl,
                    decoration: getDecoration(lang.endDate, false),
                  ),
                  onTap: () => _selectDate(context, false),
                ),
              ),
              IconButton(
                onPressed: () {
                  _endDate.add(null);
                },
                icon: Icon(Icons.cancel),
              ),
            ],
          ),
        ],
      ),
      actions: [
        getButtons(
          onSave: () {
            widget.onSave(List.of([
              _startDate.valueOrNull?.millisecondsSinceEpoch ?? -1,
              _endDate.valueOrNull?.millisecondsSinceEpoch ?? -1,
            ]));
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool start) async {
    var value = start ? _startDate.valueOrNull : _endDate.valueOrNull;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime.now().add(Duration(days: -365 * 100)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != value) {
      var startDate = _startDate.valueOrNull;
      var endDate = _endDate.valueOrNull;
      if (start) {
        if (startDate != null &&
            startDate.millisecondsSinceEpoch < picked.millisecondsSinceEpoch) {
          _endDate.add(picked);
          _startDate.add(endDate);
        } else {
          _startDate.add(picked);
        }
      } else {
        if (startDate != null &&
            startDate.millisecondsSinceEpoch > picked.millisecondsSinceEpoch) {
          _startDate.add(picked);
          _endDate.add(startDate);
        } else {
          _endDate.add(picked);
        }
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
