import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:notary_admin/src/pages/customer/customer_general_form.dart';
import 'package:notary_admin/src/pages/customer/id_card_widget.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/widgets/address_input_widget.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/mixins/button_utils_mixin.dart';
import 'package:notary_model/model/address.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/customer_input.dart';
import 'package:notary_model/model/id_card.dart';
import 'package:rxdart/subjects.dart';

class AddCustomerPage extends StatefulWidget {
  final Customer? customer;
  AddCustomerPage({super.key, this.customer});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends BasicState<AddCustomerPage>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<CustomerService>();
  final _currentStepStream = BehaviorSubject.seeded(0);
  final customerGeneralInfoKey = GlobalKey<CustomerGeneralFormState>();
  final addressInputKey = GlobalKey<AddressInputWidgetState>();
  final idCardInputKey = GlobalKey<IdCardWidgetState>();
  CustomerGeneralInfo? customerGeneralInfo;
  Address? address;
  IdCard? idCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.newCustomer),
      ),
      body: StreamBuilder<int>(
        stream: _currentStepStream,
        initialData: _currentStepStream.value,
        builder: (context, snapshot) {
          int activeState = snapshot.data ?? 0;
          return Stepper(
            //type: getStepperType(type),
            physics: ScrollPhysics(),
            currentStep: activeState,
            onStepTapped: (step) => tapped(step),
            controlsBuilder: (context, _) {
              return SizedBox.shrink();
            },
            steps: <Step>[
              Step(
                title: Text(lang.general.toUpperCase()),
                content: Column(
                  children: [
                    CustomerGeneralForm(
                      key: customerGeneralInfoKey,
                      customer: widget.customer,
                    ),
                    SizedBox(height: 16),
                    getButtons(
                        onSave: continued,
                        skipCancel: true,
                        saveLabel: lang.next.toUpperCase()),
                  ],
                ),
                isActive: activeState == 0,
                state: getState(0),
              ),
              Step(
                title: Text(lang.address.toUpperCase()),
                content: Column(children: [
                  AddressInputWidget(
                    key: addressInputKey,
                    customer: widget.customer,
                  ),
                  SizedBox(height: 16),
                  getButtons(
                      onSave: continued,
                      saveLabel: lang.next.toUpperCase(),
                      cancelLabel: lang.previous.toUpperCase(),
                      onCancel: previous),
                ]),
                isActive: activeState == 1,
                state: getState(1),
              ),
              Step(
                title: Text(lang.idCardInfo.toUpperCase()),
                content: Column(
                  children: [
                    IdCardWidget(
                      key: idCardInputKey,
                      customer: widget.customer,
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 16),
                    getButtons(
                        onSave: continued,
                        saveLabel: lang.submit.toUpperCase(),
                        cancelLabel: lang.previous.toUpperCase(),
                        onCancel: previous),
                  ],
                ),
                isActive: activeState == 2,
                state: getState(2),
              ),
            ],
          );
        },
      ),
    );
  }

  tapped(int step) {
    _currentStepStream.add(step);
  }

  previous() {
    int value = _currentStepStream.value;
    value > 0 ? value -= 1 : value = 0;
    _currentStepStream.add(value);
  }

  continued() {
    var value = _currentStepStream.value;

    switch (value) {
      case 0:
        {
          var generalInfo =
              customerGeneralInfoKey.currentState!.readCustomerGeneralInfo();

          setState(() {
            customerGeneralInfo = generalInfo;
          });
          if (customerGeneralInfo != null) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 1:
        {
          var addressInput = addressInputKey.currentState!.readAddress();

          setState(() {
            address = addressInput;
          });
          if (address != null) {
            _currentStepStream.add(_currentStepStream.value + 1);
          }
        }
        break;
      case 2:
        {
          var idCardInput = idCardInputKey.currentState!.readAddress();

          setState(() {
            idCard = idCardInput;
          });
          if (idCard != null) {
            save();
          }
        }
        break;
    }
  }

  save() async {
    if (address != null && customerGeneralInfo != null && idCard != null) {
      try {
        progressSubject.add(true);

        if (widget.customer == null) {
          CustomerInput input = CustomerInput(
            id: null,
            firstName: customerGeneralInfo!.firstName,
            lastName: customerGeneralInfo!.lastName,
            dateOfBirth: customerGeneralInfo!.dateOfBirth,
            gender: customerGeneralInfo!.gender,
            idCard: idCard!,
            address: address!,
          );
          await service.saveCustomer(input);
          await showSnackBar2(context, lang.savedSuccessfully);
        } else {
          CustomerInput input = CustomerInput(
            id: widget.customer!.id,
            firstName: customerGeneralInfo!.firstName,
            lastName: customerGeneralInfo!.lastName,
            dateOfBirth: customerGeneralInfo!.dateOfBirth,
            gender: customerGeneralInfo!.gender,
            idCard: idCard!,
            address: address!,
          );
          await service.saveCustomer(input);
          await showSnackBar2(context, lang.updatedSuccessfully);
        }
      } catch (error, stackTrace) {
        showServerError(context, error: error);
        print(stackTrace);
        throw error;
      } finally {
        progressSubject.add(false);
      }
    } else {
      showSnackBar2(context, "ERRRRRROOOOORRRR");
    }
  }

  StepState getState(int currentState) {
    final value = _currentStepStream.value;
    if (value >= currentState) {
      return StepState.complete;
    } else {
      return StepState.disabled;
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
