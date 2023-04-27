import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/pages/docs_management/image_widget.dart';
import 'package:notary_admin/src/pages/docs_management/pdf_images.dart';
import 'package:notary_admin/src/services/files/data_manager_service.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:webviewx/webviewx.dart';
import 'package:rxdart/rxdart.dart';

class DocumentManagerPage extends StatefulWidget {
  final String id;
  final String name;

  const DocumentManagerPage({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<DocumentManagerPage> createState() => _DocumentManagerPageState();
}

class _DocumentManagerPageState extends BasicState<DocumentManagerPage>
    with WidgetUtilsMixin {
  final tokenService = GetIt.instance.get<TokenDbService>();
  final pdfService = GetIt.instance.get<DataManagerService>();

  final _htmlDocument = BehaviorSubject.seeded("");
  final extensionStream = BehaviorSubject<Extension>();
  final imageIdsStream = BehaviorSubject.seeded(<String>[]);
  final base64DataStream = BehaviorSubject.seeded("");
  WebViewXController? controllerWeb;
  WebViewXController? controllerWeb2;

  late String? token;
  var initialized = false;

  init() async {
    if (initialized) return;
    token = await tokenService.getToken();
    await getBase64();
    base64DataStream.listen((value) {
      getExtension();
    });
    extensionStream.listen((value) {
      getHtmlData();
    });
    initialized = true;
    _htmlDocument
        .where((event) => controllerWeb2 != null && event.isNotEmpty)
        .listen((event) {
      controllerWeb2!.loadContent(event, SourceType.html);
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text("${widget.name}"),
          actions: [
            TextButton.icon(
              onPressed: download,
              label: Text(
                lang.download,
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                ),
              ),
              icon: Icon(
                Icons.download,
                color: Theme.of(context).canvasColor,
              ),
            ),
            SizedBox(width: 5),
            TextButton(
              onPressed: printDoc,
              child: Text(
                lang.print.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                ),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 0,
              child: WebViewX(
                ignoreAllGestures: false,
                onWebViewCreated: (controller) {
                  controllerWeb2 = controller;
                },
                height: 0,
                width: 0,
              ),
            ),
            Expanded(
              child: StreamBuilder<String>(
                  stream: base64DataStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    return extensionWidget();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget extensionWidget() {
    switch (extensionStream.valueOrNull) {
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
                    getHtmlData();
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
            getHtmlData();
          },
        );
      case Extension.DOCX:
      case Extension.HTML:
      case Extension.TXT:
        return htmlOrDocxOrTxt();

      default:
        return SizedBox.shrink();
    }
  }

  Widget htmlOrDocxOrTxt() {
    return StreamBuilder<String>(
      stream: _htmlDocument,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        if (snapshot.data!.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        var htmlData = snapshot.data!;
        controllerWeb?.loadContent(htmlData, SourceType.html);
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

  Future getHtmlData() async {
    try {
      var res = "";
      switch (extensionStream.value) {
        case Extension.TXT:
          final decodedContent =
              utf8.decode(base64Decode(base64DataStream.value));
          res = """
        <html>
            <script>
              function display() {
                  window.print();
              }
          </script>
          <body>
            <pre>${decodedContent}</pre>
          </body>
        </html>""";
          break;
        case Extension.DOCX:
          res = await pdfService.wordToHtml(widget.id);
          break;
        case Extension.HTML:
          res = """<script>
                function display() {
                    window.print();
                }
            </script>""";
          res = res + utf8.decode(base64Decode(base64DataStream.value));
          break;
        case Extension.IMAGE:
          var imageBase64 = await pdfService.getImageInBase64ById(widget.id);
          res = """
      <html>
      <script>
              function display() {
                  window.print();
              }
          </script> 
        <body>
        <img src="data:image/jpeg;base64,${imageBase64}"/>
        </body> 
      </html>""";
          break;
        case Extension.PDF:
          res = await pdfService.pdfFromImageIdsToHtml(
              imageIdsStream.value, widget.name);
          break;
      }
      _htmlDocument.add(res);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  getExtension() {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
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

  printDoc() async {
    var extension = extensionStream.value;
    if (extension == Extension.TXT ||
        extension == Extension.DOCX ||
        extension == Extension.HTML) {
      controllerWeb?.callJsMethod("display", []);
    }
    if (extension == Extension.IMAGE || extension == Extension.PDF) {
      controllerWeb2?.callJsMethod("display", []);
    }
  }

  getBase64() async {
    try {
      var data = await pdfService.downloadFilesById(widget.id);
      base64DataStream.add(data);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }

  void download() async {
    var data = base64DataStream.value;
    if (extensionStream.valueOrNull == Extension.PDF) {
      data = await pdfService.createPdfFromImageIds(
          imageIdsStream.value, widget.name);
    }
    ReusedWidgets.download(
      context,
      uri: "",
      name: widget.name,
      base64Data: data,
      token: token,
    );
  }
}

enum Extension {
  PDF,
  DOCX,
  HTML,
  IMAGE,
  TXT,
}
