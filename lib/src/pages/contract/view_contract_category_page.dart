import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:notary_admin/src/pages/contract/add_contract_category_page.dart';
import 'package:notary_admin/src/utils/widget_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_admin/src/widgets/view_contract_category_widget.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:rxdart/src/subjects/subject.dart';

class ViewContractCategoryPage extends StatefulWidget {
  const ViewContractCategoryPage({super.key});

  @override
  State<ViewContractCategoryPage> createState() =>
      _ViewContractCategoryPageState();
}

class _ViewContractCategoryPageState
    extends BasicState<ViewContractCategoryPage> with WidgetUtilsMixin {
  final viewContractCategoryWidgetKey =
      GlobalKey<ViewContractCategoryWidgetState>();
  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
        appBar: AppBar(title: Text(lang.contractCategory)),
        body: ViewContractCategoryWidget(key: viewContractCategoryWidgetKey),
        floatingActionButton: ElevatedButton(
          child: Text(lang.addContractCategory.toUpperCase()),
          onPressed: () {
            Navigator.of(context)
                .push<ContractCategory?>(MaterialPageRoute(builder: (context) {
              return AddContractCategoryPage();
            })).then((value) => viewContractCategoryWidgetKey
                    .currentState?.listKey.currentState
                    ?.add(value));
          },
        )));
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
