import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:webviewx/webviewx.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class MyDocxFileReader extends StatefulWidget {
  final String title;
  final String id;
  final bool isDocx;
  final Uint8List? bytes;
  const MyDocxFileReader({
    super.key,
    required this.id,
    required this.title,
    this.isDocx = false,
    this.bytes,
  });

  @override
  _MyDocxFileReaderState createState() => _MyDocxFileReaderState();
}

class _MyDocxFileReaderState extends BasicState<MyDocxFileReader> {
  WebViewXController? controllerWeb;
  final service = GetIt.instance.get<PdfService>();
  final tokenService = GetIt.instance.get<TokenDbService>();

  final _htmlDocument = BehaviorSubject.seeded("");

  @override
  void initState() {
    super.initState();
    wordToHtml(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.title}"),
          actions: [
            ElevatedButton.icon(
              onPressed: download,
              label: Text(lang.download),
              icon: Icon(Icons.download),
            ),
          ],
        ),
        body: StreamBuilder<String>(
          stream: _htmlDocument,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox.shrink();
            }
            if (snapshot.data!.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: WebViewX(
                ignoreAllGestures: false,
                initialContent: snapshot.data!,
                initialSourceType: SourceType.html,
                onWebViewCreated: (controller) => controllerWeb = controller,
                height: double.maxFinite,
                width: double.maxFinite,
              ),
            );
          },
        ));
  }

  Future wordToHtml(String id) async {
    try {
      var res = "";
      if (widget.isDocx) {
        res = await service.wordToHtml(id);
      } else if (widget.bytes != null) {
        res = utf8.decode(widget.bytes!);
      } else {
        res = lang.noDataFound;
      }
      _htmlDocument.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future download() async {
    try {
      String? authToken = await tokenService.getToken();
      String uri = "${getUrlBase()}/admin/grid/download/${widget.id}";
      WidgetMixin.download(context, uri, widget.title, widget.bytes, authToken);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }
}
