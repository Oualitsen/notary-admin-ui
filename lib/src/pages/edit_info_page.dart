
/*
import 'package:notary_model/model/users/admin.dart';
import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_admin/src/widgets/basic_state.dart';
import 'package:rapidoc_utils/auth_status.dart';
import 'package:rxdart/rxdart.dart';

class EditInfoPage extends StatefulWidget {
  final bool pop;
  const EditInfoPage({Key? key, this.pop = true}) : super(key: key);

  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends BasicState<EditInfoPage> {
  final authMan = Injector.provideAuthManager();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Admin?>(
        stream: authMan.userSubject,
        initialData: authMan.userSubject.valueOrNull,
        builder: (context, snapshot) {
          var user = snapshot.data;
          if (user == null) {
            return const SizedBox.shrink();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(lang.editInfo),
            ),
            body: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BasicInfoInputWidget(
                info: user.basicUserInfo,
                showCancelButton: widget.pop,
                onSave: (customer) {
                  if (widget.pop) {
                    Navigator.of(context).pop(customer);
                  } else {
                    authMan.subject.add(AuthStatus.logged_in);
                    authMan.userSubject.add(customer);
                  }
                },
              ),
            )),
          );
        });
  }

  @override
  List<ChangeNotifier> get notifiers => const [];

  @override
  List<Subject> get subjects => const [];
}
*/