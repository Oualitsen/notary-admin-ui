import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/files/widget_document_picked.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/rxdart.dart';
import '../../services/files/files_service.dart';
import '../../services/upload_service.dart';
import 'list_files_customer.dart';

class UpdateDocumentFolderCustomer extends StatefulWidget {
  final Files files;

  const UpdateDocumentFolderCustomer({
    super.key,
    required this.files,
  });
  @override
  State<UpdateDocumentFolderCustomer> createState() =>
      _UpdateDocumentFolderCustomerState();
}

class _UpdateDocumentFolderCustomerState
    extends BasicState<UpdateDocumentFolderCustomer> with WidgetUtilsMixin {
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  late Files files;
  final bool statusUpload = false;
  final pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final pathDocumentsUpdateStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final allUploadedStream = BehaviorSubject.seeded(false);
  @override
  initState() {
    files = widget.files;

    pathDocumentsStream.add(widget.files.specification.documents
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
    pathDocumentsUpdateStream.add(widget.files.specification.documents
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
                  : StreamBuilder<List<PathsDocuments>>(
                      stream: pathDocumentsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return SizedBox.shrink();
                        }
                        return ListTile(
                          leading: Icon(Icons.file_download),
                          title: Text(
                            " ${files.specification.documents[index].name} ",
                            style:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                                  stream:
                                      pathDocumentsStream.value[index].progress,
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
                              ElevatedButton(
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
                                            files.specification.documents[index]
                                                .id,
                                            pickedBytes,
                                            true,
                                            namePickedFile,
                                            files.specification.documents[index]
                                                .name,
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
            }),
        bottomNavigationBar: StreamBuilder<bool>(
            stream: allUploadedStream,
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return SizedBox.shrink();
              }
              return ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: snapshot.data! ? save : null,
                      child: Text(lang.submit)),
                ],
              );
            }),
      ),
    );
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

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => ListFilesCustomer()));
        } else {
          await showSnackBar2(context, lang.noDocument);
        }
      } else {
        if (pathDocumentsUpdateStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsUpdateStream.value) {
            if (pathDoc.selected && pathDoc.document != null) {
              await _uploadWeb(pathDoc);
            }
          }

          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => ListFilesCustomer()));
        } else {
          await showSnackBar2(context, lang.noDocument);
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => ListFilesCustomer()));
        } else {
          await showSnackBar2(context, lang.noDocument);
        }
      } else {
        if (pathDocumentsUpdateStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsUpdateStream.value) {
            if (pathDoc.selected && pathDoc.path != null) {
              await _uploadWeb(pathDoc);
            }
          }
          await showSnackBar2(context, lang.savedSuccessfully);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => ListFilesCustomer()));
        } else {
          await showSnackBar2(context, lang.noDocument);
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
}
