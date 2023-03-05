import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/subjects.dart';

class CustomerSelection extends StatefulWidget {
  final SelectionType selectionType;
  const CustomerSelection(
      {super.key, this.selectionType = SelectionType.MULTIPLE});

  @override
  State<CustomerSelection> createState() => _CustomerSelectionState();
}

class _CustomerSelectionState extends BasicState<CustomerSelection>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<CustomerService>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  final selectedCustomerStream = BehaviorSubject.seeded(<Customer>[]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.customerList),
        actions: [
          ElevatedButton(
              onPressed: () {
                push(context, AddCustomerPage());
              },
              child: Text(lang.addCustomer))
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: save,
        child: Text(lang.ok.toUpperCase()),
      ),
      body: widget.selectionType == SelectionType.MULTIPLE
          ? selectMultiple()
          : selectOne(),
    );
  }

  Widget selectMultiple() {
    return StreamBuilder<List<Customer>>(
      stream: selectedCustomerStream,
      initialData: selectedCustomerStream.value,
      builder: (context, snapshot) {
        return InfiniteScrollListView<Customer>(
          elementBuilder:
              (BuildContext context, element, int index, animation) {
            final selectedCustomers = snapshot.data!;

            return CheckboxListTile(
              value: selectedCustomers.contains(element),
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  if (newValue) {
                    selectedCustomers.add(element);
                  } else {
                    selectedCustomers.remove(element);
                  }
                  selectedCustomerStream.add(selectedCustomers);
                }
              },
              title: ListTile(
                leading: CircleAvatar(
                  child: Text(
                      "${element.firstName[0].toUpperCase()} ${element.lastName[0].toUpperCase()}"),
                ),
                title: Text(
                    "${element.firstName} ${element.lastName.toUpperCase()}"),
                subtitle: Text("${lang.formatDate(element.creationDate)}"),
                onTap: null,
              ),
            );
          },
          pageLoader: getData,
        );
      },
    );
  }

  Widget selectOne() {
    return InfiniteScrollListView(
        elementBuilder: (context, element, index, animation) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                  "${element.firstName[0].toUpperCase()} ${element.lastName[0].toUpperCase()}"),
            ),
            title:
                Text("${element.firstName} ${element.lastName.toUpperCase()}"),
            subtitle: Text("${lang.formatDate(element.creationDate)}"),
            onTap: () {
              Navigator.of(context).pop(element);
            },
          );
        },
        pageLoader: getData);
  }

  Future<List<Customer>> getData(int index) {
    return service.getCustomers(pageIndex: index, pageSize: 10);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void save() {
    Navigator.of(context).pop(selectedCustomerStream.value);
  }
}
