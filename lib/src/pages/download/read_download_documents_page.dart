import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/pages/download/image_widget.dart';
import 'package:notary_admin/src/pages/download/pdf_images.dart';
import 'package:notary_admin/src/pages/printed_docs/printed_doc_view.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:webviewx/webviewx.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

class ReadAndDownloadDocumentsPage extends StatefulWidget {
  final String id;
  final String name;

  const ReadAndDownloadDocumentsPage({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<ReadAndDownloadDocumentsPage> createState() =>
      _ReadAndDownloadDocumentsPageState();
}

class _ReadAndDownloadDocumentsPageState
    extends BasicState<ReadAndDownloadDocumentsPage> with WidgetUtilsMixin {
  final tokenService = GetIt.instance.get<TokenDbService>();
  final pdfService = GetIt.instance.get<PdfService>();

  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  final _htmlDocument = BehaviorSubject.seeded("");
  final extensionStream = BehaviorSubject<Extension>();
  final imageIdsStream = BehaviorSubject.seeded(<String>[]);
  WebViewXController? controllerWeb;

  late String uri;
  late String? token;
  late Uint8List? bytes;
  var initialized = false;

  init() async {
    if (initialized) return;
    initialized = true;
    uri = "${getUrlBase()}/admin/grid/download/${widget.id}";
    getExtension();
    token = await tokenService.getToken();
    bytes = await ReusedWidgets.getBytes(token, uri);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text("${widget.name}"),
          actions: [
            ElevatedButton.icon(
              onPressed: (() async {
                if (extensionStream.valueOrNull == Extension.PDF) {
                  final uri =
                      "${getUrlBase()}/admin/pdf/create/${widget.name}?date=${DateTime.now().millisecondsSinceEpoch}";
                  final response = await http.post(
                    Uri.parse(uri),
                    headers: {
                      "Authorization": "Bearer $token",
                      HttpHeaders.contentTypeHeader: 'application/json',
                    },
                    body: json.encode(imageIdsStream.value),
                  );
                  Uint8List byteList = response.bodyBytes;
                  ReusedWidgets.download(
                    context,
                    uri: "",
                    name: widget.name,
                    myBytes: byteList,
                    token: token,
                  );
                } else {
                  ReusedWidgets.download(
                    context,
                    uri: uri,
                    name: widget.name,
                    myBytes: bytes,
                    token: token,
                  );
                }
              }),
              label: Text(lang.download),
              icon: Icon(Icons.download),
            ),
            ElevatedButton(
              onPressed: (() async => await printDoc(context)),
              child: Text(lang.print.toUpperCase()),
            ),
          ],
        ),
        body: StreamBuilder<Extension>(
            stream: extensionStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              return extensionWidget(snapshot.data!);
            }),
      ),
    );
  }

  Widget extensionWidget(Extension extension) {
    switch (extension) {
      case Extension.IMAGE:
        return StreamBuilder<List<String>>(
            stream: imageIdsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }

              return SingleChildScrollView(
                child: ImageWidget(
                  imageId: widget.id,
                  token: token!,
                  onAngleChanged: (imageId) {
                    imageIdsStream.add(imageIdsStream.value);
                  },
                ),
              );
            });
      case Extension.PDF:
        return PdfImages(
          name: widget.name,
          id: widget.id,
          onImageIdsChange: (imageIds) {
            imageIdsStream.add(imageIds);
          },
        );
      case Extension.DOCX:
        return htmlOrDocx(true);

      case Extension.HTML:
        return htmlOrDocx(false);

      case Extension.TXT:
        if (bytes == null) {
          return SizedBox.shrink();
        }
        final decodedContent = utf8.decode(bytes!);
        final lines = LineSplitter().convert(decodedContent);
        var data = lines.join('\n');
        var myHtmlText = """
        <html>
            <script>
              function display() {
                  window.print();
              }
          </script>
          <body>
            <pre>${data}</pre>
          </body>
        </html>""";
        return WebViewX(
          ignoreAllGestures: false,
          initialContent: myHtmlText,
          initialSourceType: SourceType.html,
          onWebViewCreated: (controller) => controllerWeb = controller,
          height: double.maxFinite,
          width: double.maxFinite,
        );

      default:
        ReusedWidgets.download(
          context,
          uri: "",
          name: widget.name,
          myBytes: bytes,
          token: token,
        );
        break;
    }
    return SizedBox.shrink();
  }

  Widget htmlOrDocx(bool isDocx) {
    wordToHtml(widget.id, isDocx);
    return StreamBuilder<String>(
      stream: _htmlDocument,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        if (snapshot.data!.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        var htmlData = """<script>
              function display() {
                  window.print();
              }
          </script>""" +
            snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: WebViewX(
            ignoreAllGestures: false,
            initialContent: htmlData,
            initialSourceType: SourceType.html,
            onWebViewCreated: (controller) => controllerWeb = controller,
            height: double.maxFinite,
            width: double.maxFinite,
          ),
        );
      },
    );
  }

  Future wordToHtml(String id, bool isDocx) async {
    try {
      var res = "";
      if (isDocx) {
        res = await pdfService.wordToHtml(id);
      } else if (bytes != null) {
        res = utf8.decode(bytes!);
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

  getExtension() {
    var extension = widget.name.split(".").last;
    if (imageExtensions.contains(extension)) {
      extensionStream.add(Extension.IMAGE);
    }
    switch (extension) {
      case "pdf":
        extensionStream.add(Extension.PDF);
        break;
      case "docx":
        extensionStream.add(Extension.DOCX);
        break;
      case "html":
        extensionStream.add(Extension.HTML);
        break;
      case "txt":
        extensionStream.add(Extension.TXT);
        break;
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  printDoc(BuildContext context) async {
    var extension = extensionStream.value;
    if (extension == Extension.TXT ||
        extension == Extension.DOCX ||
        extension == Extension.HTML) controllerWeb?.callJsMethod("display", []);
    if (extension == Extension.IMAGE) {
      var uri =
          "${getUrlBase()}/admin/pdf/image/${widget.id}date=${DateTime.now().millisecondsSinceEpoch.toString()}";
      var htmlData = """<script>
              function display() {
                  window.print();
              }
          </script> <body>
          <img src=${uri} alt="My Image"></body> """;
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: WebViewX(
          ignoreAllGestures: false,
          initialContent: htmlData,
          initialSourceType: SourceType.html,
          onWebViewCreated: (controller) => controllerWeb = controller,
          height: double.maxFinite,
          width: double.maxFinite,
        ),
      );
    }
  }
}

enum Extension {
  PDF,
  DOCX,
  HTML,
  IMAGE,
  TXT,
}
