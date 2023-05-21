import 'package:flutter/material.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:notary_model/model/contract_formula.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';

class FormulaSelectWidget extends StatefulWidget {
  final List<FilesSpec> list;
  final void Function(FilesSpec fileSpec) onfileSpecChange;
  FormulaSelectWidget(this.list, {required this.onfileSpecChange, super.key});
  @override
  State<FormulaSelectWidget> createState() => FormulaSelectWidgetState();
}

class FormulaSelectWidgetState extends BasicState<FormulaSelectWidget>
    with WidgetUtilsMixin {
  final fileSpecsList = <FilesSpec>[];
  final key = GlobalKey<InfiniteScrollListViewState<FilesSpec>>();
  final filterStream = BehaviorSubject<String>.seeded("");
  final selectedFileSpec = BehaviorSubject<FilesSpec>();

  @override
  void initState() {
    var _list =
        widget.list.where((element) => element.formula != null).toList();
    if (_list.isNotEmpty) {
      selectedFileSpec.add(_list.first);
    }
    fileSpecsList.addAll(_list);
    filterStream.where((event) => key.currentState != null).listen((value) {
      key.currentState!.reload();
    });
    selectedFileSpec.listen((value) {
      widget.onfileSpecChange(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          TextFormField(
            decoration: getDecoration(lang.search, false),
            onChanged: (newText) {
              filterStream.add(newText);
            },
          ),
          Expanded(
            child: InfiniteScrollListView<FilesSpec>(
              loadingWidget: SizedBox.shrink(),
              itemLoadingWidget: SizedBox.shrink(),
              endOfResultWidget: SizedBox.shrink(),
              key: key,
              elementBuilder: (context, e, index, animation) =>
                  StreamBuilder<FilesSpec>(
                      stream: selectedFileSpec,
                      builder: (context, snapshot) {
                        bool selected = snapshot.data == e;
                        return ListTile(
                          title: Text(
                            e.name,
                            style: selected
                                ? TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  )
                                : null,
                          ),
                          onTap: () {
                            widget.onfileSpecChange(e);
                            selectedFileSpec.add(e);
                          },
                        );
                      }),
              pageLoader: (index) async {
                if (index == 0) {
                  return getFilteredData();
                }
                return [];
              },
            ),
          ),
        ],
      ),
    );
  }

  List<FilesSpec> getFilteredData() {
    var filterString = filterStream.value;
    if (filterString.isEmpty) {
      return fileSpecsList;
    }
    return fileSpecsList
        .where((element) =>
            element.name.toLowerCase().contains(filterString.toLowerCase()))
        .toList();
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
