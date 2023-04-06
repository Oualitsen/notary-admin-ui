import 'package:flutter/material.dart';

import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/subjects.dart';

class UploadPartsDocumentsWidget extends StatefulWidget {
  final FilesSpec filesSpec;
  final Function(List<PathsDocuments> pathDocumentList) onNext;
  const UploadPartsDocumentsWidget(
      {super.key, required this.filesSpec, required this.onNext});
  @override
  State<UploadPartsDocumentsWidget> createState() =>
      _UploadPartsDocumentsWidgetState();
}

class _UploadPartsDocumentsWidgetState
    extends BasicState<UploadPartsDocumentsWidget> with WidgetUtilsMixin {
  final uploadsStream = BehaviorSubject<List<PartsDocument>>();
  bool initialize = false;
  void init() {
    if (initialize) return;
    initialize = true;
    var list = widget.filesSpec.partsSpecs
        .map(
          (element) => PartsDocument(
            maxUpload: element.documentSpec.length,
            uploaded: 0,
            pathsDocuments: element.documentSpec
                .map((e) => PathsDocuments(
                      idParts: element.id,
                      idDocument: e.id,
                      document: null,
                      selected: false,
                      namePickedDocument: null,
                      path: null,
                      nameDocument: e.name,
                    ))
                .toList(),
          ),
        )
        .toList();
    uploadsStream.add(list);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return SingleChildScrollView(
      child: Container(
        height: 200,
        child: ListView.builder(
          itemCount: widget.filesSpec.partsSpecs.length,
          itemBuilder: (context, index) {
            return StreamBuilder<List<PartsDocument>>(
                stream: uploadsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox.shrink();
                  return ListTile(
                      leading: CircleAvatar(child: Text("${(index + 1)}")),
                      trailing: Text(
                          "${snapshot.data![index].uploaded} / ${snapshot.data![index].maxUpload}"),
                      title: Container(
                        alignment: Alignment.centerLeft,
                        child:
                            Text("${widget.filesSpec.partsSpecs[index].name}"),
                      ),
                      onTap: (() => push<List<PathsDocuments>>(
                            context,
                            UploadDocumentsWidget(
                              pathDocuments:
                                  snapshot.data![index].pathsDocuments,
                            ),
                          ).listen((pathDocuments) {
                            var list = uploadsStream.value;
                            list.insert(
                                index,
                                PartsDocument(
                                    maxUpload: list[index].maxUpload,
                                    uploaded: pathDocuments
                                        .where((element) => element.selected)
                                        .toList()
                                        .length,
                                    pathsDocuments: pathDocuments));
                            list.removeAt((index + 1));
                            uploadsStream.add(list);
                            change();
                          })));
                });
          },
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  void change() {
    var list = <PathsDocuments>[];
    uploadsStream.value
        .map((e) => e.pathsDocuments.map((e) => list.add(e)).toList())
        .toList();

    widget.onNext(list);
  }
}

class PartsDocument {
  final int maxUpload;
  final int uploaded;
  final List<PathsDocuments> pathsDocuments;

  PartsDocument({
    required this.maxUpload,
    required this.uploaded,
    required this.pathsDocuments,
  });
}
