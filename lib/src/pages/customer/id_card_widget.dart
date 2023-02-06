import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/id_card.dart';
import 'package:rxdart/subjects.dart';

class IdCardWidget extends StatefulWidget {
  final Customer? customer;
  IdCardWidget({super.key, this.customer});

  @override
  State<IdCardWidget> createState() => IdCardWidgetState();
}

class IdCardWidgetState extends BasicState<IdCardWidget> with WidgetUtilsMixin {
  final _formKey = GlobalKey<FormState>();
  final idCardIdCtrl = TextEditingController();
  final expiryDateCtrl = TextEditingController();
  final frontImageUrlCtrl = TextEditingController();
  final backImageUrlCtrl = TextEditingController();
  final selectedDay = BehaviorSubject<DateTime>();
  bool initialized = false;
  void init() {
    if (initialized) {
      return;
    }
    initialized = true;
    if (widget.customer != null) {
      final card = widget.customer!.idCard;
      idCardIdCtrl.text = card.idCardId;
      expiryDateCtrl.text = lang.formatDate(card.expiryDate);
      frontImageUrlCtrl.text = card.frontImageUrl;
      backImageUrlCtrl.text = card.backImageUrl;
      selectedDay.add(DateTime.fromMillisecondsSinceEpoch(card.expiryDate));
    }
    selectedDay.listen((date) {
      expiryDateCtrl.text = lang.formatDate(date.millisecondsSinceEpoch);
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: idCardIdCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.cardId, true)),
          const SizedBox(height: 16),
          wrapInIgnorePointer(
            onTap: selectDate,
            child: TextFormField(
                controller: expiryDateCtrl,
                validator: (text) {
                  return ValidationUtils.requiredField(text, context);
                },
                decoration: getDecoration(lang.expiryDate, true)),
          ),
          const SizedBox(height: 16),
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: frontImageUrlCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.frontImageUrl, true)),
          const SizedBox(height: 16),
          TextFormField(
              textInputAction: TextInputAction.next,
              controller: backImageUrlCtrl,
              validator: (text) => ValidationUtils.requiredField(text, context),
              decoration: getDecoration(lang.backImageUrl, true)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  selectDate() {
    final now = selectedDay.valueOrNull ?? DateTime.now();
    showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now,
            lastDate: now.add(Duration(days: 365 * 100)))
        .asStream()
        .where((event) => event != null)
        .map((event) => event!)
        .listen(selectedDay.add);
  }

  IdCard? readAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      /**
       * Get the coordinqtes first
       */

      var idCard = IdCard(
        backImageUrl: backImageUrlCtrl.text,
        expiryDate: selectedDay.value.millisecondsSinceEpoch,
        frontImageUrl: frontImageUrlCtrl.text,
        idCardId: idCardIdCtrl.text,
      );

      return idCard;
    }
    return null;
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
