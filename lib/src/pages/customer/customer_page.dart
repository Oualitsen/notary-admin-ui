import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/pages/customer/customer_table_widget.dart';
import 'package:notary_admin/src/pages/search/search_widget.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:rxdart/rxdart.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends BasicState<CustomerPage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<CustomerService>();
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
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.customerList),
          actions: [
            SearchWidget(
                type: type,
                onChange: ((searchValue) {
                  searchValueStream.add(searchValue);
                })),
          ],
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.push<Customer?>(
              context,
              MaterialPageRoute(builder: (context) => AddCustomerPage()),
            ).then((value) {
              if (value != null) {
                tableKey.currentState?.refreshPage();
              }
            });
          },
          child: Text(lang.addCustomer.toUpperCase()),
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
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
