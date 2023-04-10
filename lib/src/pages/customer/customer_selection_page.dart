import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rxdart/subjects.dart';

class CustomerSelection extends StatefulWidget {
  final SelectionType selectionType;
  final Function(List<Customer> selectedCustomers) onSelect;
  final GlobalKey<InfiniteScrollListViewState>? listKey;
  final String? searchValue;
  const CustomerSelection(
      {super.key,
      this.searchValue,
      this.selectionType = SelectionType.MULTIPLE,
      this.listKey,
      required this.onSelect});

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
    return widget.selectionType == SelectionType.MULTIPLE
        ? selectMultiple()
        : selectOne();
  }

  Widget selectMultiple() {
    return StreamBuilder<List<Customer>>(
      stream: selectedCustomerStream,
      initialData: selectedCustomerStream.value,
      builder: (context, snapshot) {
        return InfiniteScrollListView<Customer>(
          key: widget.listKey,
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
                  widget.onSelect(selectedCustomers);
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
              widget.onSelect([element]);
            },
          );
        },
        pageLoader: getData);
  }

  Future<List<Customer>> getData(int index) {
    if (widget.searchValue == null || widget.searchValue!.isEmpty) {
      return service.getCustomers(pageIndex: index, pageSize: 10);
    }
    return service.searchCustomers(
        name: widget.searchValue!, index: index, size: 10);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
