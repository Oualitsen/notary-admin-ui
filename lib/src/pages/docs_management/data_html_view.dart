import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webviewx/webviewx.dart';

class DataHtmlView extends StatefulWidget {
  final String text;
  final String? title;
  const DataHtmlView({super.key, required this.text, this.title});

  @override
  State<DataHtmlView> createState() => _DataHtmlViewState();
}

class _DataHtmlViewState extends BasicState<DataHtmlView>
    with WidgetUtilsMixin {
  WebViewXController? controllerWeb;

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
              child: TextButton.icon(
                label: Text(
                  lang.print.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                onPressed: () {
                  controllerWeb?.callJsMethod("display", []);
                },
                icon: Icon(
                  Icons.print,
                  color: Theme.of(context).canvasColor,
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: WebViewX(
            ignoreAllGestures: false,
            initialContent: widget.text,
            initialSourceType: SourceType.html,
            onWebViewCreated: (controller) {
              return controllerWeb = controller;
            },
            height: double.maxFinite,
            width: double.maxFinite,
          ),
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
