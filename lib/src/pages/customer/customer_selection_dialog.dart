import 'package:flutter/material.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/pages/search/search_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/rxdart.dart';

class CustomerSelectionDialog extends StatefulWidget {
  final Function(List<Customer> selectedCustomer)? onSave;
  const CustomerSelectionDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<CustomerSelectionDialog> createState() =>
      _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends BasicState<CustomerSelectionDialog>
    with WidgetUtilsMixin {
  final searchValueStream = BehaviorSubject<String>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  List<Customer> customerList = [];
  @override
  void initState() {
    searchValueStream
        .where((event) => listKey.currentState != null)
        .debounceTime(Duration(milliseconds: 500))
        .listen((value) {
      listKey.currentState?.reload();
    });
    super.initState();
  }

  @override
  void dispose() {
    searchValueStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SearchWidget(
        useType: false,
        type: null,
        onChange: ((searchValue) {
          searchValueStream.add(searchValue);
        }),
        moreActions: [Text(lang.selectCustomers)],
      ),
      content: SizedBox(
        height: 600,
        width: 600,
        child: StreamBuilder<String>(
            stream: searchValueStream,
            builder: (context, snapshot) {
              return CustomerSelection(
                searchValue: snapshot.data,
                listKey: listKey,
                selectionType: SelectionType.MULTIPLE,
                onSelect: (selectedCustomers) {
                  customerList = selectedCustomers;
                },
              );
            }),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCustomerPage(),
                    )).then(
                  (value) => listKey.currentState?.reload(),
                ),
                child: Text(
                  lang.addCustomer,
                ),
              ),
              getButtons(
                onSave: () => widget.onSave!(customerList),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
