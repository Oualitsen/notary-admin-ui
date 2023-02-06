import 'package:flutter/material.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:rxdart/rxdart.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? label;
  final String? Function(String?)? validator;
  const PasswordInput({
    Key? key,
    this.controller,
    this.label,
    this.validator,
  }) : super(key: key);

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends BasicState<PasswordInput> {
  final _subject = BehaviorSubject.seeded(true);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _subject,
        initialData: _subject.value,
        builder: (context, snapshot) {
          final obscure = snapshot.data!;

          return TextFormField(
            obscureText: obscure,
            controller: widget.controller,
            validator: widget.validator,
            decoration: InputDecoration(
              label: widget.label,
              suffix: InkWell(
                child: _getIcon(obscure),
                onTap: () => _subject.add(!obscure),
              ),
            ),
          );
        });
  }

  Widget _getIcon(bool obscure) {
    return Icon(
      obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
      size: 16,
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => const [];
}
