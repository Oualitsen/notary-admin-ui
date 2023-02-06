import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/src/subjects/subject.dart';

class TimeRangeWidget extends StatefulWidget {
  final void Function(TimeOfDay) onChanged;
  final TimeOfDay? initialValue;
  const TimeRangeWidget({Key? key, required this.onChanged, this.initialValue})
      : super(key: key);

  @override
  State<TimeRangeWidget> createState() => _TimeRangeWidgetState();
}

class _TimeRangeWidgetState extends BasicState<TimeRangeWidget> {
  var hours = new List<int>.generate(24, (i) => i);
  var minutes = new List<int>.generate(12, (i) => i);
  int? hour;
  int? minute;

  @override
  void initState() {
    if (widget.initialValue != null) {
      hour = widget.initialValue!.hour;
      minute = widget.initialValue!.minute;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          color: Colors.red,
          child: SizedBox(
            height: 64,
            width: 224,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        items: hours
                            .map((e) => DropdownMenuItem<int>(
                                  alignment: AlignmentDirectional.center,
                                  child: Text("${e}"),
                                  value: e,
                                ))
                            .toList(),
                        onChanged: (int? value) {
                          hour = value;
                          onChanged();
                        },
                        value: hour,
                      )
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Text(":"),
                SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        items: minutes
                            .map((e) => DropdownMenuItem<int>(
                                  alignment: AlignmentDirectional.center,
                                  child: Text(
                                    "${e * 5}",
                                  ),
                                  value: e * 5,
                                ))
                            .toList(),
                        onChanged: (int? value) {
                          minute = value;
                          onChanged();
                        },
                        value: minute,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  onChanged() {
    if (hour != null && minute != null) {
      TimeOfDay time = TimeOfDay(hour: hour!, minute: minute!);
      widget.onChanged(time);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
