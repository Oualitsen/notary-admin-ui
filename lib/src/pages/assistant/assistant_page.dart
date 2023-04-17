import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/search/search_widget.dart';
import 'package:notary_admin/src/widgets/widget_roles.dart';
import 'package:notary_admin/src/pages/assistant/add_assistant_page.dart';
import 'package:notary_admin/src/pages/assistant/assistant_table_widget.dart';
import 'package:notary_admin/src/services/assistant/admin_assistant_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/role.dart';
import 'package:rapidoc_utils/alerts/alert_vertical_widget.dart';
import 'package:rxdart/rxdart.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends BasicState<AssistantPage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<AdminAssistantService>();
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();
  final searchValueStream = BehaviorSubject.seeded("");

  @override
  void initState() {
    searchValueStream
        .where((event) => tableKey.currentState != null)
        .debounceTime(Duration(milliseconds: 500))
        .listen((value) {
      tableKey.currentState?.refreshPage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => RoleGuardWidget(
        role: Role.ADMIN,
        noRoleWidget: Center(
            child: AlertVerticalWidget.createDanger(
                lang.noAccessRightError.toUpperCase())),
        child: Scaffold(
            appBar: AppBar(
              title: Text(lang.assistantList),
              actions: [
                SearchWidget(
                  type: type,
                  onChange: ((searchValue) {
                    searchValueStream.add(searchValue);
                  }),
                ),
              ],
            ),
            floatingActionButton: ElevatedButton(
              onPressed: () {
                Navigator.push<Admin?>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAssistantPage())).then(
                  (value) {
                    if (value != null) {
                      tableKey.currentState?.add(value);
                    }
                  },
                );
              },
              child: Text(lang.addAssistant.toUpperCase()),
            ),
            body: StreamBuilder<String>(
                stream: searchValueStream,
                builder: (context, snapshot) {
                  return AssistantTableWidget(
                    tableKey: tableKey,
                    searchValue: snapshot.data,
                  );
                })),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
