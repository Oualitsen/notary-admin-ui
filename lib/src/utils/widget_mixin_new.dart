import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/customer/customer_detail_page.dart';
import 'package:notary_admin/src/pages/templates/upload_template.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/pages/file-spec/document/upload_document_widget.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_spec.dart';

class WidgetMixin {
  static Future<T?> showDialog2<T>(
    BuildContext context, {
    required String label,
    required Widget content,
    List<Widget>? actions,
  }) {
    var lang = getLang(context);
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Container(
                height: 50,
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
              content: content,
              actions: actions,
            ));
  }

  static uploadFiles(BuildContext context, Files finalFiles,
      List<PathsDocuments> _pathDocuments) async {
    final serviceUploadDocument = GetIt.instance.get<UploadService>();
    var uri =
        "/admin/files/upload/${finalFiles.id}/${finalFiles.specification.id}/";
    try {
      if (_pathDocuments.isNotEmpty) {
        if (kIsWeb) {
          for (var pathDoc in _pathDocuments) {
            if (pathDoc.selected) {
              await serviceUploadDocument.upload(
                uri + "${pathDoc.idDocument}",
                pathDoc.document!,
                pathDoc.nameDocument,
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
                uri + "${pathDoc.idDocument}",
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

  static uploadAdditionalData(BuildContext context, Files files,
      List<UploadData> additionalFiles) async {
    final serviceUploadDocument = GetIt.instance.get<UploadService>();
    var uri = "/admin/files/upload/additional/${files.id}";
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
}
