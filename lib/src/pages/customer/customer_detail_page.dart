import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:rxdart/src/subjects/subject.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;
  CustomerDetailsPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends BasicState<CustomerDetailsPage>
    with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    var customer = widget.customer;

    var myTabs = [
      Tab(
        text: "Informations",
        height: 50,
      ),
      Tab(
        text: "Adresse",
        height: 50,
      ),
      Tab(
        text: "Idcards",
        height: 50,
      ),
    ];
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${customer.firstName} ${customer.lastName}"),
          actions: [
            TextButton.icon(
              label: Text(
                lang.edit.toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                push<Customer>(context, AddCustomerPage(customer: customer))
                    .listen((c) => setState(() => customer = c));
              },
            ),
          ],
          bottom: TabBar(tabs: myTabs),
        ),
        body: TabBarView(children: [
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(right: 30),
            child: Column(
              children: [
                ListTile(
                  title: Text(lang.lastName),
                  subtitle: Text(customer.lastName),
                ),
                ListTile(
                  title: Text(lang.firstName),
                  subtitle: Text(customer.firstName),
                ),
                ListTile(
                  title: Text(lang.gender),
                  subtitle: Text(customer.gender.name),
                ),
                ListTile(
                  title: Text(lang.dateOfBirth),
                  subtitle: Text(lang.formatDate(customer.dateOfBirth)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(right: 30),
            child: Column(
              children: [
                ListTile(
                  title: Text(lang.street),
                  subtitle: Text(customer.address.street.toString()),
                ),
                ListTile(
                  title: Text(lang.city),
                  subtitle: Text(customer.address.city.toString()),
                ),
                ListTile(
                  title: Text(lang.state),
                  subtitle: Text(customer.address.state.toString()),
                ),
                ListTile(
                  title: Text(lang.postalCode),
                  subtitle: Text(customer.address.postalCode.toString()),
                ),
                ListTile(
                  title: Text(lang.country),
                  subtitle: Text(customer.address.country.toString()),
                ),
              ],
            ),
          ),
          ListView(children: [
            ListTile(
              title: Text("Id :"),
              subtitle: Text(customer.idCard.idCardId),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(lang.expiryDate),
              subtitle: Text(lang.formatDate(customer.idCard.expiryDate)),
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.all(15),
              width: 100,
              height: 100,
              child: Image.network(
                customer.idCard.frontImageUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    Container(child: Text("Error")),
              ),
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.all(15),
              width: 100,
              height: 100,
              child: Image.network(
                customer.idCard.backImageUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    Container(child: Text("Error")),
              ),
            ),
          ])
        ]),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
