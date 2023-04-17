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
  //stream
  final documentListStream = BehaviorSubject.seeded(<DocumentSpecInput>[]);
//variables
  late List<DocumentSpecInput> listDocument;

  @override
  void initState() {
    listDocument = widget.listDocument;
    documentListStream.add(listDocument);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSpecInput>>(
        stream: documentListStream,
        initialData: documentListStream.value,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return SizedBox.shrink();
          }
          var index = -1;
          return Column(
            children: snapshot.data!.map((docSpec) {
              index++;
              var isRequired =
                  docSpec.optional ? lang.isNotRequired : lang.isNotRequired;
              var isOriginal =
                  docSpec.original ? lang.isOriginal : lang.isNotOriginal;
              var isDoubleSide = docSpec.doubleSided
                  ? lang.isDoubleSided
                  : lang.isNotDoubleSided;
              return ListTile(
                leading: CircleAvatar(
                  child: Text("${(index + 1)}"),
                ),
                title: Text("${docSpec.name}"),
                subtitle:
                    Text("${isRequired} , ${isOriginal} , ${isDoubleSide}"),
                trailing: widget.onChanged != null
                    ? TextButton(
                        onPressed: () async =>
                            await deleteDocument(docSpec, index),
                        child: Text(lang.delete.toUpperCase()),

                      )
                    : null,
              );
            }).toList(),
          );
        });
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
              var list = documentListStream.value;
              list.removeAt(index);
              documentListStream.add(list);
              if (widget.onChanged != null) {
                widget.onChanged!(documentListStream.value);
              }
              Navigator.of(context).pop(true);
            },
          )
        ],
      ),
    );
  }
}
