import 'package:get_it/get_it.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_model/model/printed_doc_input.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webviewx/webviewx.dart';
import '../../widgets/basic_state.dart';
import '../../widgets/mixins/button_utils_mixin.dart';

class FormAndViewHtml extends StatefulWidget {
  static const home = "/";
  final List listFormField;
  final String text;
  const FormAndViewHtml(
      {super.key, required this.listFormField, required this.text});

  @override
  State<FormAndViewHtml> createState() => _FormAndViewHtmlState();
}

class _FormAndViewHtmlState extends BasicState<FormAndViewHtml>
    with WidgetUtilsMixin {
  WebViewXController? controllerWeb;
  final printedDocService = GetIt.instance.get<PrintedDocService>();
  final GlobalKey<FormState> _formKeyListNames = GlobalKey<FormState>();
  List<TextEditingController> _controller = [];
  late List listFormField;
  late String text;
  final _htmlDocument = BehaviorSubject.seeded('');
  var toPrint = """
   <script>
      function display() {
         window.print();
      }
   </script>
""";

  @override
  void initState() {
    text = toPrint + widget.text;
    listFormField = widget.listFormField;
    _controller =
        List.generate(listFormField.length, (i) => TextEditingController());
    _htmlDocument.where((event) => controllerWeb != null).listen((value) {
      controllerWeb!.loadContent(value, SourceType.html);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.formToHtml),
          actions: [
            Tooltip(
              message: lang.print,
              child: IconButton(
                onPressed: () {
                  controllerWeb?.callJsMethod("display", []);
                },
                icon: Icon(Icons.print),
              ),
            ),
            Tooltip(
              message: lang.save,
              child: IconButton(
                onPressed: saveCopy,
                icon: Icon(Icons.save),
              ),
            )
          ],
        ),
        body: Row(
          children: [
            Container(
              width: 300,
              height: double.maxFinite,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Theme.of(context).canvasColor,
                    leading: SizedBox.shrink(),
                    title: Tooltip(
                        child: Text(
                          lang.dataForDocument,
                          style: TextStyle(color: Colors.black),
                        ),
                        message: lang.dataForDocument),
                    elevation: 0,
                  ),
                  Form(
                    key: _formKeyListNames,
                    onChanged: onDataChange,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: listFormField.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextFormField(
                              decoration:
                                  getDecoration(listFormField[index], false),
                              controller: _controller[index],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.requiredField;
                                }
                                return null;
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: saveCopy,
                    child: Text(lang.save),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              thickness: 1,
              width: 5,
              indent: 1,
              endIndent: 1,
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: AppBar(
                      backgroundColor: Theme.of(context).canvasColor,
                      leading: SizedBox.shrink(),
                      title: Text(
                        lang.nameForDocument,
                        style: TextStyle(color: Colors.black),
                      ),
                      elevation: 0,
                    ),
                  ),
                  Expanded(
                    child: WebViewX(
                      initialContent: text,
                      initialSourceType: SourceType.html,
                      onWebViewCreated: (controller) =>
                          controllerWeb = controller,
                      height: double.maxFinite,
                      width: double.maxFinite,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onDataChange() {
    Map map = Map<String, String>();
    for (int index = 0; index < listFormField.length; index++)
      map[listFormField[index]] = _controller[index].text;
    var doc = parse(text);
    map.forEach((key, value) {
      doc.querySelectorAll('.$key').map((e) => e.text = value).toList();
    });
    text = doc.outerHtml;
    _htmlDocument.add(text);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void saveCopy() async {
    if (_formKeyListNames.currentState?.validate() ?? false) {
      try {
        var input = PrintedDocInput(
            id: null,
            filesId: "filesId",
            htmlData: _htmlDocument.value,
            name: "name");
        await printedDocService.create(input);
        await showSnackBar2(context, lang.savedSuccessfully);
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError(context, error: error);
      }
    }
  }
}
