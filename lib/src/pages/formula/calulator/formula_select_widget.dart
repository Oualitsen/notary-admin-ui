import 'package:flutter/material.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_formula.dart';
import 'package:notary_model/model/files_spec.dart';
import 'package:rxdart/rxdart.dart';

class FormulaSelectWidget extends StatefulWidget {
  final List<FilesSpec> list;
  final void Function(ContractFormula) onSelect;
  FormulaSelectWidget(this.list, {required this.onSelect, super.key});
  @override
  State<FormulaSelectWidget> createState() => _FormulaSelectWidgetState();
}

class _FormulaSelectWidgetState extends BasicState<FormulaSelectWidget>
    with WidgetUtilsMixin {
  final fileSpecsList = <FilesSpec>[];
  final key = GlobalKey<InfiniteScrollListViewState<FilesSpec>>();
  final filterStream = BehaviorSubject<String>.seeded("");
  final selectedFormula = BehaviorSubject<ContractFormula>();
  @override
  void initState() {
    var _list =
        widget.list.where((element) => element.formula != null).toList();
    if (_list.isNotEmpty) {
      selectedFormula.add(_list.first.formula!);
    }
    fileSpecsList.addAll(_list);
    filterStream.where((event) => key.currentState != null).listen((value) {
      key.currentState!.reload();
    });
    selectedFormula.listen((value) {
      widget.onSelect(value);
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
                  StreamBuilder<ContractFormula>(
                      stream: selectedFormula,
                      builder: (context, snapshot) {
                        bool selected = snapshot.data == e.formula;
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
                            selectedFormula.add(e.formula!);

                            //////////////////////////////////////////////////////////////////////
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
