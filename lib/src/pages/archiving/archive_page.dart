import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/archiving/add_archive_page.dart';
import 'package:notary_admin/src/pages/archiving/files_archived_table_widget.dart';
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
  final _selectedYearStream = BehaviorSubject.seeded(DateTime.now().year);
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
                      Container(
                          padding: EdgeInsets.all(5),
                          child: Text("${snapshot.data}")),
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
              return Column(
                children: [
                  Tooltip(
                    message: lang.selectYear,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        child: Text("${snapshot.data}"),
                        onPressed: yearPicker,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: DateTime.monthsPerYear,
                      itemBuilder: (context, index) {
                        var startDate = DateTime(snapshot.data!, (index + 1))
                            .millisecondsSinceEpoch;
                        var endDate =
                            DateTime(snapshot.data!, (index + 2), 0, 23, 59, 59)
                                .millisecondsSinceEpoch;
                        return ListTile(
                          leading: Icon(Icons.folder),
                          title: Text("${lang.monthName(startDate)}"),
                          onTap: () {
                            push(
                              context,
                              FilesArchiveTableWidget(
                                startDate: startDate,
                                endDate: endDate,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
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
}
