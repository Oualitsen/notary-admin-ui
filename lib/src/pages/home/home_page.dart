import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/device_screen_type.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/pages/customer/customer_table_widget.dart';
import 'package:notary_admin/src/pages/search/search_widget.dart';

import 'package:notary_admin/src/pages/html/quil_html_editor.dart';

import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  static const home = "/";

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends BasicState<HomePage>
    with TickerProviderStateMixin, WidgetUtilsMixin {
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();
  final searchValueStream = BehaviorSubject.seeded("");
  @override
  void initState() {
    searchValueStream
        .where((event) => tableKey.currentState != null)
        .debounceTime(Duration(milliseconds: 500))
        .listen((value) {
      tableKey.currentState?.refreshPage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) {
      return Scaffold(
        drawer: type == DeviceScreenType.mobile ? createDrawer(context) : null,
        appBar: AppBar(
          title: Text(lang.customerList),
          actions: [
            SearchWidget(
              type: type,
              onChange: ((searchValue) {
                searchValueStream.add(searchValue);
              }),
              moreActions: [
                ElevatedButton.icon(
                  onPressed: reload,
                  label: Text(lang.reload.toUpperCase()),
                  icon: Icon(Icons.refresh),
                ),

                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: (() =>
                      push(context, AddCustomerPage()).listen((event) {
                        reload();
                      })),
                  label: Text(lang.addCustomer.toUpperCase()),
                  icon: Icon(Icons.add),
                ),

              ],
            ),
          ],
        ),
        body: StreamBuilder<String>(
            stream: searchValueStream,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomerTableWidget(
                  tableKey: tableKey,
                  searchValue: snapshot.data,
                ),
              );
            }),
      );
    });
  }

  reload() {
    tableKey.currentState?.refreshPage();
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
