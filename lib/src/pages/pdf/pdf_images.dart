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
import 'package:notary_admin/src/pages/pdf/image_widget.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
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
  final List<String> imageIds;
  const PdfImages(
      {super.key,
      required this.name,
      required this.id,
      required this.imageIds});

  @override
  State<PdfImages> createState() => _PdfImagesState();
}

class _PdfImagesState extends BasicState<PdfImages> with WidgetUtilsMixin {
  final archiveService = GetIt.instance.get<FilesArchiveService>();
  final tokenService = GetIt.instance.get<TokenDbService>();
  final uri = "${getUrlBase()}/admin/grid/content";

  late List<ImageRotationInfo> imageRotationInfo;
  bool initialize = false;

  init() {
    if (initialize) return;
    initialize = true;

    imageRotationInfo =
        widget.imageIds.map((id) => ImageRotationInfo(id, 0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    init();
    return WidgetUtils.wrapRoute(
      (context, type) {
        return Scaffold(
          appBar: AppBar(
            title: Text("${widget.name}"),
            actions: [
              ElevatedButton.icon(
                  icon: Icon(Icons.download),
                  onPressed: (() => downloadPdf(widget.id)),
                  label: Text(lang.download)),
              
            ],
          ),
          body: StreamBuilder<String>(
            stream:
                tokenService.getToken().asStream().map((event) => event ?? ""),
            builder: (context, snapshot) {
              var token = snapshot.data;
              if (token == null) {
                return SizedBox.shrink();
              }
              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.imageIds.map(
                      (id) {
                        return ImageWidget(
                          imageId: id,
                          token: token,
                          onAngleChanged: (angle) {
                            var index = imageRotationInfo
                                .indexWhere((element) => element.id == id);
                            imageRotationInfo[index].angle = angle;
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> downloadPdf(String id) async {
    String? authToken = await tokenService.getToken();
    final response = await http.post(
      Uri.parse("$uri/pdf/${widget.name}"),
      headers: {
        "Authorization": "Bearer $authToken",
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(widget.imageIds),
    );
    final bytes = response.bodyBytes;
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

  
}

class ImageRotationInfo {
  String id;
  double angle;
  ImageRotationInfo(this.id, this.angle);
}
