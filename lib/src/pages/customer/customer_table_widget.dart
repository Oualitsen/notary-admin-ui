import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/pages/customer/customer_detail_page.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:rxdart/src/subjects/subject.dart';

class CustomerTableWidget extends StatefulWidget {
  final GlobalKey<LazyPaginatedDataTableState>? tableKey;
  CustomerTableWidget({super.key, this.tableKey});

  @override
  State<CustomerTableWidget> createState() => _CustomerTableWidgetState();
}

class _CustomerTableWidgetState extends BasicState<CustomerTableWidget>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<CustomerService>();
  bool initialized = false;
  final columnSpacing = 65.0;
  List<DataColumn> columns = [];
  late GlobalKey<LazyPaginatedDataTableState> tableKey;

  @override
  void initState() {
    tableKey = widget.tableKey != null
        ? widget.tableKey!
        : GlobalKey<LazyPaginatedDataTableState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    columns = [
      DataColumn(label: Text(lang.firstName.toUpperCase())),
      DataColumn(label: Text(lang.lastName.toUpperCase())),
      DataColumn(label: Text(lang.gender.toUpperCase())),
      DataColumn(label: Text(lang.dateOfBirth.toUpperCase())),
      DataColumn(label: Text(lang.idCard.toUpperCase())),
      DataColumn(label: Text(lang.address.toUpperCase())),
      DataColumn(label: Text(lang.edit.toUpperCase())),
      DataColumn(label: Text(lang.customerDetails.toUpperCase())),
      DataColumn(label: Text(lang.delete.toUpperCase()))
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LazyPaginatedDataTable<Customer>(
        key: tableKey,
        columnSpacing: columnSpacing,
        getData: getData,
        getTotal: getTotal,
        columns: columns,
        dataToRow: dataToRow,
        checkboxHorizontalMargin: 20,
        sortAscending: true,
        dataRowHeight: 40,
      ),
    );
  }

  Future<List<Customer>> getData(PageInfo page) {
    return service.getCustomers(
        pageIndex: page.pageIndex, pageSize: page.pageSize);
  }

  Future<int> getTotal() {
    return service.getCustomersCount();
  }

  DataRow dataToRow(Customer data, int indexInCurrentPage) {
    var cellList = [
      DataCell(Text(data.firstName)),
      DataCell(Text(data.lastName)),
      DataCell(Text(lang.genderName(data.gender))),
      DataCell(Text(lang.formatDate(data.dateOfBirth))),
      DataCell(Text(data.idCard.idCardId)),
      DataCell(Text(lang.formatAddress(data.address))),
      DataCell(
        TextButton(
          child: Text(lang.edit),
          onPressed: () {
            push(context, AddCustomerPage(customer: data))
                .listen((_) => tableKey.currentState?.refreshPage());
          },
        ),
      ),
      DataCell(
        TextButton(
          child: Text(lang.customerDetails),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CustomerDetailsPage(
                        customer: data,
                      )),
            );
          },
        ),
      ),
      DataCell(
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(lang.confirm),
                content: Text(lang.confirmDelete),
                actions: <Widget>[
                  TextButton(
                    child: Text(lang.no.toUpperCase()),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                      child: Text(lang.yes.toUpperCase()),
                      onPressed: () async {
                        try {
                          await service.deleteCustomer(data.id);
                          Navigator.of(context).pop(true);
                          tableKey.currentState?.refreshPage();
                          await showSnackBar2(context, lang.delete);
                        } catch (error, stacktrace) {
                          showServerError(context, error: error);
                          print(stacktrace);
                        }
                      }),
                ],
              ),
            );
          },
          child: Text(
            lang.delete,
          ),
        ),
      )
    ];
    return DataRow(cells: cellList);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
