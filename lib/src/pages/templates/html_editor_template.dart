import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rxdart/src/subjects/subject.dart';

class HtmlEditorTemplate extends StatefulWidget {
  HtmlEditorTemplate({Key? key, required this.template}) : super(key: key);

  final TemplateDocument template;
  @override
  _HtmlEditorTemplateState createState() => _HtmlEditorTemplateState();
}

class _HtmlEditorTemplateState extends BasicState<HtmlEditorTemplate>
    with WidgetUtilsMixin {
  String result = '';
  final service = GetIt.instance.get<TemplateDocumentService>();
  final HtmlEditorController controller = HtmlEditorController();
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
      var res = await service.updateHtmlData(widget.template.id, newHtmlData);
      await showSnackBar2(context, lang.updatedSuccessfully);
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
