import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';

import 'package:rxdart/src/subjects/subject.dart';

class QuillHtmlEditorPage extends StatefulWidget {
  final String text;
  const QuillHtmlEditorPage({super.key, required this.text});

  @override
  State<QuillHtmlEditorPage> createState() => _QuillHtmlEditorPageState();
}

class _QuillHtmlEditorPageState extends BasicState<QuillHtmlEditorPage>
    with WidgetUtilsMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HTML Editor"),
        actions: [
          ElevatedButton(
            onPressed: () async {},
            child: Text("Save"),
          ),
        ],
      ),
      body: Container(),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
