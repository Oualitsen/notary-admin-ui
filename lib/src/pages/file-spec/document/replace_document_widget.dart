import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/subjects.dart';

class ReplaceDocumentWidget extends StatefulWidget {
  final Files files;
  final double width;
  final double height;
  const ReplaceDocumentWidget({
    super.key,
    required this.files,
    this.width = 400,
    this.height = 400,
  });

  @override
  State<ReplaceDocumentWidget> createState() => _ReplaceDocumentWidgetState();
}

class _ReplaceDocumentWidgetState extends BasicState<ReplaceDocumentWidget>
    with WidgetUtilsMixin {
  final updateDocumentsStream = BehaviorSubject.seeded(<UpdateDocuments>[]);
  final allUploadedStream = BehaviorSubject.seeded(false);
  bool initialized = false;

  void init() {
    if (initialized) return;
    initialized = true;
    var pathDocumentsList =
        widget.files.specification.partsSpecs[0].documentSpec.map((e) {
      return UpdateDocuments(
          pathDocument: PathsDocuments(
        idDocument: e.id,
        document: null,
        selected: true,
        namePickedDocument: null,
        nameDocument: e.name,
        path: null,
      ));
    }).toList();
    updateDocumentsStream.add(pathDocumentsList);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: widget.width,
            height: widget.height - 50,
            child: StreamBuilder<List<UpdateDocuments>>(
              stream: updateDocumentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text("${(index + 1)}")),
                      title: Text(
                        " ${widget.files.specification.partsSpecs[0].documentSpec[index].name} ",
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
                          ElevatedButton(
                            child: Text(lang.remplaceFile),
                            onPressed: () => pickFile(index),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
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
                      child: Text(lang.submit));
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
          var pathDoc = PathsDocuments(
            idDocument:
                widget.files.specification.partsSpecs[0].documentSpec[index].id,
            document: pickedBytes,
            selected: true,
            namePickedDocument: namePickedFile,
            nameDocument: widget
                .files.specification.partsSpecs[0].documentSpec[index].name,
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
    try {
      progressSubject.add(true);
      if (updateDocumentsStream.value.isNotEmpty) {
        await WidgetMixin.uploadFiles(
          context,
          widget.files,
          updateDocumentsStream.value
              .where((element) => element.updated)
              .map((e) => e.pathDocument)
              .toList(),
        );
        Navigator.pop(context);
        await showSnackBar2(context, lang.savedSuccessfully);
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
  final PathsDocuments pathDocument;
  final bool updated;

  UpdateDocuments({required this.pathDocument, this.updated = false});
}
