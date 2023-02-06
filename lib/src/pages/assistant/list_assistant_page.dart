import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/assistant/add_assistant_page.dart';
import 'package:notary_admin/src/pages/assistant/assistant_detail_page.dart';
import 'package:notary_admin/src/services/assistant/assistant_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ListAssistantPage extends StatefulWidget {
  const ListAssistantPage({super.key});

  @override
  State<ListAssistantPage> createState() => _ListAssistantPageState();
}

class _ListAssistantPageState extends BasicState<ListAssistantPage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<AssistantService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.assistantList),
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
            MaterialPageRoute(builder: (context) => AddAssistantPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: InfiniteScrollListView<Assistant>(
        elementBuilder: (BuildContext context, assistant, index, animation) {
          return ListTile(
              title: Text(assistant.lastName),
              subtitle: Text(assistant.firstName),
              onTap: () {
                // Get.toNamed(RouteHelper.getPopularHotels(index));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AssistantDetailsPage(
                            assistant: assistant,
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

  Future<List<Assistant>> getData(int index) {
    if (index == 0)
      return service.getAssistants(pageIndex: index, pageSize: 20);
    else
      return Future.value([]);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
