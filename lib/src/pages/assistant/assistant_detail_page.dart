import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/assistant/add_assistant_page.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AssistantDetailsPage extends StatefulWidget {
  final Assistant assistant;
  AssistantDetailsPage({Key? key, required this.assistant}) : super(key: key);

  @override
  State<AssistantDetailsPage> createState() => _AssistantDetailsPageState();
}

class _AssistantDetailsPageState extends BasicState<AssistantDetailsPage>
    with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    var assistant = widget.assistant;

    var myTabs = [
      Tab(
        text: "Informations",
        height: 50,
      ),
    ];
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${assistant.firstName} ${assistant.lastName}"),
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
                push<Assistant>(
                        context, AddAssistantPage(/*assistant: assistant*/))
                    .listen((c) => setState(() => assistant = c));
              },
            ),
          ],
          bottom: TabBar(tabs: myTabs),
        ),
        body: TabBarView(
          children: [
            Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(right: 30),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(lang.lastName),
                      subtitle: Text(assistant.lastName),
                    ),
                    ListTile(
                      title: Text(lang.firstName),
                      subtitle: Text(assistant.firstName),
                    ),
                    ListTile(
                      title: Text(lang.gender),
                      subtitle: Text(assistant.gender.name),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
