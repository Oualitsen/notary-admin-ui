import 'package:flutter/material.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/file-spec/add_file_spec.dart';
import 'package:notary_admin/src/pages/file-spec/file_spec_table.dart';
import 'package:notary_admin/src/pages/search/search_widget.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class FileSpecPage extends StatefulWidget {
  const FileSpecPage({super.key});

  @override
  State<FileSpecPage> createState() => _FileSpecPageState();
}

class _FileSpecPageState extends BasicState<FileSpecPage>
    with WidgetUtilsMixin {
  final searchValueStream = BehaviorSubject.seeded("");
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();

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
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.fileSpec),
            actions: [
              SearchWidget(
                type: type,
                onChange: ((searchValue) {
                  searchValueStream.add(searchValue);
                }),
              )
            ],
          ),
          floatingActionButton: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFileSpec()),
              ).then((value) {
                tableKey.currentState?.refreshPage();
              });
            },
            child: Text(lang.addFileSpec),
          ),
          body: StreamBuilder<String>(
              stream: searchValueStream,
              builder: (context, snapshot) {
                return Padding(
                    padding: EdgeInsets.all(20),
                    child: FileSpecTable(
                      tableKey: tableKey,
                      searchValue: snapshot.data,
                    ));
              }),
        ));
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
