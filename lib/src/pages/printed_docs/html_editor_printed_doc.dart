import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/printed_doc_input.dart';
import 'package:rxdart/src/subjects/subject.dart';

class HtmlEditorPrintedDoc extends StatefulWidget {
  HtmlEditorPrintedDoc({Key? key, required this.template}) : super(key: key);

  final PrintedDoc template;
  @override
  _HtmlEditorPrintedDocState createState() => _HtmlEditorPrintedDocState();
}

class _HtmlEditorPrintedDocState extends BasicState<HtmlEditorPrintedDoc>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<PrintedDocService>();
  final controller = HtmlEditorController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.template.name),
        ),
        body: HtmlEditor(
          controller: controller,
          htmlEditorOptions: HtmlEditorOptions(
            initialText: widget.template.htmlData,
            spellCheck: true,
            autoAdjustHeight: false,
          ),
          htmlToolbarOptions: HtmlToolbarOptions(customToolbarButtons: [
            ElevatedButton.icon(
              onPressed: onSave,
              label: Text(lang.save.toUpperCase()),
              icon: Icon(Icons.save),
            ),
          ]),
          otherOptions: OtherOptions(
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  void onSave() async {
    progressSubject.add(true);
    try {
      var newHtmlData = await controller.getText();
      if (newHtmlData.contains('src=\"data:')) {
        newHtmlData =
            '<text removed due to base-64 data, displaying the text could cause the app to crash>';
      }
      var input = PrintedDocInput(
        id: widget.template.id,
        htmlData: newHtmlData,
        name: widget.template.name,
      );
      var res = await service.create(input);
      await showSnackBar2(context, lang.updatedSuccessfully);
      Navigator.of(context).pop(res);
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
    } finally {
      progressSubject.add(false);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
