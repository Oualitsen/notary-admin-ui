import 'package:flutter/material.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_model/model/role.dart';

class RoleGuardWidget extends StatelessWidget {
  final Widget child;
  //this will be shown if the user does not have the role
  final Widget noRoleWidget;
  final Role role;
  const RoleGuardWidget(
      {super.key,
      required this.role,
      required this.child,
      this.noRoleWidget = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) {
    final _authManager = Injector.provideAuthManager();
    return StreamBuilder<List<Role>>(
        stream: _authManager.userSubject
            .where((event) => event != null)
            .map((event) => event!.roles),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }
          var roles = snapshot.data ?? [];
          if (roles.contains(role) || roles.contains(Role.ADMIN)) {
            return child;
          } else {
            return noRoleWidget;
          }
        });
  }
}

