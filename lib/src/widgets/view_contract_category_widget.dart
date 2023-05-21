import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view/infinite_scroll_list_view.dart';
import 'package:notary_admin/src/pages/contract/add_contract_category_page.dart';
import 'package:notary_admin/src/services/contract_category_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:rapidoc_utils/utils/Utils.dart';
import 'package:rxdart/rxdart.dart';

class ViewContractCategoryWidget extends StatefulWidget {
  const ViewContractCategoryWidget({super.key});

  @override
  State<ViewContractCategoryWidget> createState() =>
      ViewContractCategoryWidgetState();
}

class ViewContractCategoryWidgetState
    extends BasicState<ViewContractCategoryWidget> with WidgetUtilsMixin {
  final service = GetIt.instance.get<ContractCategoryService>();
  final selectedContractCategorySubject = BehaviorSubject<ContractCategory>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder(builder: (context, snapshot) {
            return InfiniteScrollListView(
                key: listKey,
                elementBuilder:
                    (BuildContext context, element, int index, animation) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return AddContractCategoryPage(
                            contractCategory: element);
                      })).then((value) => listKey.currentState?.reload());
                    },
                    title: Text("${element.name}"),
                    trailing: Wrap(
                      spacing: 40,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return AddContractCategoryPage(
                                  contractCategory: element);
                            })).then((value) => listKey.currentState?.reload());
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showAlertDialog(
                              context: context,
                              title: lang.confirm,
                              message: lang.confirmDeleteItem,
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(lang.cancel.toUpperCase())),
                                TextButton(
                                    onPressed: () {
                                      deleteContractCategory(element.id).then(
                                          (value) =>
                                              listKey.currentState?.reload());
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text(lang.ok.toUpperCase()))
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                pageLoader: getData);
          }),
        )
      ],
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future<List<ContractCategory>> getData(int index) {
    return service.getContractCategory(pageIndex: index, pageSize: 10);
  }

  Future<void> deleteContractCategory(String id) async {
    service.deleteContractCategory(id);
  }
}
