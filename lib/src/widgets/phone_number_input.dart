import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_model/model/phone_number.dart';
import 'package:rapidoc_utils/alerts/alert_info_widget.dart';
import 'package:rapidoc_utils/common/full_page_progress.dart';
import 'package:rapidoc_utils/phone_number_input/phone_code.dart';
import 'package:rapidoc_utils/widgets/image_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

const _persistenceKey = "phoneNumber";

class PhoneNumberInput extends StatefulWidget {
  final PhoneNumber? phoneNumber;
  final Function(PhoneNumber) onChange;
  final bool persist;

  const PhoneNumberInput({
    Key? key,
    this.phoneNumber,
    required this.onChange,
    this.persist = false,
  }) : super(key: key);

  @override
  _PhoneNumberInputState createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends BasicState<PhoneNumberInput> {
  late PhoneNumber _phoneNumber;

  late final TextEditingController ctrl;

  final defaultNumber = PhoneNumber("DZ", 213, "", "");

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.phoneNumber ?? defaultNumber;
    ctrl = TextEditingController();
    ctrl.text = _phoneNumber.national;
  }

  Future<void> saveValue(PhoneNumber phone) async {
    if (widget.persist) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_persistenceKey, jsonEncode(phone.toJson()));
    }
  }

  Future<PhoneNumber> readValue() {
    return Stream.value((widget.persist) && widget.phoneNumber == null)
        .where((event) => event)
        .asyncMap((event) => SharedPreferences.getInstance())
        .map((prefs) => prefs.getString(_persistenceKey))
        .where((event) => event != null)
        .map((event) => event!)
        .map((event) => PhoneNumber.fromJson(jsonDecode(event)))
        .onErrorResume((error, stackTrace) => Stream.value(defaultNumber))
        .defaultIfEmpty(defaultNumber)
        .first;
  }

  Future<List<PhoneCode>> getCodes() {
    return rootBundle
        .loadString("assets/countries.json")
        .asStream()
        .map((event) => jsonDecode(event))
        .map((event) => event as List<dynamic>)
        .map((list) => list
            .map((e) =>
                PhoneCode(dial: e["dial"], name: e["name"], code: e["code"]))
            .toList())
        .first;
  }

  @override
  Widget build(BuildContext context) {
    if (_phoneNumber.national.isNotEmpty) {
      widget.onChange(_phoneNumber);
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        OutlinedButton(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
            child: Text("+${_phoneNumber.regionCode}"),
          ),
          onPressed: () async {
            var result = await showModalBottomSheet(
                builder: (context) {
                  return FutureBuilder<List<PhoneCode>>(
                      future: getCodes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return AlertInfoWidget.createDanger(
                              lang.couldNotLoadData);
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          var codes = snapshot.data ?? <PhoneCode>[];
                          return ListView(
                            children: codes
                                .map(
                                  (code) => ListTile(
                                    leading: ImageUtils.fromNetworkRounded(
                                      getFlagUrl(code.code),
                                      width: 32,
                                      height: 32,
                                    ),
                                    title: Text(code.dial),
                                    subtitle: Text(code.name),
                                    onTap: () {
                                      Navigator.of(context).pop(code);
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return FullPageProgress();
                      });
                },
                context: context);

            if (result != null) {
              var code = result as PhoneCode;
              setState(() {
                _phoneNumber.regionCode = int.parse(code.dial.substring(1));
                _phoneNumber.region = code.code;
                widget.onChange(_phoneNumber);
              });
            }
          },
        ),
        const SizedBox(width: 5),
        Expanded(
          child: FutureBuilder<PhoneNumber>(
              future: readValue(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                _phoneNumber = snapshot.data!;
                ctrl.text = _phoneNumber.national;

                return TextField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  controller: ctrl,
                  onChanged: (text) {
                    _phoneNumber.national = text;
                    widget.onChange(_phoneNumber);
                    saveValue(_phoneNumber);
                  },
                  decoration: InputDecoration(
                    hintText: lang.phoneNumber,
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
