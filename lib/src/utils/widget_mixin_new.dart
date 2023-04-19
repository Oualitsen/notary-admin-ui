import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/customer/customer_detail_page.dart';
import 'package:notary_admin/src/pages/search/search_filter_table_widget.dart';
import 'package:notary_admin/src/pages/templates/upload_template.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_model/model/customer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class WidgetMixin {
  static Future<T?> showDialog2<T>(BuildContext context,
      {required String label,
      required Widget content,
      List<Widget>? actions,
      double? width,
      double? height}) {
    var lang = getLang(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Container(
                height: 40,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(label),
                    ),
                    Tooltip(
                      message: lang.cancel,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          child: Icon(Icons.cancel),
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                height: height != null ? height : 600,
                width: width != null ? width : 600,
                child: content,
              ),
              actions: actions,
            ));
  }

  static uploadFiles(BuildContext context, String filesId,
      List<DocumentUploadInfos> _pathDocuments) async {
    final serviceUploadDocument = GetIt.instance.get<UploadService>();
    var uri = "/admin/files/upload/${filesId}/";
    try {
      if (_pathDocuments.isNotEmpty) {
        if (kIsWeb) {
          for (var pathDoc in _pathDocuments) {
            if (pathDoc.selected) {
              await serviceUploadDocument.upload(
                uri + "${pathDoc.idParts}/${pathDoc.idDocument}",
                pathDoc.document!,
                pathDoc.namePickedDocument!,
                callBack: (percentage) {
                  pathDoc.progress.add(percentage);
                },
              );
            }
          }
        } else {
          for (var pathDoc in _pathDocuments) {
            if (pathDoc.selected) {
              await serviceUploadDocument.uploadFileDynamic(
                uri + "${pathDoc.idParts}/${pathDoc.idDocument}",
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

  static Widget ListCustomers(BuildContext context,
      {required List<Customer> listCustomers, double? width}) {
    var lang = getLang(context);

    return SizedBox(
        width: width,
        child: Column(
          children: listCustomers.map((customer) {
            return ListTile(
              leading: CircleAvatar(
                  child: Text(
                      "${customer.lastName[0].toUpperCase()}${customer.firstName[0].toUpperCase()}")),
              title: Text("${customer.lastName} ${customer.firstName}"),
              subtitle: Text("${lang.idCard} : ${customer.idCard.idCardId}"),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetailsPage(customer: customer),
                ),
              ),
            );
          }).toList(),
        ));
  }

  static uploadAdditionalData(BuildContext context, String filesId,
      List<UploadData> additionalFiles) async {
    final serviceUploadDocument = GetIt.instance.get<UploadService>();
    var uri = "/admin/files/upload/additional/${filesId}";
    try {
      if (additionalFiles.isNotEmpty) {
        if (kIsWeb) {
          for (var data in additionalFiles) {
            await serviceUploadDocument.upload(
              uri,
              data.data!,
              data.name,
              callBack: (percentage) {
                data.progress.add(percentage);
              },
            );
          }
        } else {
          for (var data in additionalFiles) {
            await serviceUploadDocument.uploadFileDynamic(
              uri,
              data.path!,
              callBack: (percentage) {
                data.progress.add(percentage);
              },
            );
          }
        }
      }
    } catch (error, stackTrace) {
      print(stackTrace);
      showServerError(context, error: error);
      throw error;
    } finally {}
  }

  static SearchParams? getParams(SearchParams2 searchParam2) {
    var startDate = -1;
    var endDate = -1;
    if (searchParam2.range.startDate != null) {
      startDate = searchParam2.range.startDate!.millisecondsSinceEpoch;
    }
    if (searchParam2.range.endDate != null) {
      endDate = searchParam2.range.endDate!.millisecondsSinceEpoch;
    }
    var searchParams = SearchParams(
      number: searchParam2.number,
      fileSpecName: searchParam2.fileSpecName,
      customerIds: searchParam2.customers.map((e) => e.id).join(","),
      startDate: startDate,
      endDate: endDate,
    );
    if (searchParams.customerIds.isNotEmpty ||
        searchParams.number.isNotEmpty ||
        searchParams.fileSpecName.isNotEmpty ||
        searchParams.startDate != -1 ||
        searchParams.endDate != -1) {
      return searchParams;
    }
    return null;
  }

  static Future<bool> confirmDelete(BuildContext context) async {
    var lang = getLang(context);
    return await showAlertDialog(
        context: context,
        title: lang.confirm,
        message: lang.confirmDelete,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(lang.cancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(lang.ok.toUpperCase()),
          )
        ]);
  }

  static download(
    BuildContext context, {
    required String uri,
    required String name,
    Uint8List? myBytes = null,
    String? token = null,
  }) async {
    Map<String, String> headers = <String, String>{};
    var bytes = myBytes;

    if (kIsWeb) {
      if (bytes == null) {
        bytes = await getBytes(token, uri);
      }
      final content = base64Encode(bytes);
      html.AnchorElement(
          href:
              "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", name)
        ..click();
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final baseStorage = await getExternalStorageDirectory();
        await FlutterDownloader.enqueue(
            openFileFromNotification: true,
            url: uri,
            headers: headers,
            savedDir: baseStorage!.path);
      } else {
        var lang = getLang(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(lang.permissionDenied),
            content: Text(lang.permissionText),
            actions: [
              TextButton(
                child: Text(lang.openSettings),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
  }

  static Future<Uint8List> getBytes(String? token, String uri) async {
    try {
      Map<String, String> headers = <String, String>{};
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
      final response = await http.get(
        Uri.parse("$uri"),
        headers: headers,
      );
      return response.bodyBytes;
    } catch (error, stacktrace) {
      print("@@@ error: $stacktrace");
      throw error;
    }
  }
}
