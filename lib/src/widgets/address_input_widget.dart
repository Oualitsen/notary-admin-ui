import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/address.dart';
import 'package:flutter/material.dart';
import 'package:notary_model/model/customer.dart';
import 'package:rxdart/src/subjects/subject.dart';

class AddressInputWidget extends StatefulWidget {
  final Customer? customer;
  const AddressInputWidget({Key? key, this.customer}) : super(key: key);

  @override
  State<AddressInputWidget> createState() => AddressInputWidgetState();
}

class AddressInputWidgetState extends BasicState<AddressInputWidget>
    with WidgetUtilsMixin {
  final _formKey = GlobalKey<FormState>();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final postalCodeCtrl = TextEditingController();

  @override
  void initState() {
    if (widget.customer != null) {
      final a = widget.customer!.address;
      streetCtrl.text = a.street!;
      cityCtrl.text = a.city!;
      stateCtrl.text = a.state!;
      countryCtrl.text = a.country!;
      postalCodeCtrl.text = a.postalCode!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: streetCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.street, true)),
          const SizedBox(height: 16),
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: cityCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.city, true)),
          const SizedBox(height: 16),
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: stateCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.state, true)),
          const SizedBox(height: 16),
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: countryCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.country, true)),
          const SizedBox(height: 16),
          TextFormField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              controller: postalCodeCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.postalCode, true)),
        ],
      ),
    );
  }

  Address? readAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      /**
       * Get the coordinqtes first
       */

      var address = Address(
          street: streetCtrl.text,
          city: cityCtrl.text,
          state: stateCtrl.text,
          postalCode: postalCodeCtrl.text,
          country: countryCtrl.text);

      return address;
    }
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
