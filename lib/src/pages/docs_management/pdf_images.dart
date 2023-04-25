import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/pages/docs_management/image_widget.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/files/data_manager_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

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
  final pdfService = GetIt.instance.get<DataManagerService>();

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
                            });
                      },
                    ).toList(),
                  );
                }),
          ),
        );
      },
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future getImageIds() async {
    try {
      var imageIds = await pdfService.getPdfImageIds(widget.id);
      imageIdsStream.add(imageIds);
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
      throw error;
    }
  }
}
