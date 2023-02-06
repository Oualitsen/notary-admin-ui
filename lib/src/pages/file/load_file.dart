import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/file/template_detail.dart';
import 'package:notary_admin/src/pages/file/upload_file.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:rxdart/src/subjects/subject.dart';

class LoadFilePage extends StatefulWidget {
  const LoadFilePage({super.key});

  @override
  State<LoadFilePage> createState() => _LoadFilePageState();
}

class _LoadFilePageState extends BasicState<LoadFilePage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<TemplateDocumentService>();
  final key = GlobalKey<InfiniteScrollListViewState<TemplateDocument>>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All the files")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadFilePage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: InfiniteScrollListView<TemplateDocument>(
        key: key,
        //   comparator: ((a, b) => a.creationDate - b.creationDate),
        elementBuilder: (BuildContext context, file, index, animation) {
          return ListTile(
              title: Text(file.name),
              // subtitle: Text(file.type),
              onTap: () async {
                var res = await Navigator.push<TemplateDocument?>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TemplateDetails(
                            template: file,
                          )),
                );
                if (res != null) {
                  key.currentState?.add(res);
                }
              });
        },
        pageLoader: getData,
      ),
    );
  }

  Future<List<TemplateDocument>> getData(int index) {
    if (index == 0)
      return service.getFiles(pageIndex: index, pageSize: 20);
    else
      return Future.value([]);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
