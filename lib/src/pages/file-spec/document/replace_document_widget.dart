import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/docs_management/document_manager.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

class ReplaceDocumentWidget extends StatefulWidget {
  final List<DocumentUploadInfos> pathDocumentsList;
  final String filesId;
  const ReplaceDocumentWidget({
    super.key,
    required this.filesId,
    required this.pathDocumentsList,
  });

  @override
  State<ReplaceDocumentWidget> createState() => _ReplaceDocumentWidgetState();
}

class _ReplaceDocumentWidgetState extends BasicState<ReplaceDocumentWidget>
    with WidgetUtilsMixin {
  final updateDocumentsStream = BehaviorSubject.seeded(<UpdateDocuments>[]);
  final allUploadedStream = BehaviorSubject.seeded(false);
  bool initialized = false;
  final filesService = GetIt.instance.get<FilesService>();

  void init() async {
    if (initialized) return;
    initialized = true;
    var pathDocumentsList = widget.pathDocumentsList
        .map((e) => UpdateDocuments(pathDocument: e))
        .toList();
    updateDocumentsStream.add(pathDocumentsList);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      appBar: AppBar(
        title: Text("${lang.listDocumentsFileSpec}"),
      ),
      body: Column(
        children: [
          StreamBuilder<List<UpdateDocuments>>(
            stream: updateDocumentsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text("${(index + 1)}")),
                      title: Text(
                        " ${snapshot.data![index].pathDocument.nameDocument} ",
                        softWrap: true,
                      ),
                      subtitle: Wrap(
                        children: [
                          snapshot.data![index].updated == true
                              ? Text(
                                  updateDocumentsStream.value[index]
                                      .pathDocument.namePickedDocument!,
                                  softWrap: true,
                                )
                              : SizedBox.shrink(),
                          StreamBuilder<double>(
                              stream:
                                  snapshot.data![index].pathDocument.progress,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox.shrink();
                                }
                                return Wrap(
                                  children: [
                                    SizedBox(width: 5),
                                    Text("${snapshot.data} %"),
                                  ],
                                );
                              }),
                        ],
                      ),
                      trailing: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 10,
                        children: [
                          snapshot.data![index].pathDocument.selected
                              ? OutlinedButton(
                                  child: Text(lang.remplaceFile.toUpperCase()),
                                  onPressed: () => pickFile(index),
                                )
                              : ElevatedButton(
                                  child: Text(lang.uploadFile.toUpperCase()),
                                  onPressed: () => pickFile(index),
                                ),
                        ],
                      ),
                      onTap: () async {
                        if (widget
                                .pathDocumentsList[index].namePickedDocument !=
                            null) {
                          try {
                            var res = await filesService.loadFileDocuments(
                              widget.filesId,
                              snapshot.data![index].pathDocument.idParts,
                              snapshot.data![index].pathDocument.idDocument,
                            );
                            push(
                              context,
                              DocumentManagerPage(
                                name:
                                    "${snapshot.data![index].pathDocument.namePickedDocument}",
                                id: res,
                              ),
                            );
                          } catch (error, stacktrace) {
                            print(stacktrace);
                            showServerError(context, error: error);
                            throw error;
                          }
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              StreamBuilder<bool>(
                stream: allUploadedStream,
                initialData: allUploadedStream.value,
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return SizedBox.shrink();
                  }
                  return ElevatedButton(
                      onPressed: snapshot.data! == true ? submitFiles : null,
                      child: Text(lang.submit.toUpperCase()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  pickFile(int index) async {
    var picked = await FilePicker.platform.pickFiles();
    if (picked != null) {
      var pickedPath = null;
      final pickedBytes = picked.files.first.bytes;
      final namePickedFile = picked.files.first.name;
      if (!kIsWeb) {
        pickedPath = picked.files.first.path;
      }

      if (pickedBytes != null || pickedPath != null) {
        var list = updateDocumentsStream.value;
        if (updateDocumentsStream.value.asMap().containsKey(index)) {
          var element = updateDocumentsStream.value[index].pathDocument;
          var pathDoc = DocumentUploadInfos(
            idParts: element.idParts,
            idDocument: element.idDocument,
            document: pickedBytes,
            selected: true,
            namePickedDocument: namePickedFile,
            nameDocument: element.nameDocument,
            path: pickedPath,
          );
          var updatePathDoc = UpdateDocuments(
            pathDocument: pathDoc,
            updated: true,
          );
          list.removeAt(index);
          list.insert(index, updatePathDoc);
        }
        updateDocumentsStream.add(list);
        allUploadedStream.add(true);
      }
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void submitFiles() async {
    progressSubject.add(true);
    try {
      if (updateDocumentsStream.value.isNotEmpty) {
        await ReusedWidgets.uploadFiles(
          context,
          widget.filesId,
          updateDocumentsStream.value
              .where((element) => element.updated)
              .map((e) => e.pathDocument)
              .toList(),
        );
       await showSnackBar2(context, lang.savedSuccessfully);
        Navigator.of(context).pop();
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

class UpdateDocuments {
  final DocumentUploadInfos pathDocument;
  final bool updated;

  UpdateDocuments({required this.pathDocument, this.updated = false});
}
