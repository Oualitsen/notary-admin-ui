import 'package:html/parser.dart';
import 'package:flutter/material.dart';
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

  final GlobalKey<FormState> _formKeyListNames = GlobalKey<FormState>();
  List<TextEditingController> _controller = [];
  late List listFormField;
  late String text;
  final _htmlDocument = BehaviorSubject.seeded('');

  @override
  void initState() {
    text = widget.text;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Form to html"),
        actions: [],
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          width: double.maxFinite,
          height: double.maxFinite,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        width: double.maxFinite,
                        decoration: BoxDecoration(color: Colors.blue),
                        child: Center(child: Text("Data for Document")),
                      ),
                      Form(
                          key: _formKeyListNames,
                          onChanged: onDataChange,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: double.maxFinite,
                                height: 450,
                                child: ListView.builder(
                                  itemCount: listFormField.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: listFormField[index],
                                          ),
                                          controller: _controller[index],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return lang.requiredField;
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: VerticalDivider(
                  color: Colors.black,
                  thickness: 1,
                  width: 50,
                  indent: 5,
                  endIndent: 5,
                ),
              ),
              Flexible(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        width: double.maxFinite,
                        decoration: BoxDecoration(color: Colors.blue),
                        child: Center(child: Text("Name For Document")),
                      ),
                      WebViewX(
                        initialContent: text,
                        initialSourceType: SourceType.html,
                        onWebViewCreated: (controller) =>
                            controllerWeb = controller,
                        height: 450,
                        width: double.maxFinite,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
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
}
