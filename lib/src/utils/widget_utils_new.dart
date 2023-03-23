import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/customer/customer_detail_page.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';

mixin WidgetUtilsFile {
  uploadFiles(BuildContext context, Files finalFiles,
      List<PathsDocuments> _pathDocumentsStream) async {
    final serviceUploadDocument = GetIt.instance.get<UploadService>();
    try {
      if (_pathDocumentsStream.isNotEmpty) {
        if (kIsWeb) {
          for (var pathDoc in _pathDocumentsStream) {
            if (pathDoc.selected) {
              await serviceUploadDocument.upload(
                "/admin/files/upload/${finalFiles.id}/${finalFiles.specification.id}/${pathDoc.idDocument}",
                pathDoc.document!,
                pathDoc.nameDocument!,
                callBack: (percentage) {
                  pathDoc.progress.add(percentage);
                },
              );
            }
          }
        } else {
          for (var pathDoc in _pathDocumentsStream) {
            if (pathDoc.selected) {
              await serviceUploadDocument.uploadFileDynamic(
                "/admin/files/upload/${finalFiles.id}/${finalFiles.specification.id}/${pathDoc.idDocument}",
                pathDoc.path!,
                callBack: (percentage) {
                  pathDoc.progress.add(percentage);
                },
              );
            }
          }
        }
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {}
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

class ListCustomers extends StatelessWidget {
  final List<Customer> listCustomers;
  final double? width;

  const ListCustomers({super.key, required this.listCustomers, this.width});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return SizedBox(
      height: 200,
      width: width,
      child: listCustomers.isNotEmpty
          ? ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: listCustomers.length,
              itemBuilder: (BuildContext context, int index) {
                var customer = listCustomers[index];
                return ListTile(
                  leading: CircleAvatar(
                      child: Text(
                          "${customer.lastName[0].toUpperCase()}${customer.firstName[0].toUpperCase()}")),
                  title: Text("${customer.lastName} ${customer.firstName}"),
                  subtitle:
                      Text("${lang.idCard} : ${customer.idCard.idCardId}"),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailsPage(customer: customer),
                    ),
                  ),
                );
              })
          : Padding(
              padding: const EdgeInsets.all(5),
              child: Text(lang.noCustomer.toUpperCase()),
            ),
    );
  }
}

class widgetListFiles extends StatelessWidget {
  final List<String>? documentsUpload;
  final double? width;
  final Files? file;
  final BehaviorSubject<List<PathsDocuments>>? _pathDocumentsStream;
  final BehaviorSubject<List<PathsDocuments>>? _pathDocumentsUpdateStream;
  final BehaviorSubject<bool>? _allUploadedStream;
  final BehaviorSubject<FilesSpec>? _filesSpecStream;

  widgetListFiles(
      {super.key,
      this.file,
      BehaviorSubject<List<PathsDocuments>>? pathDocumentsStream,
      BehaviorSubject<List<PathsDocuments>>? pathDocumentsUpdateStream,
      BehaviorSubject<bool>? allUploadedStream,
      BehaviorSubject<FilesSpec>? filesSpecStream,
      this.documentsUpload,
      this.width})
      : _allUploadedStream = allUploadedStream,
        _pathDocumentsUpdateStream = pathDocumentsUpdateStream,
        _pathDocumentsStream = pathDocumentsStream,
        _filesSpecStream = filesSpecStream;
  void allUploaded(
    bool update,
  ) {
    if (update == false) {
      for (var pathDoc in _pathDocumentsStream!.value) {
        if (!pathDoc.selected) {
          _allUploadedStream!.add(false);
          return;
        }
      }
      _allUploadedStream!.add(true);
    } else {
      _allUploadedStream!.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);

    return documentsUpload == null
        ? ListView.builder(
            itemCount: _pathDocumentsStream!.value.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text("${(index + 1)}"),
                ),
                title: file == null
                    ? Text(
                        " ${_pathDocumentsStream!.value[index].nameDocument} ")
                    : Text(
                        " ${file!.specification.documents[index].name} ",
                        maxLines: 50,
                      ),
                subtitle: Wrap(
                  children: [
                    _pathDocumentsStream!.value[index].selected == true
                        ? Text(
                            _pathDocumentsStream!
                                .value[index].namePickedDocument!,
                            softWrap: true,
                          )
                        : file == null
                            ? Text(lang.noUpload)
                            : SizedBox.shrink(),
                    StreamBuilder<double>(
                        stream: _pathDocumentsStream!.value[index].progress,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          return Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
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
                    file == null &&
                            _pathDocumentsStream!.value[index].selected == true
                        ? OutlinedButton(
                            onPressed: (() => _delete(context, index)),
                            child: Text(lang.delete))
                        : SizedBox.shrink(),
                    ElevatedButton(
                      child: file == null
                          ? Text(lang.uploadFile)
                          : Text(lang.remplaceFile),
                      onPressed: () async {
                        var picked = await FilePicker.platform.pickFiles();
                        if (picked != null) {
                          var pickedPath = null;

                          if (!kIsWeb) {
                            pickedPath = picked.files.first.path;
                          }
                          final pickedBytes = picked.files.first.bytes;
                          final namePickedFile = picked.files.first.name;

                          if (file != null &&
                              (pickedBytes != null || pickedPath != null)) {
                            var list = _pathDocumentsUpdateStream!.value;
                            if (_pathDocumentsUpdateStream!.value
                                .asMap()
                                .containsKey(index)) {
                              list.removeAt(index);
                              list.insert(
                                index,
                                addPathDocument(
                                  file!.specification.documents[index].id,
                                  pickedBytes,
                                  true,
                                  namePickedFile,
                                  file!.specification.documents[index].name,
                                  pickedPath,
                                ),
                              );
                            }
                            _pathDocumentsUpdateStream?.add(list);
                            _pathDocumentsStream!.add(list);
                            allUploaded(true);
                          } else {
                            var list = _pathDocumentsStream!.value;
                            list.removeAt(index);
                            list.insert(
                                index,
                                addPathDocument(
                                  _filesSpecStream!.value.documents[index].id,
                                  pickedBytes,
                                  true,
                                  namePickedFile,
                                  _filesSpecStream!.value.documents[index].name,
                                  pickedPath,
                                ));
                            _pathDocumentsStream!.add(list);
                            allUploaded(false);
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            })
        : SizedBox(
            height: 200,
            width: width,
            child: documentsUpload!.isNotEmpty
                ? ListView.builder(
                    itemCount: documentsUpload!.length,
                    itemBuilder: (context, int index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.file_download,
                              color: Color.fromARGB(158, 135, 150, 6),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text("${documentsUpload![index]}"),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      );
                    })
                : Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(lang.noDocument.toUpperCase()),
                  ),
          );
  }

  _delete(BuildContext context, int index) {
    var lang = getLang(context);
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
                      var list = _pathDocumentsStream!.value;
                      list.removeAt(index);
                      list.insert(
                          index,
                          addPathDocument(
                            _filesSpecStream!.value.documents[index].id,
                            null,
                            false,
                            '',
                            _filesSpecStream!.value.documents[index].name,
                            null,
                          ));
                      _pathDocumentsStream!.add(list);
                      Navigator.of(context).pop(true);
                      allUploaded(false);
                    },
                    child: Text(lang.confirm.toUpperCase())),
              ],
            ));
  }
}
