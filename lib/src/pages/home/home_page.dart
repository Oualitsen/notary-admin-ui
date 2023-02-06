import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:notary_admin/src/pages/assistant/add_assistant_page.dart';
import 'package:notary_admin/src/pages/assistant/list_assistant_page.dart';
import 'package:notary_admin/src/pages/customer/customer_list.dart';
import 'package:notary_admin/src/pages/customer/list_customer_page.dart';
import 'package:notary_admin/src/pages/file/html_editor.dart';
import 'package:notary_admin/src/pages/file/load_file.dart';
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
  static const persistenceKey = "filter";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.notaryService),
      ),
      drawer: createDrawer(context),
      body: Container(
        alignment: Alignment.center,
        child: Column(children: [
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoadFilePage(),
                ),
              );
            },
            child: Text("list files"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ListCustomerPage(),
                ),
              );
            },
            child: Text("Show Customers"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ListAssistantPage(),
                ),
              );
            },
            child: Text(lang.assistantList),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CustomerTable(),
                ),
              );
            },
            child: Text(lang.customerList),
          ),
        ]),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
