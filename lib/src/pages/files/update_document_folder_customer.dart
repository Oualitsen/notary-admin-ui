import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/utils/widget_utils_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files.dart';
import 'package:rxdart/rxdart.dart';
import '../../services/files/files_service.dart';
import '../../services/upload_service.dart';
import 'list_files_customer.dart';

class UpdateDocumentFolderCustomer extends StatefulWidget {
  final Files file;

  const UpdateDocumentFolderCustomer({
    super.key,
    required this.file,
  });
  @override
  State<UpdateDocumentFolderCustomer> createState() =>
      _UpdateDocumentFolderCustomerState();
}

class _UpdateDocumentFolderCustomerState
    extends BasicState<UpdateDocumentFolderCustomer>
    with WidgetUtilsMixin, WidgetUtilsFile {
  //service
  final serviceUploadDocument = GetIt.instance.get<UploadService>();
  final serviceFiles = GetIt.instance.get<FilesService>();
  //stream
  final _pathDocumentsStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final _pathDocumentsUpdateStream = BehaviorSubject.seeded(<PathsDocuments>[]);
  final allUploadedStream = BehaviorSubject.seeded(false);
  //var
  late Files files;

  @override
  initState() {
    files = widget.file;

    _pathDocumentsStream.add(widget.file.specification.documents
        .map(
          (e) => PathsDocuments(
            idDocument: e.id,
            document: null,
            selected: true,
            namePickedDocument: '',
            nameDocument: e.name,
            path: null,
          ),
        )
        .toList());
    _pathDocumentsUpdateStream.add(widget.file.specification.documents
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
        body: StreamBuilder<List<PathsDocuments>>(
            stream: _pathDocumentsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return SizedBox.shrink();
              }
              return widgetListFiles(
                  file: files,
                  pathDocumentsStream: _pathDocumentsStream,
                  pathDocumentsUpdateStream: _pathDocumentsUpdateStream,
                  allUploadedStream: allUploadedStream);
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

  save() async {
    try {
      progressSubject.add(true);
      if (_pathDocumentsUpdateStream.value.isNotEmpty) {
        await uploadFiles(context, files, _pathDocumentsUpdateStream.value);

        await showSnackBar2(context, lang.savedSuccessfully);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ListFilesCustomer()));
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {
      progressSubject.add(false);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
