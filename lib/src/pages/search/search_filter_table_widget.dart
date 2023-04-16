import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/archiving/files_archived_table_widget.dart';
import 'package:notary_admin/src/pages/search/date_range_picker_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:rxdart/rxdart.dart';

class SearchFilterTableWidget extends StatefulWidget {
  final void Function(SearchParams) onSearchParamsChanged;
  const SearchFilterTableWidget({
    super.key,
    required this.onSearchParamsChanged,
  });

  @override
  State<SearchFilterTableWidget> createState() =>
      SearchFilterTableWidgetState();
}

class SearchFilterTableWidgetState extends BasicState<SearchFilterTableWidget>
    with WidgetUtilsMixin {
  final subject = BehaviorSubject.seeded(SearchParams2(
      customers: [],
      fileSpecName: "",
      number: "",
      range: DateRange(endDate: null, startDate: null)));
  @override
  void initState() {
    subject.listen((SearchParams2 value) {
      widget.onSearchParamsChanged(_getParams());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchParams2>(
      stream: subject,
      initialData: subject.value,
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (data == null) {
          return SizedBox.shrink();
        }
        var filesCode = data.number;
        var filesSpec = data.fileSpecName;
        var customers = data.customers;
        // create the date range
        var range = data.range;
        return Wrap(spacing: 20, children: [
          range.startDate != null
              ? InputChip(
                  label: Text(
                      "${lang.start} : ${lang.formatDateDate(range.startDate!)}"),
                  onDeleted: () {
                    range = DateRange(startDate: null, endDate: range.endDate);
                    var currentValue = subject.value;
                    currentValue.range = range;
                    subject.add(currentValue);
                  },
                  deleteIcon: Icon(Icons.cancel),
                )
              : SizedBox.shrink(),
          range.endDate != null
              ? InputChip(
                  label: Text(
                      "${lang.end} : ${lang.formatDateDate(range.endDate!)}"),
                  onDeleted: () {
                    range =
                        DateRange(startDate: range.startDate, endDate: null);
                    var currentValue = subject.value;
                    currentValue.range = range;
                    subject.add(currentValue);
                  },
                  deleteIcon: Icon(Icons.cancel),
                )
              : SizedBox.shrink(),
          filesCode.isNotEmpty
              ? InputChip(
                  label: Text("${filesCode}"),
                  onDeleted: () {
                    var currentValue = subject.value;
                    currentValue.number = "";
                    subject.add(currentValue);
                  },
                  deleteIcon: Icon(Icons.cancel),
                )
              : SizedBox.shrink(),
          filesSpec.isNotEmpty
              ? InputChip(
                  label: Text("${filesSpec}"),
                  onDeleted: () {
                    var currentValue = subject.value;
                    currentValue.fileSpecName = "";
                    subject.add(currentValue);
                  },
                  deleteIcon: Icon(Icons.cancel),
                )
              : SizedBox.shrink(),
          ...customers
              .map(
                (e) => InputChip(
                  label: Text("${e.firstName} ${e.lastName}"),
                  onDeleted: () {
                    var currentValue = subject.value;
                    currentValue.customers.remove(e);
                    subject.add(currentValue);
                  },
                  deleteIcon: Icon(Icons.cancel),
                ),
              )
              .toList()
        ]);
      },
    );
  }

  void refresh(SearchParams2 searchParams) {
    subject.add(searchParams);
  }

  SearchParams _getParams() {
    var value = subject.value;
    var startDate = -1;
    var endDate = -1;
    if (value.range.startDate != null) {
      startDate = value.range.startDate!.millisecondsSinceEpoch;
    }
    if (value.range.endDate != null) {
      endDate = value.range.endDate!.millisecondsSinceEpoch;
    }
    var searchParams = SearchParams(
      number: value.number,
      fileSpecName: value.fileSpecName,
      customerIds: value.customers.map((e) => e.id).join(","),
      startDate: startDate,
      endDate: endDate,
    );
    return searchParams;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class SearchParams2 {
  String number;
  String fileSpecName;
  List<Customer> customers;
  DateRange range;

  SearchParams2({
    required this.number,
    required this.fileSpecName,
    required this.customers,
    required this.range,
  });
}
