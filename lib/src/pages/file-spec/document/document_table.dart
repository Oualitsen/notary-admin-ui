import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/widget_mixin_new.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:rxdart/rxdart.dart';
import '../../../widgets/mixins/button_utils_mixin.dart';

class DocumentsTable extends StatefulWidget {
  final List<DocumentSpecInput> listDocument;
  final Function(List<DocumentSpecInput> listDoc) onChanged;
  const DocumentsTable(
      {super.key, required this.listDocument, required this.onChanged});

  @override
  State<DocumentsTable> createState() => _DocumentsTableState();
}

class _DocumentsTableState extends BasicState<DocumentsTable>
    with WidgetUtilsMixin {
  final columnSpacing = 30.0;
  bool initialized = false;
  final _listDocumentsStream = BehaviorSubject.seeded(<DocumentSpecInput>[]);
  List<DataColumn> columns = [];
  late List<DocumentSpecInput> listDocument;
  @override
  void initState() {
    listDocument = widget.listDocument;
    _listDocumentsStream.add(listDocument);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 200,
      alignment: Alignment.topLeft,
      child: StreamBuilder<List<DocumentSpecInput>>(
          stream: _listDocumentsStream,
          initialData: _listDocumentsStream.value,
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return SizedBox.shrink();
            }
            return snapshot.data!.isEmpty
                ? ListTile(title: Text(lang.noDocument.toUpperCase()))
                : ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, int index) {
                      var isRequired = snapshot.data![index].optional
                          ? lang.isNotRequired
                          : lang.isNotRequired;
                      var isOriginal = snapshot.data![index].original
                          ? lang.isOriginal
                          : lang.isNotOriginal;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text("${(index + 1)}"),
                        ),
                        title: Text("${snapshot.data![index].name}"),
                        subtitle: Text("${isRequired} , ${isOriginal}"),
                        trailing: IconButton(
                          onPressed: () =>
                              deleteDocument(snapshot.data![index], index),
                          icon: Icon(
                            Icons.delete,
                          ),
                        ),
                      );
                    },
                  );
          }),
    );
  }

  Future<List<DocumentSpecInput>> getData(int page) {
    return Future<List<DocumentSpecInput>>(
      () {
        return listDocument;
      },
    );
  }

  Future<int> getTotal() {
    return Future<int>(
      () {
        return listDocument.length;
      },
    );
  }

  @override
  // TODO: implement notifiers
  List<ChangeNotifier> get notifiers => [];

  @override
  // TODO: implement subjects
  List<Subject> get subjects => [];

  deleteDocument(DocumentSpecInput documentSpecInput, int index) {
    WidgetMixin.showDialog2(
      context,
      label: lang.confirm,
      content: Text(lang.confirmDelete),
      actions: <Widget>[
        TextButton(
          child: Text(lang.no.toUpperCase()),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(lang.yes.toUpperCase()),
          onPressed: () async {
            var list = _listDocumentsStream.value;
            list.removeAt(index);

            _listDocumentsStream.add(list);
            print(list.length);
            if (list.isEmpty) {
              await showSnackBar2(context, lang.noDocument);
            }
            widget.onChanged(_listDocumentsStream.value);

            Navigator.of(context).pop(true);
          },
        )
      ],
    );
  }
}
