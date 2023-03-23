import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:intl/intl.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';

import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ArchivedFilesList extends StatefulWidget {
  final int startDate;
  final int endDate;
  const ArchivedFilesList(
      {super.key, required this.startDate, required this.endDate});

  @override
  State<ArchivedFilesList> createState() => _ArchivedFilesListState();
}

class _ArchivedFilesListState extends BasicState<ArchivedFilesList>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<FilesArchiveService>();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text("${lang.monthName(widget.startDate)}"),
          actions: [
            ElevatedButton(
              onPressed:
                  widget.startDate < DateTime.now().millisecondsSinceEpoch
                      ? () {
                          push(
                              context,
                              AddArchivePage(
                                initDate: DateTime.fromMillisecondsSinceEpoch(
                                    widget.startDate),
                              ));
                        }
                      : null,
              child: Text(lang.addFiles),
            )
          ],
        ),
        body: InfiniteScrollListView(
            elementBuilder: ((context, element, index, animation) {
              return ListTile(
                title: Text(element.number),
                subtitle: Text(lang.formatDate(element.archvingDate)),
              );
            }),
            refreshable: true,
            pageLoader: getArchives),
      ),
    );
  }

  Future<List<FilesArchive>> getArchives(int index) {
    if (index == 0) {
      var result =
          service.getFilesArchiveByDate(widget.startDate, widget.endDate);

      return result;
    } else {
      return Future.value([]);
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
