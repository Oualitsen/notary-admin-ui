import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class UploadDocumentsWidget extends StatefulWidget {
  final List<DocumentUploadInfos> pathDocuments;
  UploadDocumentsWidget({
    super.key,
    required this.pathDocuments,
  });

  @override
  State<UploadDocumentsWidget> createState() => _UploadDocumentsWidgetState();
}

class _UploadDocumentsWidgetState extends BasicState<UploadDocumentsWidget>
    with WidgetUtilsMixin {
  final pathDocumentsStream = BehaviorSubject.seeded(<DocumentUploadInfos>[]);
  bool isAllUploaded = false;
  bool initialized = false;

  void init() {
    if (initialized) return;
    initialized = true;

    var list = widget.pathDocuments;

    pathDocumentsStream.add(list);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      appBar: AppBar(title: Text("${lang.listDocumentsFileSpec}")),
      body: StreamBuilder<List<DocumentUploadInfos>>(
          stream: pathDocumentsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            return Column(
              children: [
                Expanded(
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
                                  stream:
                                      pathDocumentsStream.value[index].progress,
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
                                      child: Text(lang.delete.toUpperCase()),
                                    )
                                  : SizedBox.shrink(),
                              ElevatedButton(
                                child: Text(lang.uploadFile.toUpperCase()),
                                onPressed: () => pickFile(index),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: getButtons(onSave: onSave),
                )
              ],
            );
          }),
    );
  }

  _delete(int index) {
    ReusedWidgets.confirmDelete(context)
        .asStream()
        .where((event) => event == true)
        .listen(
      (_) {
        var pathDoc = DocumentUploadInfos(
          idParts: widget.pathDocuments[index].idParts,
          idDocument: widget.pathDocuments[index].idDocument,
          document: null,
          selected: false,
          namePickedDocument: null,
          nameDocument: widget.pathDocuments[index].nameDocument,
          path: null,
        );
        var list = pathDocumentsStream.value;
        list.removeAt(index);
        list.insert(index, pathDoc);
        pathDocumentsStream.add(list);
      },
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
        var pathDoc = DocumentUploadInfos(
          idParts: widget.pathDocuments[index].idParts,
          idDocument: widget.pathDocuments[index].idDocument,
          document: pickedBytes,
          selected: true,
          namePickedDocument: namePickedFile,
          nameDocument: widget.pathDocuments[index].nameDocument,
          path: pickedPath,
        );
        var list = pathDocumentsStream.value;
        list.removeAt(index);
        list.insert(index, pathDoc);
        pathDocumentsStream.add(list);
      }
    }
  }

  onSave() {
    Navigator.of(context).pop(
      pathDocumentsStream.value,
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class DocumentUploadInfos {
  final String idParts;
  final String idDocument;
  final String nameDocument;
  final String? namePickedDocument;
  final Uint8List? document;
  final bool selected;
  final String? path;
  final BehaviorSubject<double> progress;

  DocumentUploadInfos(
      {this.namePickedDocument,
      required this.idParts,
      required this.nameDocument,
      this.document,
      required this.idDocument,
      this.selected = false,
      required this.path})
      : progress = BehaviorSubject<double>();
}
