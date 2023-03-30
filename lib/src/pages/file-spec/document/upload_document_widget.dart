import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/parts_spec.dart';
import 'package:rxdart/rxdart.dart';

class UploadDocumentsWidget extends StatefulWidget {
  final PartsSpec partsSpec;
  final double width;
  final double height;
  final Function(List<PathsDocuments> pathDocuments) onNext;
  UploadDocumentsWidget({
    super.key,
    this.height = 200,
    this.width = double.infinity,
    required this.onNext,
    required this.partsSpec,
  });

  @override
  State<UploadDocumentsWidget> createState() => _UploadDocumentsWidgetState();
}

class _UploadDocumentsWidgetState extends BasicState<UploadDocumentsWidget> {
  final pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  bool isAllUploaded = false;
  bool initialized = false;

  void init() {
    if (initialized) return;
    initialized = true;

    var list = widget.partsSpec.documentSpec
        .map(
          (e) => PathsDocuments(
            idDocument: e.id,
            document: null,
            selected: false,
            namePickedDocument: null,
            path: null,
            nameDocument: e.name,
          ),
        )
        .toList();
    pathDocumentsStream.add(list);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return StreamBuilder<List<PathsDocuments>>(
        stream: pathDocumentsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return Container(
            height: widget.height,
            width: widget.width,
            child: ListView.builder(
                itemCount: pathDocumentsStream.value.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text("${(index + 1)}")),
                    title: Text(
                      " ${pathDocumentsStream.value[index].nameDocument} ",
                      maxLines: 50,
                    ),
                    subtitle: Wrap(
                      children: [
                        pathDocumentsStream.value[index].selected == true
                            ? Text(
                                pathDocumentsStream
                                    .value[index].namePickedDocument!,
                                softWrap: true,
                              )
                            : Text(lang.noUpload),
                        StreamBuilder<double>(
                            stream: pathDocumentsStream.value[index].progress,
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
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.end,
                      spacing: 10,
                      children: [
                        pathDocumentsStream.value[index].selected == true
                            ? OutlinedButton(
                                onPressed: () => _delete(index),
                                child: Text(lang.delete),
                              )
                            : SizedBox.shrink(),
                        ElevatedButton(
                          child: Text(lang.uploadFile),
                          onPressed: () => pickFile(index),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  _delete(int index) {
    showDialog(
        context: context,
        builder: (BuildContext) => AlertDialog(
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
                      var pathDoc = PathsDocuments(
                        idDocument: widget.partsSpec.documentSpec[index].id,
                        document: null,
                        selected: false,
                        namePickedDocument: "",
                        nameDocument: widget.partsSpec.documentSpec[index].name,
                        path: null,
                      );
                      var list = pathDocumentsStream.value;
                      list.removeAt(index);
                      list.insert(index, pathDoc);
                      pathDocumentsStream.add(list);
                      allUploaded();

                      Navigator.of(context).pop(true);
                    },
                    child: Text(lang.confirm.toUpperCase())),
              ],
            ));
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
        var pathDoc = PathsDocuments(
          idDocument: widget.partsSpec.documentSpec[index].id,
          document: pickedBytes,
          selected: true,
          namePickedDocument: namePickedFile,
          nameDocument: widget.partsSpec.documentSpec[index].name,
          path: pickedPath,
        );
        var list = pathDocumentsStream.value;
        list.removeAt(index);
        list.insert(index, pathDoc);
        pathDocumentsStream.add(list);
        allUploaded();
      }
    }
  }

  void allUploaded() {
    for (var pathDoc in pathDocumentsStream.value) {
      if (!pathDoc.selected) {
        isAllUploaded = false;
        widget.onNext([]);
        return;
      }
    }
    isAllUploaded = true;
    widget.onNext(pathDocumentsStream.value);
  }

  List<ChangeNotifier> get notifiers => [];
  List<Subject> get subjects => [];
}

class PathsDocuments {
  final String idDocument;
  final String nameDocument;
  final String? namePickedDocument;
  final Uint8List? document;
  final bool selected;
  final String? path;
  final BehaviorSubject<double> progress;

  PathsDocuments(
      {this.namePickedDocument,
      required this.nameDocument,
      this.document,
      required this.idDocument,
      this.selected = false,
      required this.path})
      : progress = BehaviorSubject<double>();
}
