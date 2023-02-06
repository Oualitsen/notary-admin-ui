/*

import 'package:notary_model/model/passwords.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/services/profile_service.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:notary_admin/src/widgets/password_input.dart';
import 'package:rapidoc_utils/common/full_page_progress.dart';
import 'package:rxdart/rxdart.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends BasicState<ChangePasswordPage> {
  final service = GetIt.instance.get<ProfileService>();
  final key = GlobalKey<FormState>();
  final oldPwdCtr = TextEditingController();
  final newPwdCtr = TextEditingController();
  final newPwdCtr2 = TextEditingController();
  final progress = BehaviorSubject.seeded(false);
  final authMan = Injector.provideAuthManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.changePassword),
      ),
      body: Stack(
        children: [
          Form(
            key: key,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PasswordInput(
                  controller: oldPwdCtr,
                  label: Text(lang.oldPassword),
                  validator: (text) {
                    if (text?.isEmpty ?? true) {
                      return lang.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordInput(
                  controller: newPwdCtr,
                  label: Text(lang.newPassword),
                  validator: (text) {
                    if (text?.isEmpty ?? true) {
                      return lang.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordInput(
                  controller: newPwdCtr2,
                  label: Text(lang.retypePassword),
                  validator: (text) {
                    if (text?.isEmpty ?? true) {
                      return lang.requiredField;
                    }
                    if (text != newPwdCtr.text) {
                      return lang.passwordDontMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(lang.cancel.toUpperCase()),
                    ),
                    const SizedBox(width: 10),
                    StreamBuilder<bool>(
                      stream: progress,
                      initialData: progress.value,
                      builder: (context, snapshot) => ElevatedButton(
                        onPressed: snapshot.data!
                            ? null
                            : () => changePassword(context),
                        child: Text(lang.ok.toUpperCase()),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          StreamBuilder<bool>(
              stream: progress,
              initialData: progress.value,
              builder: (context, snapshot) =>
                  snapshot.data! ? FullPageProgress() : const SizedBox.shrink())
        ],
      ),
    );
  }

  void changePassword(BuildContext context) {
    if (key.currentState?.validate() ?? false) {
      service
          .updatePassword(Passwords(oldPwdCtr.text, newPwdCtr.text))
          .asStream()
          .doOnListen(() => progress.add(true))
          .doOnDone(() => progress.add(false))
          .doOnError((p0, p1) => showServerError(context, error: p0))
          .asyncMap((event) => authMan.save(event))
          .asyncMap((event) => ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Text(lang.passwordChanged),
                  action: SnackBarAction(
                    label: lang.ok.toUpperCase(),
                    onPressed: () {},
                  ),
                ),
              )
              .closed)
          .listen((event) => Navigator.of(context).pop(true));
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [oldPwdCtr, newPwdCtr, newPwdCtr2];

  @override
  List<Subject> get subjects => [progress];
}
*/