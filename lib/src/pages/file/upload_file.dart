import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class UploadFilePage extends StatefulWidget {
  final String? firstPath;
  const UploadFilePage({super.key, this.firstPath});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends BasicState<UploadFilePage>
    with WidgetUtilsMixin {
  final UploadService uploadService = new UploadService(GetIt.instance.get());
  final pathFiles = BehaviorSubject.seeded(<_UploadData>[]);
  final key = GlobalKey<InfiniteScrollListViewState<_UploadData>>();
  @override
  void initState() {
    if (widget.firstPath != null) {
      pathFiles.add([_UploadData(widget.firstPath!)]);
    }

    pathFiles
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
        body: InfiniteScrollListView<_UploadData>(
          key: key,
          elementBuilder: (context, element, index, animation) {
            var name = element.path.split('/').last;
            return ListTile(
              leading: CircleAvatar(child: Icon(Icons.file_copy)),
              title: Text("${name}"),
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
                              if (pathFiles.value.isEmpty) {
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
              return Future.value(pathFiles.value);
            }
            return Future.value([]);
          },
          endOfResultWidget: Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: loadFiles,
              child: Wrap(
                children: [
                  Text(
                    lang.addFileTitle.toUpperCase(),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.add_circle_outline_rounded),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: wrap(
          getButtons(onSave: save),
        ),
      ),
    );
  }

  Future loadFiles() async {
    List<String> extensions = ["docx"];
    try {
      var platformFiles = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: extensions);
      if (platformFiles != null) {
        var path = platformFiles.files.first.path;
        if (path != null) {
          var list = pathFiles.value;
          list.add(_UploadData(path));
          pathFiles.add(list);
        }
      }
    } catch (e) {
      print("[ERROR]${e.toString}");
    }
  }

  void save() async {
    Rx.combineLatest(pathFiles.value.map((ud) => upload(ud)).toList(),
        (values) => values).doOnListen(() {
      progressSubject.add(true);
    }).doOnDone(() {
      progressSubject.add(false);
    }).listen((event) async {
      await showSnackBar2(context, lang.createdsuccssfully);
      Navigator.of(context).pop();
    });
  }

  Stream<dynamic> upload(_UploadData path) {
    return uploadService
        .uploadFileDynamic(
          "/admin/template/upload",
          path.path,
          callBack: (percentage) {
            path.progress.add(percentage);
          },
        )
        .asStream()
        .doOnData((event) {
          _delete(path);
        })
        .doOnError((p0, p1) {
          path.progress.addError(p0);
        });
  }

  void _delete(_UploadData data) {
    var list = pathFiles.value;
    list.remove(data);

    pathFiles.add(list);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class _UploadData {
  final String path;
  final BehaviorSubject<double> progress;

  _UploadData(this.path) : progress = BehaviorSubject<double>();
}
