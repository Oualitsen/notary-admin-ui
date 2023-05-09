import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/services/contract_category_service.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/add_contract_category_widget.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AddContractCategoryPage extends StatefulWidget {
  final ContractCategory? contractCategory;
  const AddContractCategoryPage({super.key,this.contractCategory});

  @override
  State<AddContractCategoryPage> createState() =>
      _AddContractCategoryPageState();
}

class _AddContractCategoryPageState extends BasicState<AddContractCategoryPage>
    with WidgetUtilsMixin {
  final contractCategoryinfoKey = GlobalKey<AddContractCategoryWidgetState>();
  final ContractCategoryService service =
      GetIt.instance.get<ContractCategoryService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(lang.addContractCategory),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              AddContractCategoryWidget(
                key: contractCategoryinfoKey,
                contractCategory: widget.contractCategory,
              ),
              SizedBox(height: 15),
              getButtons(onSave: save),
            ],
          ),
        ));
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  save() async {
    var contractCategoryInput =
        contractCategoryinfoKey.currentState?.readContractCategoryInput();
    if (contractCategoryInput != null) {
      try {
        var result = await service.saveContractCategory(contractCategoryInput);
        Navigator.of(context).pop(result);
        await showSnackBar2(context, lang.savedSuccessfully);
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError(context, error: error);
      }
    }
  }
}
