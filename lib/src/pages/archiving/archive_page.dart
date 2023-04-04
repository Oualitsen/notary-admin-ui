import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/archiving/files_archived_table_widget.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:rxdart/subjects.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends BasicState<ArchivePage> with WidgetUtilsMixin {
  final archiveService = GetIt.instance.get<FilesArchiveService>();
  final _selectedYearStream = BehaviorSubject.seeded(DateTime.now().year);
  final countStream = BehaviorSubject.seeded(<int>[]);
  final listViewKey = GlobalKey();
  late List<String> monthList;
  bool initialize = false;
  init() {
    if (initialize) return;
    initialize = true;
    monthList = [
      lang.january,
      lang.february,
      lang.march,
      lang.april,
      lang.may,
      lang.june,
      lang.july,
      lang.august,
      lang.september,
      lang.october,
      lang.novermber,
      lang.december
    ];
    var list = monthList.map((e) => 0).toList();
    countStream.add(list);
  }

  @override
  Widget build(BuildContext context) {
    init();
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
            ElevatedButton(
              onPressed: (() => push(context, AddArchivePage())),
              child: Text(lang.addArchive),
            )
          ],
        ),
        body: StreamBuilder<int>(
            stream: _selectedYearStream,
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  key: listViewKey,
                  itemCount: DateTime.monthsPerYear,
                  itemBuilder: (context, index) {
                    var startDate = DateTime(snapshot.data!, (index + 1))
                        .millisecondsSinceEpoch;
                    var endDate =
                        DateTime(snapshot.data!, (index + 2), 0, 23, 59, 59)
                            .millisecondsSinceEpoch;
                    var title = "${monthList[index]}";
                    getCount(index, startDate, endDate);
                    return StreamBuilder<List<int>>(
                        stream: countStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          }
                          return ListTile(
                            leading: Icon(Icons.folder),
                            title: Text("${title} (${snapshot.data![index]})"),
                            onTap: () {
                              push(
                                context,
                                FilesArchiveTableWidget(
                                  title:
                                      "${title} ${_selectedYearStream.value}",
                                  startDate: startDate,
                                  endDate: endDate,
                                ),
                              );
                            },
                          );
                        });
                  },
                ),
              );
            }),
      ),
    );
  }

  yearPicker() async {
    WidgetMixin.showDialog2(
      context,
      label: lang.selectYear,
      content: Container(
        width: 300,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(DateTime.now().year - 100, 1),
          lastDate: DateTime(DateTime.now().year),
          initialDate: DateTime(_selectedYearStream.value),
          selectedDate: DateTime(_selectedYearStream.value),
          onChanged: (DateTime dateTime) {
            _selectedYearStream.add(dateTime.year);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  getCount(int index, int startDate, int endDate) async {
    var res =
        await archiveService.getCountFilesArchiveByDate(startDate, endDate);
    var list = countStream.value;
    list.insert(index, res);
    list.removeAt(index + 1);
    countStream.add(list);
  }
}
