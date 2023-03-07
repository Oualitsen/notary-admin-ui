import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/pages/file-spec/add_file_spec.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:rxdart/src/subjects/subject.dart';

import '../../utils/widget_utils.dart';
import '../../widgets/mixins/button_utils_mixin.dart';
import 'file_spec_table.dart';

class FileSpecList extends StatefulWidget {
  const FileSpecList({super.key});

  @override
  State<FileSpecList> createState() => _FileSpecListState();
}

class _FileSpecListState extends BasicState<FileSpecList>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<FileSpecService>();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.fileSpec),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFileSpec()),
              );
            },
            child: Icon(Icons.add),
          ),
          body: Padding(padding: EdgeInsets.all(20), child: FileSpecTable()),
        ));
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}
