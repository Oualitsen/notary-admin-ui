import 'package:flutter/material.dart';
import 'package:notary_admin/src/pages/contract/add_contract_category_page.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/contract_category.dart';
import 'package:notary_model/model/contract_category_input.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AddContractCategoryWidget extends StatefulWidget {
  final ContractCategory? contractCategory;

  const AddContractCategoryWidget({super.key, this.contractCategory});

  @override
  State<AddContractCategoryWidget> createState() =>
      AddContractCategoryWidgetState();
}

class AddContractCategoryWidgetState
    extends BasicState<AddContractCategoryWidget> with WidgetUtilsMixin {
  final nameCtrl = TextEditingController();
  final nameArCtrl = TextEditingController();
  final nameFrCtrl = TextEditingController();
  final key = GlobalKey<FormState>();
  final contractCategoryInputKey = GlobalKey<AddContractCategoryPageState>();

  @override
  void initState() {
    if (widget.contractCategory != null) {
      nameArCtrl.text = widget.contractCategory!.nameAr;
      nameCtrl.text = widget.contractCategory!.name;
      nameFrCtrl.text = widget.contractCategory!.nameFr;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        children: [
          TextFormField(
            decoration: getDecoration(lang.name, false),
            controller: nameCtrl,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: getDecoration(lang.nameAr, false),
            controller: nameArCtrl,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: getDecoration(lang.nameFr, false),
            controller: nameFrCtrl,
          ),
          SizedBox(height: 20),
          
        ],
        
      ),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  ContractCategoryInfo? readContractCategoryInput() {
    var state = key.currentState!;
    if (state.validate()) {
      var contractCategoryInfo = ContractCategoryInfo(
        name: nameCtrl.text,
        nameAr: nameArCtrl.text,
        nameFr: nameFrCtrl.text,
      );
      return contractCategoryInfo;
    }
    return null;
  }
}

class ContractCategoryInfo {
  final String name;
  final String nameAr;
  final String nameFr;

  ContractCategoryInfo(
      {required this.name, required this.nameAr, required this.nameFr});
}
