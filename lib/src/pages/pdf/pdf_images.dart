import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:rxdart/subjects.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  bool initialize = false;
  init() {
    if (initialize) return;
    initialize = true;
    widget.imageIds.forEach((id) => showImage(id));
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
                  icon: Icon(Icons.download),
                  onPressed: (() => downloadPdf(widget.id)),
                  label: Text(lang.download))
            ],
          ),
          body: StreamBuilder<String>(
              stream: tokenService
                  .getToken()
                  .asStream()
                  .map((event) => event ?? ""),
              builder: (context, snapshot) {
                var token = snapshot.data;
                if (token == null) {
                  return SizedBox.shrink();
                }
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.imageIds
                          .map((e) => showImage(e))
                          .map((url) => Card(
                                // color: Colors.red,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {},
                                            child: Text("Rotate Left"))
                                      ],
                                    ),
                                    Image.network(
                                      url,
                                      headers: {
                                        "Authorization": "Bearer $token"
                                      },
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              })),
    );
  }

  String showImage(String id) {
    return "${getUrlBase()}/admin/grid/content/${id}";
  }

  Future<void> downloadPdf(String id) async {
    String? authToken = await tokenService.getToken();
    final response = await http.get(
      Uri.parse("${getUrlBase()}/admin/grid/content/${id}"),
      headers: {"Authorization": "Bearer $authToken"},
    );
    final bytes = response.bodyBytes;

    print("bytes ......... ${bytes.length}");
    if (kIsWeb) {
      final content = base64Encode(bytes);
      final anchor = html.AnchorElement(
          href:
              "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", widget.name)
        ..click();
    } else {
      //@TODO
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
