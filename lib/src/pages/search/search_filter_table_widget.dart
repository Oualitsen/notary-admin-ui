import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/search/date_range_picker_widget.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_model/model/customer.dart';

class SearchFilterTableWidget extends StatelessWidget {
  final void Function(SearchParams2 searchParams2) onSearchParamsChanged;
  final SearchParams2 searchParam;
  SearchFilterTableWidget({
    super.key,
    required this.onSearchParamsChanged,
    required this.searchParam,
  });

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);

    var filesCode = searchParam.number;
    var filesSpec = searchParam.fileSpecName;
    var customers = searchParam.customers;
    var range = searchParam.range;
    return Container(
      padding: EdgeInsets.all(10.0),
      height: 55,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Wrap(spacing: 20, children: [
                  range.startDate != null
                      ? InputChip(
                          label: Text(
                              "${lang.start} : ${lang.formatDateDate(range.startDate!)}"),
                          onDeleted: () {
                            range = DateRange(
                                startDate: null, endDate: range.endDate);

                            onSearchParamsChanged(
                              SearchParams2(
                                range: range,
                                customers: customers,
                                fileSpecName: filesSpec,
                                number: filesCode,
                              ),
                            );
                          },
                          deleteIcon: Icon(Icons.cancel),
                        )
                      : SizedBox.shrink(),
                  range.endDate != null
                      ? InputChip(
                          label: Text(
                              "${lang.end} : ${lang.formatDateDate(range.endDate!)}"),
                          onDeleted: () {
                            range = DateRange(
                                startDate: range.startDate, endDate: null);
                            onSearchParamsChanged(
                              SearchParams2(
                                range: range,
                                customers: customers,
                                fileSpecName: filesSpec,
                                number: filesCode,
                              ),
                            );
                          },
                          deleteIcon: Icon(Icons.cancel),
                        )
                      : SizedBox.shrink(),
                  filesCode.isNotEmpty
                      ? InputChip(
                          label: Text("${filesCode}"),
                          onDeleted: () {
                            onSearchParamsChanged(
                              SearchParams2(
                                range: range,
                                customers: customers,
                                fileSpecName: filesSpec,
                                number: "",
                              ),
                            );
                          },
                          deleteIcon: Icon(Icons.cancel),
                        )
                      : SizedBox.shrink(),
                  filesSpec.isNotEmpty
                      ? InputChip(
                          label: Text("${filesSpec}"),
                          onDeleted: () {
                            onSearchParamsChanged(
                              SearchParams2(
                                range: range,
                                customers: customers,
                                fileSpecName: "",
                                number: filesCode,
                              ),
                            );
                          },
                          deleteIcon: Icon(Icons.cancel),
                        )
                      : SizedBox.shrink(),
                  ...customers
                      .map(
                        (e) => InputChip(
                          label: Text("${e.firstName} ${e.lastName}"),
                          onDeleted: () {
                            customers.remove(e);
                            onSearchParamsChanged(
                              SearchParams2(
                                range: range,
                                customers: customers,
                                fileSpecName: filesSpec,
                                number: filesCode,
                              ),
                            );
                          },
                          deleteIcon: Icon(Icons.cancel),
                        ),
                      )
                      .toList()
                ]),
              ],
            ),
          ),
          SizedBox(width: 20),
          WidgetMixin.getParams(searchParam) != null
              ? ElevatedButton.icon(
                  onPressed: (() {
                    onSearchParamsChanged(
                      SearchParams2(
                        range: DateRange(endDate: null, startDate: null),
                        customers: [],
                        fileSpecName: "",
                        number: "",
                      ),
                    );
                  }),
                  label: Text(lang.reset.toUpperCase()),
                  icon: Icon(Icons.replay_outlined),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
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

class SearchParams {
  final String number;
  final String fileSpecName;
  final String customerIds;
  final int startDate;
  final int endDate;

  SearchParams({
    required this.number,
    required this.fileSpecName,
    required this.customerIds,
    required this.startDate,
    required this.endDate,
  });
}
