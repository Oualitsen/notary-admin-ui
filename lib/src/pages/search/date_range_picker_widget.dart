import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

class DateRangePickerWidget extends StatefulWidget {
  final Function(DateRange range) onSave;
  final DateRange? range;
  DateRangePickerWidget({super.key, required this.onSave, this.range});
  @override
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends BasicState<DateRangePickerWidget>
    with WidgetUtilsMixin {
  //stream
  final startDateStream = BehaviorSubject<DateTime?>();
  final endDateStream = BehaviorSubject<DateTime?>();
  //input controller
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  @override
  void initState() {
    if (widget.range?.startDate != null) {
      startDateStream.add(widget.range!.startDate!);
    }

    if (widget.range?.endDate != null) {
      endDateStream.add(widget.range!.endDate!);
    }

    startDateStream.listen((value) {
      if (value == null) {
        startDateCtrl.text = "";
      } else {
        startDateCtrl.text = lang.formatDateDate(value);
      }
    });
    endDateStream.listen((value) {
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
                  startDateStream.add(null);
                },
                icon: Icon(Icons.cancel),
              ),
            ],
          ),
          SizedBox(height: 20),
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
                  endDateStream.add(null);
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
            widget.onSave(DateRange(
                startDate: startDateStream.valueOrNull,
                endDate: endDateStream.valueOrNull));
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool start) async {
    DateTime? value;
    if (start) {
      value = startDateStream.valueOrNull;
    } else {
      value = endDateStream.valueOrNull;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime.now().add(Duration(days: -365 * 100)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != value) {
      var startDate = startDateStream.valueOrNull;
      var endDate = endDateStream.valueOrNull;
      if (start) {
        if (startDate != null &&
            startDate.millisecondsSinceEpoch < picked.millisecondsSinceEpoch) {
          endDateStream.add(picked);
          startDateStream.add(endDate);
        } else {
          startDateStream.add(picked);
        }
      } else {
        if (startDate != null &&
            startDate.millisecondsSinceEpoch > picked.millisecondsSinceEpoch) {
          startDateStream.add(picked);
          endDateStream.add(startDate);
        } else {
          endDateStream.add(picked);
        }
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  DateRange({required this.startDate, required this.endDate});
}
