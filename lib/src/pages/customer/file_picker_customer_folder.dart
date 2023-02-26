import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/subjects/subject.dart';
import '../../services/upload_service.dart';

class FilePickerCustomerFolder extends StatefulWidget {
  final Files files;
  const FilePickerCustomerFolder({super.key, required this.files});
  @override
  State<FilePickerCustomerFolder> createState() =>
      _FilePickerCustomerFolderState();
}

class _FilePickerCustomerFolderState
    extends BasicState<FilePickerCustomerFolder> with WidgetUtilsMixin {
  final serviceUploadDocument = GetIt.instance.get<UploadService>();

  late Files files;
  final bool statusUpload = false;
  final pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  @override
  initState() {
    files = widget.files;
    pathDocumentsStream.add(widget.files.specification.documents
        .map((e) => PathsDocuments(
            idDocument: e.id, pathDocument: null, selected: false))
        .toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.selectDocuments.toUpperCase()),
        ),
        body: ListView.builder(
            itemCount: files.specification.documents.isEmpty
                ? 1
                : files.specification.documents.length,
            itemBuilder: (BuildContext context, int index) {
              return files.specification.documents.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(lang.noDocument.toUpperCase()),
                    )
                  : ListTile(
                      title: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("${lang.selectDocuments.toUpperCase()}"),
                            SizedBox(
                              width: 30,
                            ),
                            ElevatedButton(
                              child: Text(lang.addFiles.toUpperCase()),
                              onPressed: () async {
                                var picked =
                                    await FilePicker.platform.pickFiles();
                                if (picked != null) {
                                  var path = picked.files.first.path;
                                  if (path != null) {
                                    var list = pathDocumentsStream.value;
                                    list.removeAt(index);
                                    list.insert(
                                        index,
                                        addPathDocument(
                                            files.specification.documents[index]
                                                .id,
                                            path,
                                            true));
                                    pathDocumentsStream.add(list);
                                  } else {}
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      subtitle: StreamBuilder<List<PathsDocuments>>(
                          stream: pathDocumentsStream,
                          initialData: pathDocumentsStream.value,
                          builder: (context, snapshot) {
                            if (snapshot.hasData == false) {
                              return SizedBox.shrink();
                            }
                            return Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Icon(Icons.file_download),
                                    SizedBox(width: 20),
                                    Row(children: [
                                      Text(
                                        " ${files.specification.documents[index].name.toUpperCase()} : ",
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 0, 0)),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      snapshot.data![index].selected == true
                                          ? Icon(Icons.check)
                                          : Icon(Icons.add),
                                    ]),
                                    SizedBox(width: 20),
                                    StreamBuilder<double>(
                                        stream: pathDocumentsStream
                                            .value[index].progress,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return IconButton(
                                                onPressed: () {
                                                  //  upload(element).listen((event) {});
                                                },
                                                icon: Icon(
                                                  Icons.refresh,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ));
                                          }
                                          if (snapshot.hasData) {
                                            return Text("${snapshot.data} %");
                                          }
                                          return SizedBox.shrink();
                                        }),
                                    SizedBox(width: 30),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext) => AlertDialog(
                                                        title:
                                                            Text(lang.confirm),
                                                        content: Text(
                                                            lang.confirmDelete),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                              child: Text(lang
                                                                  .no
                                                                  .toUpperCase())),
                                                          TextButton(
                                                              onPressed: () {
                                                                var list =
                                                                    pathDocumentsStream
                                                                        .value;
                                                                list.removeAt(
                                                                    index);
                                                                list.insert(
                                                                    index,
                                                                    addPathDocument(
                                                                        files
                                                                            .specification
                                                                            .documents[index]
                                                                            .id,
                                                                        null,
                                                                        false));
                                                                pathDocumentsStream
                                                                    .add(list);

                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                              child: Text(lang
                                                                  .confirm
                                                                  .toUpperCase())),
                                                        ],
                                                      ));
                                        },
                                        icon: pathDocumentsStream
                                                    .value[index].selected ==
                                                true
                                            ? Icon(Icons.delete)
                                            : Icon(null)),
                                  ],
                                ));
                          }),
                      onTap: () async {
                        var picked = await FilePicker.platform.pickFiles();
                        if (picked != null) {
                          var path = picked.files.first.path;
                          if (path != null) {
                            var list = pathDocumentsStream.value;
                            list.removeAt(index);
                            list.insert(
                                index,
                                addPathDocument(
                                    files.specification.documents[index].id,
                                    path,
                                    true));
                            pathDocumentsStream.add(list);
                          } else {}
                        }
                      },
                    );
            }),
        bottomNavigationBar: getButtons(
          onSave: save,
          saveLabel: lang.submit.toUpperCase(),
          skipCancel: true,
        ),
      ),
    );
  }

  save() async {
    try {
      if (pathDocumentsStream.value.isNotEmpty) {
        for (int index = 0; index < pathDocumentsStream.value.length; index++) {
          await serviceUploadDocument.uploadFileDynamic(
            "/admin/files/upload/${files.id}/${files.specification.id}/${pathDocumentsStream.value[index].idDocument}",
            pathDocumentsStream.value[index].pathDocument!,
            callBack: (percentage) {
              pathDocumentsStream.value[index].progress.add(percentage);
            },
          );
        }
        await showSnackBar2(context, lang.savedSuccessfully);
      } else {
        await showSnackBar2(context, lang.noDocument);
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  PathsDocuments addPathDocument(
      String idDocument, String? pathDocument, bool selected) {
    var result;

    result = PathsDocuments(
        idDocument: idDocument, pathDocument: pathDocument, selected: selected);

    return result;
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];
}

class PathsDocuments {
  final String idDocument;
  final String? pathDocument;
  final bool selected;
  final BehaviorSubject<double> progress;

  PathsDocuments(
      {required this.idDocument,
      required this.pathDocument,
      this.selected = false})
      : progress = BehaviorSubject<double>();
}
