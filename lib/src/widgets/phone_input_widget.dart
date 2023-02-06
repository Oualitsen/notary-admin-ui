import 'package:flutter/material.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/phone_number_input.dart';
import 'package:rapidoc_utils/alerts/alert_info_widget.dart';
import 'package:rxdart/rxdart.dart';

class PhoneInputWidget extends StatefulWidget {
  final Function(String text) _submitCallback;
  //final Function(PhoneNumber pn)? phoneReadCallback;
  final bool askForPhone;
  final bool showAlternative;
  final bool showTitle;
  final String? title;
  //final PhoneNumber? initial;
  final String? initialEmail;

  final String? phoneNotice;
  final String? emailNotice;

  const PhoneInputWidget(
    this._submitCallback, {
    Key? key,
    this.askForPhone = true,
    this.showAlternative = false,
    this.showTitle = true,
    this.title,
    //this.phoneReadCallback,
    // this.initial,
    this.phoneNotice,
    this.emailNotice,
    this.initialEmail,
  }) : super(key: key);

  @override
  _PhoneInputWidgetState createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends BasicState<PhoneInputWidget> {
  final BehaviorSubject<bool> _valid = BehaviorSubject.seeded(false);

  final BehaviorSubject<String> _phoneText = BehaviorSubject();

  final BehaviorSubject<bool> _typeSubject = BehaviorSubject.seeded(false);

  @override
  void initState() {
    super.initState();
    _typeSubject.add(!widget.askForPhone);

    _typeSubject.where((event) => true).listen((event) {
      var text = widget.initialEmail;
      bool valid =
          !(text == null || text.isEmpty || !emailRegExp.hasMatch(text));
      _valid.add(valid);
      if (valid) {
        _phoneText.add(text);
      }
    });
  }

  @override
  void dispose() {
    _valid.close();
    _phoneText.close();
    _typeSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        if (widget.showTitle)
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(widget.title!),
            )
          else
            StreamBuilder<bool>(
                stream: _typeSubject,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      (snapshot.data ?? false) ? lang.email : lang.phoneNumber,
                    ),
                  );
                }),
        StreamBuilder(
          stream: _typeSubject,
          builder: (context, AsyncSnapshot<bool> snap) {
            if (snap.data ?? false) {
              return Column(
                children: [
                  TextFormField(
                    onChanged: (text) {
                      bool valid =
                          !(text.isEmpty || !emailRegExp.hasMatch(text));

                      if (_valid.value != valid) {
                        _valid.add(valid);
                      }
                      _phoneText.add(text);
                    },
                    decoration: InputDecoration(
                      labelText: lang.email,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    initialValue: widget.initialEmail,
                  ),
                  if (widget.emailNotice != null)
                    AlertInfoWidget.createInfo(widget.emailNotice!),
                ],
              );
            } else {
              return Column(
                children: [
                  SizedBox(child: Text("@TODO")),
                  if (widget.phoneNotice != null)
                    AlertInfoWidget.createInfo(widget.phoneNotice!),
                ],
              );
            }
          },
        ),
        SizedBox(
          height: widget.showAlternative ? 30 : 0,
        ),
        widget.showAlternative
            ? StreamBuilder(
                stream: _typeSubject,
                builder: (context, AsyncSnapshot<bool> snap) {
                  var value = snap.data;

                  if (value == null) {
                    return const SizedBox.shrink();
                  }

                  String text = value
                      ? lang.usePhoneInstead.toUpperCase()
                      : lang.useEmailInstead.toUpperCase();
                  return OutlinedButton(
                    child: Text(text),
                    onPressed: () => _typeSubject.add(!value),
                  );
                },
              )
            : const SizedBox.shrink(),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            StreamBuilder(
              stream: _valid.stream,
              builder: (s, AsyncSnapshot<bool?> snap) {
                bool? value = snap.data;
                if (value == null) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton(
                  child: Row(
                    children: <Widget>[
                      Text(lang.next.toUpperCase()),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(Icons.arrow_forward)
                    ],
                  ),
                  onPressed: value
                      ? () {
                          widget._submitCallback(_phoneText.value);
                        }
                      : null,
                );
              },
            ),
          ],
        )
      ],
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}
