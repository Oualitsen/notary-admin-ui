import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class UploadTemplatePage extends StatefulWidget {
  final UploadData? firstPath;
  const UploadTemplatePage({super.key, this.firstPath});

  @override
  State<UploadTemplatePage> createState() => _UploadTemplatePageState();
}

class _UploadTemplatePageState extends BasicState<UploadTemplatePage>
    with WidgetUtilsMixin {
  final UploadService uploadService = new UploadService(GetIt.instance.get());
  final uploadDataStream = BehaviorSubject.seeded(<UploadData>[]);
  final key = GlobalKey<InfiniteScrollListViewState<UploadData>>();
  @override
  void initState() {
    if (widget.firstPath != null) {
      uploadDataStream.add([widget.firstPath!]);
    }

    uploadDataStream
        .where((event) => key.currentState != null)
        .map((event) => key.currentState!)
        .listen((event) {
      event.reload();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.uploadFile),
        ),
        body: InfiniteScrollListView<UploadData>(
          key: key,
          elementBuilder: (context, element, index, animation) {
            return ListTile(
              leading: CircleAvatar(child: Icon(Icons.file_copy)),
              title: Text("${element.name}"),
              trailing: Wrap(
                children: [
                  StreamBuilder<double>(
                      stream: element.progress,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return IconButton(
                              onPressed: () {
                                upload(element).listen((event) {});
                              },
                              icon: Icon(
                                Icons.refresh,
                                color: Theme.of(context).colorScheme.secondary,
                              ));
                        }
                        if (snapshot.hasData) {
                          return Text("${snapshot.data} %");
                        }
                        return IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              _delete(element);
                              if (uploadDataStream.value.isEmpty) {
                                Navigator.of(context).pop();
                              }
                            });
                      }),
                ],
              ),
            );
          },
          pageLoader: (index) {
            if (index == 0) {
              return Future.value(uploadDataStream.value);
            }
            return Future.value([]);
          },
          endOfResultWidget: Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: loadFiles,
              child: Text(
                lang.addFileTitle.toUpperCase(),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        floatingActionButton: getButtons(onSave: save),
      ),
    );
  }

  Future loadFiles() async {
    List<String> extensions = ["docx"];
    try {
      var pickedFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: extensions);
      if (pickedFile != null) {
        var path = null;
        if (!kIsWeb) {
          path = pickedFile.files.first.path;
        }
        var data = UploadData(
            data: pickedFile.files.first.bytes,
            name: pickedFile.files.first.name,
            path: path);
        var list = uploadDataStream.value;
        list.add(data);
        uploadDataStream.add(list);
      }
    } catch (e) {
      print("[ERROR]${e.toString}");
    }
  }

  void save() async {
    Rx.combineLatest(uploadDataStream.value.map((ud) => upload(ud)).toList(),
        (values) => values).doOnListen(() {
      progressSubject.add(true);
    }).doOnDone(() {
      progressSubject.add(false);
    }).listen((event) async {
      await showSnackBar2(context, lang.createdsuccssfully);
      Navigator.of(context).pop();
    });
  }

  Stream<dynamic> upload(UploadData data) {
    try {
      var uri = "/admin/template/upload";
      if (kIsWeb && data.data != null) {
        return uploadService
            .upload(
              uri,
              data.data!,
              data.name,
              callBack: (percentage) {
                data.progress.add(percentage);
              },
            )
            .asStream()
            .doOnData((event) {
              _delete(data);
            })
            .doOnError(
              (p0, p1) {
                data.progress.addError(p0);
              },
            );
      } else if (!kIsWeb && data.path != null) {
        return uploadService
            .uploadFileDynamic(
              uri,
              data.path!,
              callBack: (percentage) {
                data.progress.add(percentage);
              },
            )
            .asStream()
            .doOnData((event) {
              _delete(data);
            })
            .doOnError(
              (p0, p1) {
                data.progress.addError(p0);
              },
            );
      }
    } catch (error, stacktrace) {
      print(stacktrace);
      showServerError(context, error: error);
    }
    return Stream.empty();
  }

  void _delete(UploadData data) {
    var list = uploadDataStream.value;
    list.remove(data);

    uploadDataStream.add(list);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class UploadData {
  final BehaviorSubject<double> progress;
  final Uint8List? data;
  final String name;
  final String? path;
  UploadData({required this.data, required this.name, required this.path})
      : progress = BehaviorSubject<double>();
}
