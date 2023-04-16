import 'package:flutter/material.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/files/add_files_page.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';

import 'files_table_widget.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends BasicState<FilesPage> with WidgetUtilsMixin {
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
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
