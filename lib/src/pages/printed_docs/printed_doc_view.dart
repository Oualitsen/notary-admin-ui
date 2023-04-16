import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webviewx/webviewx.dart';

class PrintedDocViewHtml extends StatefulWidget {
  final String text;
  final String? title;
  const PrintedDocViewHtml({super.key, required this.text, this.title});

  @override
  State<PrintedDocViewHtml> createState() => _PrintedDocViewHtmlState();
}

class _PrintedDocViewHtmlState extends BasicState<PrintedDocViewHtml>
    with WidgetUtilsMixin {
  WebViewXController? controllerWeb;
  final printedDocService = GetIt.instance.get<PrintedDocService>();
  late String text;
  final templateNameCrtl = TextEditingController();
  final _htmlDocument = BehaviorSubject.seeded('');

  @override
  void initState() {
    text = widget.text;

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
          title: widget.title != null
              ? Text(widget.title!.toUpperCase())
              : Text(lang.print),
          actions: [
            Tooltip(
              message: lang.print,
              child: ElevatedButton.icon(
                label: Text(lang.print.toUpperCase()),
                onPressed: () {
                  controllerWeb?.callJsMethod("display", []);
                },
                icon: Icon(Icons.print),
              ),
            ),
          ],
        ),
        body: WebViewX(
          ignoreAllGestures: false,
          initialContent: text,
          initialSourceType: SourceType.html,
          onWebViewCreated: (controller) => controllerWeb = controller,
          height: double.maxFinite,
          width: double.maxFinite,
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
