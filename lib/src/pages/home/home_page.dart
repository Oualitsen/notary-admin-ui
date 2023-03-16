import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/device_screen_type.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/customer/customer_table_widget.dart';
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
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) {
      return Scaffold(
          drawer:
              type == DeviceScreenType.mobile ? createDrawer(context) : null,
          appBar: AppBar(
            title: Text(lang.customerList),
            actions: [
              ElevatedButton.icon(
                onPressed: reload,
                label: Text(lang.reload),
                icon: Icon(Icons.refresh),
              )
            ],
          ),
          body: CustomerTableWidget(
            tableKey: tableKey,
          ));
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

