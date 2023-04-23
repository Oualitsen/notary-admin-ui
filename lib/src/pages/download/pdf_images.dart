import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/pages/download/image_widget.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/files/pdf_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class PdfImages extends StatefulWidget {
  final String name;
  final String id;
  final Function(List<String> imageIds) onImageIdsChange;
  const PdfImages({
    super.key,
    required this.name,
    required this.id,
    required this.onImageIdsChange,
  });

  @override
  State<PdfImages> createState() => _PdfImagesState();
}

class _PdfImagesState extends BasicState<PdfImages> with WidgetUtilsMixin {
  final archiveService = GetIt.instance.get<FilesArchiveService>();
  final pdfService = GetIt.instance.get<PdfService>();

  final tokenService = GetIt.instance.get<TokenDbService>();
  final imageIdsStream = BehaviorSubject.seeded(<String>[]);
  bool initialize = false;
  final scrollController = ScrollController();
  double scrollPosition = 0.0;
  init() async {
    if (initialize) return;
    initialize = true;
    await getImageIds();
    imageIdsStream.listen((value) {
      widget.onImageIdsChange(value);
    });
    scrollController.addListener(() {
      scrollPosition = scrollController.position.pixels;
      // ...
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return StreamBuilder<String>(
      stream: tokenService.getToken().asStream().map((event) => event ?? ""),
      builder: (context, snapshot) {
        var token = snapshot.data;
        if (token == null) {
          return SizedBox.shrink();
        }
        return SingleChildScrollView(
          controller: scrollController,
          child: Center(
            child: StreamBuilder<List<String>>(
                stream: imageIdsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  scrollController.jumpTo(scrollPosition);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: snapshot.data!.map(
                      (id) {
                        return ImageWidget(
                          imageId: id,
                          token: token,
                          onAngleChanged: (imageId) {
                            imageIdsStream.add(imageIdsStream.value);
                          }
                        );
                      },
                    ).toList(),
                  );
                }),
          ),
        );
      },
    );
  }

  Future<void> downloadPdf(String id) async {
    String? authToken = await tokenService.getToken();
    final uri = "${getUrlBase()}/admin/pdf/create";

    final response = await http.post(
      Uri.parse("$uri/${widget.name}"),
      headers: {
        "Authorization": "Bearer $authToken",
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(imageIdsStream.value),
    );
    Uint8List bytes = response.bodyBytes;
    if (kIsWeb) {
      final content = base64Encode(bytes);
      html.AnchorElement(
          href:
              "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", widget.name)
        ..click();
    } else {
      saveBytesToFile(bytes);
    }
  }

  Future<void> saveBytesToFile(List<int> bytes) async {
    String? path;
    var status = await Permission.storage.request();
    if (status.isGranted) {
      path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: lang.directoryDialog,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(lang.permissionDenied),
          content: Text(lang.permissionText),
          actions: [
            getButtons(
              saveLabel: lang.openSettings,
              onSave: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    }

    if (path == null) {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw lang.noDirectoryPath;
      }
      path = directory.path;
    }

    final file = File('${path}/${widget.name}');
    await file.writeAsBytes(bytes);

    await Fluttertoast.showToast(
      msg: "${lang.savedSuccessfully} ${file.path}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future getImageIds() async {
    try {
      var imageIds = await pdfService.getPdfImages(widget.id);
      imageIdsStream.add(imageIds);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }
}
