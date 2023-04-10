import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/rxdart.dart';
import 'files_page.dart';

class WidgetDocumentPicked extends StatefulWidget {
  final Files files;

  const WidgetDocumentPicked({super.key, required this.files});

  @override
  State<WidgetDocumentPicked> createState() => _WidgetDocumentPickedState();
}

class _WidgetDocumentPickedState extends BasicState<WidgetDocumentPicked>
    with WidgetUtilsMixin {
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  late Files files;
  final bool statusUpload = false;
  final pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final pathDocumentsUpdateStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final allUploadedStream = BehaviorSubject.seeded(false);
  @override
  void initState() {
    files = widget.files;
    if (files.uploadedFiles.isEmpty) {
      pathDocumentsStream
          .add(widget.files.specification.partsSpecs[0].documentSpec
              .map(
                (e) => PathsDocuments(
                  idDocument: e.id,
                  document: null,
                  selected: false,
                  namePickedDocument: null,
                  path: null,
                ),
              )
              .toList());
    } else {
      pathDocumentsStream
          .add(widget.files.specification.partsSpecs[0].documentSpec
              .map(
                (e) => PathsDocuments(
                  idDocument: e.id,
                  document: null,
                  selected: true,
                  namePickedDocument: '',
                  nameDocument: '',
                  path: null,
                ),
              )
              .toList());
      pathDocumentsUpdateStream
          .add(widget.files.specification.partsSpecs[0].documentSpec
              .map(
                (e) => PathsDocuments(
                  idDocument: e.id,
                  document: null,
                  selected: false,
                  namePickedDocument: '',
                  nameDocument: '',
                  path: null,
                ),
              )
              .toList());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: files.specification.partsSpecs[0].documentSpec.isEmpty
            ? 1
            : files.specification.partsSpecs[0].documentSpec.length,
        itemBuilder: (BuildContext context, int index) {
          return files.specification.partsSpecs[0].documentSpec.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(lang.noDocument.toUpperCase()),
                )
              : StreamBuilder<List<PathsDocuments>>(
                  stream: pathDocumentsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return SizedBox.shrink();
                    }
                    return ListTile(
                      leading: Icon(Icons.file_download),
                      title: Text(
                        " ${files.specification.partsSpecs[0].documentSpec[index].name} ",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        maxLines: 50,
                      ),
                      subtitle: Row(
                        children: [
                          snapshot.data![index].selected == true
                              ? Flexible(
                                  child: Text(
                                    pathDocumentsStream
                                        .value[index].namePickedDocument
                                        .toString(),
                                    softWrap: true,
                                  ),
                                )
                              : files.uploadedFiles.isEmpty
                                  ? Text(lang.noUpload)
                                  : SizedBox.shrink(),
                          StreamBuilder<double>(
                              stream: pathDocumentsStream.value[index].progress,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ));
                                }
                                if (snapshot.hasData) {
                                  return Text(
                                    "   ...${snapshot.data} %",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              }),
                        ],
                      ),
                      trailing: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.end,
                        spacing: 10,
                        children: [
                          pathDocumentsStream.value[index].selected == true &&
                                  files.uploadedFiles.isEmpty
                              ? OutlinedButton(
                                  onPressed: () =>
                                      delete(snapshot.data![index], index),
                                  child: Icon(Icons.delete))
                              : SizedBox.shrink(),
                          files.uploadedFiles.isEmpty
                              ? ElevatedButton(
                                  child: Text(lang.addFiles),
                                  onPressed: () async {
                                    var picked =
                                        await FilePicker.platform.pickFiles();

                                    if (picked != null) {
                                      var pickedPath = null;
                                      if (!kIsWeb) {
                                        pickedPath = picked.files.first.path;
                                      }
                                      final pickedBytes =
                                          picked.files.first.bytes;

                                      final namePickedFile =
                                          picked.files.first.name;
                                      final extensionPickedFile =
                                          picked.files.first.extension;
                                      if (pickedBytes != null ||
                                          pickedPath != null) {
                                        var list = pathDocumentsStream.value;
                                        list.removeAt(index);
                                        list.insert(
                                            index,
                                            addPathDocument(
                                              files.specification.partsSpecs[0]
                                                  .documentSpec[index].id,
                                              pickedBytes,
                                              true,
                                              namePickedFile,
                                              files.specification.partsSpecs[0]
                                                  .documentSpec[index].name,
                                              pickedPath,
                                            ));
                                        pathDocumentsStream.add(list);
                                        allUploaded(false);
                                      } else {}
                                    }
                                  },
                                )
                              : ElevatedButton(
                                  child: Text(lang.remplaceFile),
                                  onPressed: () async {
                                    var picked =
                                        await FilePicker.platform.pickFiles();
                                    if (picked != null) {
                                      var pickedPath = null;
                                      if (!kIsWeb) {
                                        pickedPath = picked.files.first.path;
                                      }
                                      final pickedBytes =
                                          picked.files.first.bytes;
                                      final namePickedFile =
                                          picked.files.first.name;
                                      final extensionPickedFile =
                                          picked.files.first.extension;
                                      if (pickedBytes != null ||
                                          pickedPath != null) {
                                        var list =
                                            pathDocumentsUpdateStream.value;
                                        if (pathDocumentsUpdateStream.value
                                            .asMap()
                                            .containsKey(index)) {
                                          list.removeAt(index);
                                          list.insert(
                                            index,
                                            addPathDocument(
                                              files.specification.partsSpecs[0]
                                                  .documentSpec[index].id,
                                              pickedBytes,
                                              true,
                                              namePickedFile,
                                              files.specification.partsSpecs[0]
                                                  .documentSpec[index].name,
                                              pickedPath,
                                            ),
                                          );
                                        }
                                        pathDocumentsUpdateStream.add(list);
                                        pathDocumentsStream.add(list);
                                        allUploaded(true);
                                      }
                                    }
                                  },
                                ),
                        ],
                      ),
                    );
                  });
        });
  }

  void allUploaded(bool update) {
    if (update == false) {
      for (var pathDoc in pathDocumentsStream.value) {
        if (!pathDoc.selected) {
          allUploadedStream.add(false);
          return;
        }
      }
      allUploadedStream.add(true);
    } else {
      allUploadedStream.add(true);
    }
  }

  save() async {
    if (kIsWeb) {
      await webSave();
    } else {
      await devSave();
    }
  }

  PathsDocuments addPathDocument(
      String idDocument,
      Uint8List? document,
      bool selected,
      String namePickedDocument,
      String nameDocument,
      String? path) {
    var result;
    result = PathsDocuments(
      idDocument: idDocument,
      selected: selected,
      document: document,
      namePickedDocument: namePickedDocument,
      nameDocument: nameDocument,
      path: path,
    );

    return result;
  }

  webSave() async {
    try {
      if (files.uploadedFiles.isEmpty) {
        if (pathDocumentsStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsStream.value) {
            if (pathDoc.document != null) {
              await _uploadWeb(pathDoc);
            }
          }
          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext) => FilesPage()));
        } else {
          showSnackBar2(context, lang.noDocument);
        }
      } else {
        if (pathDocumentsUpdateStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsUpdateStream.value) {
            if (pathDoc.selected && pathDoc.document != null) {
              await _uploadWeb(pathDoc);
            }
          }

          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext) => FilesPage()));
        } else {
          showSnackBar2(context, lang.noDocument);
        }
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  devSave() async {
    try {
      if (files.uploadedFiles.isEmpty) {
        if (pathDocumentsStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsStream.value) {
            if (pathDoc.path != null) {
              await _uploadDev(pathDoc);
            }
          }
          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext) => FilesPage()));
        } else {
          showSnackBar2(context, lang.noDocument);
        }
      } else {
        if (pathDocumentsUpdateStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsUpdateStream.value) {
            if (pathDoc.selected && pathDoc.path != null) {
              await _uploadWeb(pathDoc);
            }
          }
          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext) => FilesPage()));
        } else {
          showSnackBar2(context, lang.noDocument);
        }
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  _uploadWeb(PathsDocuments pathDoc) async {
    try {
      await serviceUploadDocument.upload(
        "/admin/files/upload/${files.id}/${files.specification.id}/${pathDoc.idDocument}",
        pathDoc.document!,
        pathDoc.nameDocument!,
        callBack: (percentage) {
          pathDoc.progress.add(percentage);
        },
      );
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  _uploadDev(PathsDocuments pathDoc) async {
    try {
      await serviceUploadDocument.uploadFileDynamic(
        "/admin/files/upload/${files.id}/${files.specification.id}/${pathDoc.idDocument}",
        pathDoc.path!,
        callBack: (percentage) {
          pathDoc.progress.add(percentage);
        },
      );
    } catch (error, stacktrace) {
      showServerError(context, error: error);
      print(stacktrace);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => throw UnimplementedError();

  @override
  List<Subject> get subjects => throw UnimplementedError();

  delete(PathsDocuments pathsDocuments, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.confirm),
        content: Text(lang.confirmDelete),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(lang.no.toUpperCase())),
          TextButton(
              onPressed: () {
                var list = pathDocumentsStream.value;
                list.removeAt(index);
                list.insert(
                    index,
                    addPathDocument(
                      files.specification.partsSpecs[0].documentSpec[index].id,
                      null,
                      false,
                      '',
                      '',
                      null,
                    ));
                pathDocumentsStream.add(list);
                allUploaded(false);
                Navigator.of(context).pop(true);
              },
              child: Text(lang.confirm.toUpperCase())),
        ],
      ),
    );
  }
}

class PathsDocuments {
  final String idDocument;
  final Uint8List? document;
  final String? namePickedDocument;
  final String? nameDocument;
  final bool selected;
  final String? path;
  final BehaviorSubject<double> progress;

  PathsDocuments(
      {this.namePickedDocument,
      this.nameDocument,
      this.document,
      required this.idDocument,
      this.selected = false,
      required this.path})
      : progress = BehaviorSubject<double>();
}
