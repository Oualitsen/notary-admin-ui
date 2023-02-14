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
  final GlobalKey<FormState> _formKeyListNames = GlobalKey<FormState>();
  List<TextEditingController> _controller = [];
  late List listFormField;
  late WebViewXController controllerWeb;
  late String text;
  final _htmlDocument = BehaviorSubject.seeded('');

  var loadingPercentage = 0;

  @override
  void initState() {
    text = widget.text;

    listFormField = widget.listFormField;
    _controller =
        List.generate(listFormField.length, (i) => TextEditingController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myTabs = [
      Tab(
        text: "Form  Convert",
        height: 50,
      ),
      Tab(
        text: "View Html",
        height: 50,
      )
    ];
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Form to html"),
          actions: [],
          bottom: TabBar(tabs: myTabs),
        ),
        body: TabBarView(children: [
          Container(
              padding: EdgeInsets.all(30),
              width: double.maxFinite,
              height: 400,
              child: Form(
                  key: _formKeyListNames,
                  onChanged: convertToMap,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        height: 350,
                        child: ListView.builder(
                          itemCount: listFormField.length,
                          itemBuilder: (BuildContext context, int index) {
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
                                    if (value == null || value.isEmpty) {
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
                  ))),
          StreamBuilder<String>(
              stream: _htmlDocument,
              initialData: text,
              builder: (context, snapshot) {
                return WebViewX(
                  initialContent: text,
                  initialSourceType: SourceType.html,
                  onWebViewCreated: (controller) => controllerWeb = controller,
                  height: 500,
                  width: double.maxFinite,
                );
              }),
        ]),
      ),
    );
  }

  convertToMap() {
    if (_formKeyListNames.currentState!.validate() || true) {
      Map map = Map<String, String>();
      for (int index = 0; index < listFormField.length; index++)
        map[listFormField[index]] = _controller[index].text;
      var doc = parse(text);
      map.forEach((key, value) {
        doc.querySelector('.$key')?.text = value;
      });
      text = doc.outerHtml;
      _htmlDocument.add(text);

      // showSnackBar2(context, lang.ok);
    }
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => throw UnimplementedError();

  @override
  // TODO: implement subjects
  List<Subject> get subjects => throw UnimplementedError();
}
