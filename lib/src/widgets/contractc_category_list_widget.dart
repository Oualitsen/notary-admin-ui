import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:rxdart/rxdart.dart';

class ContractCategoryListWidget extends StatefulWidget {
  final void Function(ContractCategory contractCategory) selectContractCategory;
  const ContractCategoryListWidget(
      {super.key, required this.selectContractCategory});
  @override
  State<ContractCategoryListWidget> createState() =>
      _ContractCategoryListWidgetState();
}

class _ContractCategoryListWidgetState
    extends BasicState<ContractCategoryListWidget> with WidgetUtilsMixin {
  final service = GetIt.instance.get<FileSpecService>();
  final selectedContractCategorySubject = BehaviorSubject<ContractCategory>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Expanded(
          child: StreamBuilder<ContractCategory>(
              stream: selectedContractCategorySubject,
              builder: (context, snapshot) {
                return InfiniteScrollListView<ContractCategory>(
                  elementBuilder:
                      (BuildContext context, element, int index, animation) {
                    return RadioListTile<ContractCategory>(
                        title: Text(element.name),
                        value: element,
                        groupValue: selectedContractCategorySubject.valueOrNull,
                        onChanged: (val) {
                          if (val != null) {
                            selectedContractCategorySubject.add(val);
                            widget.selectContractCategory(
                                selectedContractCategorySubject.value);
                          }
                        });
                  },
                  pageLoader: getData,
                );
              }),
        ),
      ]),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future<List<ContractCategory>> getData(int index) {
    return service.getContractCategory(pageIndex: index, pageSize: 10);
  }
}
