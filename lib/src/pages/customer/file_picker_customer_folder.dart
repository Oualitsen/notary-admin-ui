import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/rxdart.dart';
import '../../services/files/files_service.dart';
import '../../services/upload_service.dart';
import 'list_files_customer.dart';

class FilePickerCustomerFolder extends StatefulWidget {
  final Files files;

  const FilePickerCustomerFolder({
    super.key,
    required this.files,
  });
  @override
  State<FilePickerCustomerFolder> createState() =>
      _FilePickerCustomerFolderState();
}

class _FilePickerCustomerFolderState
    extends BasicState<FilePickerCustomerFolder> with WidgetUtilsMixin {
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
    if (files.uploadedFiles.isEmpty) {
      pathDocumentsStream.add(widget.files.specification.documents
          .map((e) => PathsDocuments(
              idDocument: e.id,
              document: null,
              selected: false,
              namePickedDocument: null))
          .toList());
    } else {
      pathDocumentsStream.add(widget.files.specification.documents
          .map((e) => PathsDocuments(
              idDocument: e.id,
              document: null,
              selected: true,
              namePickedDocument: '',
              nameDocument: ''))
          .toList());
      pathDocumentsUpdateStream.add(widget.files.specification.documents
          .map((e) => PathsDocuments(
              idDocument: e.id,
              document: null,
              selected: false,
              namePickedDocument: '',
              nameDocument: ''))
          .toList());
    }

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
                              pathDocumentsStream.value[index].selected ==
                                          true &&
                                      files.uploadedFiles.isEmpty
                                  ? OutlinedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext) =>
                                                AlertDialog(
                                                  title: Text(lang.confirm),
                                                  content:
                                                      Text(lang.confirmDelete),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                        child: Text(lang.no
                                                            .toUpperCase())),
                                                    TextButton(
                                                        onPressed: () {
                                                          var list =
                                                              pathDocumentsStream
                                                                  .value;
                                                          list.removeAt(index);
                                                          list.insert(
                                                              index,
                                                              addPathDocument(
                                                                  files
                                                                      .specification
                                                                      .documents[
                                                                          index]
                                                                      .id,
                                                                  null,
                                                                  false,
                                                                  '',
                                                                  ''));
                                                          pathDocumentsStream
                                                              .add(list);
                                                          allUploaded(false);
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                        child: Text(lang.confirm
                                                            .toUpperCase())),
                                                  ],
                                                ));
                                      },
                                      child: Icon(Icons.delete))
                                  : SizedBox.shrink(),
                              files.uploadedFiles.isEmpty
                                  ? ElevatedButton(
                                      child: Text(lang.addFiles),
                                      onPressed: () async {
                                        var picked = await FilePicker.platform
                                            .pickFiles();

                                        if (picked != null) {
                                          final pickedBytes =
                                              picked.files.first.bytes;
                                          final namePickedFile =
                                              picked.files.first.name;
                                          final extensionPickedFile =
                                              picked.files.first.extension;
                                          if (pickedBytes != null) {
                                            var list =
                                                pathDocumentsStream.value;
                                            list.removeAt(index);
                                            list.insert(
                                                index,
                                                addPathDocument(
                                                    files.specification
                                                        .documents[index].id,
                                                    pickedBytes,
                                                    true,
                                                    namePickedFile,
                                                    files
                                                        .specification
                                                        .documents[index]
                                                        .name));
                                            pathDocumentsStream.add(list);
                                            allUploaded(false);
                                          } else {}
                                        }
                                      },
                                    )
                                  : ElevatedButton(
                                      child: Text(lang.remplaceFile),
                                      onPressed: () async {
                                        var picked = await FilePicker.platform
                                            .pickFiles();
                                        if (picked != null) {
                                          final pickedBytes =
                                              picked.files.first.bytes;
                                          final namePickedFile =
                                              picked.files.first.name;
                                          final extensionPickedFile =
                                              picked.files.first.extension;
                                          if (pickedBytes != null) {
                                            var list =
                                                pathDocumentsUpdateStream.value;
                                            if (pathDocumentsUpdateStream.value
                                                .asMap()
                                                .containsKey(index)) {
                                              list.removeAt(index);
                                              list.insert(
                                                  index,
                                                  addPathDocument(
                                                      files.specification
                                                          .documents[index].id,
                                                      pickedBytes,
                                                      true,
                                                      namePickedFile,
                                                      files
                                                          .specification
                                                          .documents[index]
                                                          .name));
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
    try {
      if (files.uploadedFiles.isEmpty) {
        if (pathDocumentsStream.value.isNotEmpty) {
          for (var pathDoc in pathDocumentsStream.value) {
            await serviceUploadDocument.upload(
              "/admin/files/upload/${files.id}/${files.specification.id}/${pathDoc.idDocument}",
              pathDoc.document!,
              pathDoc.nameDocument!,
              callBack: (percentage) {
                pathDoc.progress.add(percentage);
              },
            );
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
            if (pathDoc.selected) {
              await serviceUploadDocument.upload(
                "/admin/files/upload/${files.id}/${files.specification.id}/${pathDoc.idDocument}",
                pathDoc.document!,
                pathDoc.nameDocument!,
                callBack: (percentage) {
                  pathDoc.progress.add(percentage);
                },
              );
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

  PathsDocuments addPathDocument(String idDocument, Uint8List? document,
      bool selected, String namePickedDocument, String nameDocument) {
    var result;

    result = PathsDocuments(
        idDocument: idDocument,
        selected: selected,
        document: document,
        namePickedDocument: namePickedDocument,
        nameDocument: nameDocument);

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
  final Uint8List? document;
  final String? namePickedDocument;
  final String? nameDocument;
  final bool selected;
  final BehaviorSubject<double> progress;

  PathsDocuments(
      {this.namePickedDocument,
      this.nameDocument,
      this.document,
      required this.idDocument,
      this.selected = false})
      : progress = BehaviorSubject<double>();
}
