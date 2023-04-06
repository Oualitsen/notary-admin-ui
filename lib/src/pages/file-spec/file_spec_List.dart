import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/file-spec/add_file_spec.dart';
import 'package:notary_admin/src/pages/file-spec/file_spec_table.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/src/subjects/subject.dart';

class FileSpecList extends StatefulWidget {
  const FileSpecList({super.key});

  @override
  State<FileSpecList> createState() => _FileSpecListState();
}

class _FileSpecListState extends BasicState<FileSpecList>
    with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(
            title: Text(lang.fileSpec),
          ),
          floatingActionButton: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFileSpec()),
              );
            },
            child: Text(lang.addFileSpec),
          ),
          body: Padding(padding: EdgeInsets.all(20), child: FileSpecTable()),
        ));
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
