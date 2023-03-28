import 'package:flutter/material.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/files/add_files_page.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/src/subjects/subject.dart';

import '../../utils/widget_utils.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import 'files_table_widget.dart';

class ListFilesCustomer extends StatefulWidget {
  const ListFilesCustomer({super.key});

  @override
  State<ListFilesCustomer> createState() => _ListFilesCustomerState();
}

class _ListFilesCustomerState extends BasicState<ListFilesCustomer>
    with WidgetUtilsMixin {
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.listFilesCustomer),
          ),
          floatingActionButton: ElevatedButton(
              onPressed: () => Navigator.push<Files?>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddFilesCustomer()))
                      .then((value) {
                    if (value != null) {
                      tableKey.currentState?.add(value);
                    }
                  }),
              child: Text(lang.addFiles)),
          body:
              Padding(padding: EdgeInsets.all(20.0), child: FilesTableWidget()),
        ));
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
