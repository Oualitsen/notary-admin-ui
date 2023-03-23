import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notary_admin/src/pages/customer/add_customer_page.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
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
  late Customer customer;
  late List<Tab> myTabs;
  bool initialized = false;
  void init() {
    if (initialized) return;
    initialized = true;
    customer = widget.customer;
    myTabs = [
      Tab(
        text: lang.general,
        height: 50,
      ),
      Tab(
        text: lang.idCardInfo,
        height: 50,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) => DefaultTabController(
        length: myTabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${customer.firstName} ${customer.lastName}"),
            bottom: TabBar(tabs: myTabs),
          ),
          body: TabBarView(children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(right: 30),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                        child: Text(
                            "${customer.lastName[0].toUpperCase()}${customer.firstName[0].toUpperCase()}")),
                    title: Text("${customer.lastName} ${customer.firstName}"),
                    subtitle: Text(lang.name),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        child: Icon(Icons.calendar_month_outlined)),
                    title: Text("${lang.formatDate(customer.dateOfBirth)}"),
                    subtitle: Text(lang.dateOfBirth),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.people)),
                    title: Text(" ${lang.genderName(customer.gender)}"),
                    subtitle: Text(lang.gender),
                  ),
                  ListTile(
                    leading:
                        CircleAvatar(child: Icon(Icons.gps_fixed_outlined)),
                    title: Text(" ${lang.formatAddress(customer.address)}"),
                    subtitle: Text(lang.address),
                  ),
                ],
              ),
            ),
            ListView(children: [
              ListTile(
                leading: CircleAvatar(
                    child: Icon(
                  FontAwesomeIcons.idCard,
                  size: 20,
                )),
                subtitle: Text(lang.id),
                title: Text(customer.idCard.idCardId),
              ),
              SizedBox(height: 16),
              ListTile(
                leading:
                    CircleAvatar(child: Icon(Icons.calendar_month_outlined)),
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
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
