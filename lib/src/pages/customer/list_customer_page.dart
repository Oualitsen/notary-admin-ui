import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/pages/customer/customer_detail_page.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ListCustomerPage extends StatefulWidget {
  const ListCustomerPage({super.key});

  @override
  State<ListCustomerPage> createState() => _ListCustomerPageState();
}

class _ListCustomerPageState extends BasicState<ListCustomerPage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<CustomerService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.customerList),
        // titleSpacing: 00.0,
        // centerTitle: true,
        // toolbarHeight: 60.2,
        // toolbarOpacity: 0.8,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //       bottomRight: Radius.circular(25),
        //       bottomLeft: Radius.circular(25)),
        // ),
        // elevation: 0.00,
        // backgroundColor: Colors.greenAccent[400],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: InfiniteScrollListView<Customer>(
        elementBuilder: (BuildContext context, customer, index, animation) {
          return ListTile(
              title: Text(customer.lastName),
              subtitle: Text(customer.firstName),
              onTap: () {
                // Get.toNamed(RouteHelper.getPopularHotels(index));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomerDetailsPage(
                            customer: customer,
                          )),
                );
              });
        },
        pageLoader: getData,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.apps), label: ""),
      //     BottomNavigationBarItem(icon: Icon(Icons.bar_chart_sharp), label: ""),
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
      //   ],
      // ),
    );
  }

  Future<List<Customer>> getData(int index) {
    if (index == 0)
      return service.getCustomers(pageIndex: index, pageSize: 20);
    else
      return Future.value([]);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
