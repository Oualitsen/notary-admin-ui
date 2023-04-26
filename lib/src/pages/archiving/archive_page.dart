import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lazy_paginated_data_table/lazy_paginated_data_table.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/archiving/files_archived_table_widget.dart';
import 'package:notary_admin/src/pages/search/date_range_picker_widget.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/reused_widgets.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:rxdart/subjects.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends BasicState<ArchivePage> with WidgetUtilsMixin {
  //services
  final archiveService = GetIt.instance.get<FilesArchiveService>();
  //stream
  final _selectedYearStream = BehaviorSubject.seeded(DateTime.now().year);
  //key
  final listViewKey = GlobalKey();
  final tableKey = GlobalKey<LazyPaginatedDataTableState>();

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.archive),
          actions: [
            StreamBuilder(
              stream: _selectedYearStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                var year = snapshot.data!;
                var currentYear = DateTime.now().year;
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Tooltip(
                        message: lang.previousYear,
                        child: IconButton(
                          onPressed: year > (currentYear - 100)
                              ? () {
                                  _selectedYearStream.add((year - 1));
                                }
                              : null,
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      Tooltip(
                        message: lang.selectYear,
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(10),
                          child: InkWell(
                            child: Text("${snapshot.data}"),
                            onTap: yearPicker,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: lang.nextYear,
                        child: IconButton(
                          onPressed: year < currentYear
                              ? () {
                                  _selectedYearStream.add((year + 1));
                                }
                              : null,
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: 5),
            TextButton(
              onPressed: (() => push<FilesArchive?>(
                    context,
                    AddArchivePage(
                      initDate: DateTime(_selectedYearStream.value),
                    ),
                  ).listen((event) {
                    if (event != null) {
                      tableKey.currentState?.refreshPage();
                    }
                  })),
              child: Text(
                lang.addArchive.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                ),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
        body: StreamBuilder<int>(
            stream: _selectedYearStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              var startDate = DateTime(snapshot.data!, 1, 1);
              var endDate = DateTime(startDate.year, 12, 31);
              tableKey.currentState?.refreshPage();
              return FilesArchiveTableWidget(
                tableKey: tableKey,
                initialRange: DateRange(startDate: startDate, endDate: endDate),
              );
            }),
      ),
    );
  }

  yearPicker() async {
    ReusedWidgets.showDialog2(
      context,
      label: lang.selectYear,
      width: 300,
      height: 300,
      content: YearPicker(
        firstDate: DateTime(DateTime.now().year - 100, 1),
        lastDate: DateTime(DateTime.now().year),
        initialDate: DateTime(_selectedYearStream.value),
        selectedDate: DateTime(_selectedYearStream.value),
        onChanged: (DateTime dateTime) {
          _selectedYearStream.add(dateTime.year);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
