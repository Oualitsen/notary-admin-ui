import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/validation_utils.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/gender.dart';
import 'package:rxdart/src/subjects/subject.dart';
import 'package:rxdart/subjects.dart';

class CustomerGeneralForm extends StatefulWidget {
  final Customer? customer;
  CustomerGeneralForm({super.key, this.customer});

  @override
  State<CustomerGeneralForm> createState() => CustomerGeneralFormState();
}

class CustomerGeneralFormState extends BasicState<CustomerGeneralForm>
    with WidgetUtilsMixin {
  final generalInfoInputKey = GlobalKey<FormState>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final selectedDay = BehaviorSubject<DateTime>();
  final dateOfBirthCtrl = TextEditingController();
  Gender? gender;
  bool initialized = false;
  void init() {
    if (initialized) {
      return;
    }
    initialized = true;
    if (widget.customer != null) {
      var customer = widget.customer!;
      firstNameCtrl.text = customer.firstName;
      lastNameCtrl.text = customer.lastName;
      dateOfBirthCtrl.text = lang.formatDate(customer.dateOfBirth);
      gender = customer.gender;
      selectedDay
          .add(DateTime.fromMillisecondsSinceEpoch(customer.dateOfBirth));
    }
    selectedDay.listen((date) {
      dateOfBirthCtrl.text = lang.formatDate(date.millisecondsSinceEpoch);
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Form(
      key: generalInfoInputKey,
      child: Column(
        children: [
          TextFormField(
              controller: firstNameCtrl,
              validator: (text) {
                return ValidationUtils.requiredField(text, context);
              },
              decoration: getDecoration(lang.firstName, true)),
          const SizedBox(height: 16),
          TextFormField(
              controller: lastNameCtrl,
              validator: (text) {
                return ValidationUtils.requiredField(text, context);
              },
              decoration: getDecoration(lang.lastName, true)),
          const SizedBox(height: 16),
          Column(
            children: [
              DropdownButtonFormField<Gender>(
                decoration: getDecoration(lang.gender, true),
                value: gender,
                items: Gender.values
                    .map(
                      (e) => DropdownMenuItem<Gender>(
                        child: Text(lang.genderValue(e)),
                        value: e,
                      ),
                    )
                    .toList(),
                onChanged: (e) {
                  setState(() {
                    gender = e;
                  });
                },
                validator: (value) => ValidationUtils.requiredField(
                    value == null ? null : "$value", context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          wrapInIgnorePointer(
            onTap: selectDate,
            child: TextFormField(
                controller: dateOfBirthCtrl,
                validator: (text) {
                  return ValidationUtils.requiredField(text, context);
                },
                decoration: getDecoration(lang.dateOfBirth, true)),
          ),
        ],
      ),
    );
  }

  CustomerGeneralInfo? readCustomerGeneralInfo() {
    if (generalInfoInputKey.currentState?.validate() ?? false) {
      CustomerGeneralInfo result = new CustomerGeneralInfo(
        firstName: firstNameCtrl.text,
        lastName: lastNameCtrl.text,
        gender: gender!,
        dateOfBirth: selectedDay.value.millisecondsSinceEpoch,
      );
      return result;
    } else
      return null;
  }

  selectDate() {
    final now = selectedDay.valueOrNull ?? DateTime.now();
    showDatePicker(
            context: context,
            initialDate: now,
            firstDate: now.add(Duration(days: -365 * 100)),
            lastDate: now)
        .asStream()
        .where((event) => event != null)
        .map((event) => event!)
        .listen(selectedDay.add);
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class CustomerGeneralInfo {
  final String firstName;
  final String lastName;
  final Gender gender;
  final int dateOfBirth;

  CustomerGeneralInfo({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
  });
}
