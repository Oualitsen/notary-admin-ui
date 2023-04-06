import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/document_spec_input.dart';
import 'package:rxdart/rxdart.dart';

class DocumentsWidget extends StatefulWidget {
  final List<DocumentSpecInput> listDocument;
  final Function(List<DocumentSpecInput> listDoc)? onChanged;
  const DocumentsWidget(
      {super.key, required this.listDocument, this.onChanged});

  @override
  State<DocumentsWidget> createState() => _DocumentsWidgetState();
}

class _DocumentsWidgetState extends BasicState<DocumentsWidget>
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
                      var isDoubleSide = snapshot.data![index].doubleSided
                          ? lang.isDoubleSided
                          : lang.isNotDoubleSided;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text("${(index + 1)}"),
                        ),
                        title: Text("${snapshot.data![index].name}"),
                        subtitle: Text(
                            "${isRequired} , ${isOriginal} , ${isDoubleSide}"),
                        trailing: widget.onChanged != null
                            ? TextButton(
                                onPressed: () async => await deleteDocument(
                                    snapshot.data![index], index),
                                child: Text(lang.delete),
                              )
                            : null,
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
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future deleteDocument(DocumentSpecInput documentSpecInput, int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.confirm),
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
              if (widget.onChanged != null) {
                widget.onChanged!(_listDocumentsStream.value);
              }
              Navigator.of(context).pop(true);
            },
          )
        ],
      ),
    );
  }
}
