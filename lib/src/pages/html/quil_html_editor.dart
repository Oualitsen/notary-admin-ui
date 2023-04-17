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
  // late QuillEditorController controller;
  // @override
  // void initState() {
  //   controller = QuillEditorController();
  //   controller.onTextChanged((text) {
  //     // debugPrint('listening to $text');
  //   });
  //   super.initState();
  // }

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
      // body: QuillHtmlEditor(
      //   text: widget.text,
      //   hintText: 'Hint text goes here',
      //   controller: controller,
      //   isEnabled: true,
      //   minHeight: 300,
      //   //textStyle: _editorTextStyle,
      //   //hintTextStyle: _hintTextStyle,
      //   hintTextAlign: TextAlign.start,
      //   padding: const EdgeInsets.only(left: 0, top: 0),
      //   hintTextPadding: const EdgeInsets.only(left: 20),
      //   //backgroundColor: _backgroundColor,
      //   onFocusChanged: (hasFocus) => debugPrint('has focus $hasFocus'),
      //   onTextChanged: (text) => debugPrint('widget text change $text'),
      //   onEditorCreated: () => debugPrint('Editor has been loaded'),
      //   onEditorResized: (height) => debugPrint('Editor resized $height'),
      //   onSelectionChanged: (sel) =>
      //       debugPrint('index ${sel.index}, range ${sel.length}'),
      // ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
