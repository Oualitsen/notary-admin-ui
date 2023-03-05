import 'package:device_preview/device_preview.dart';
import 'package:notary_admin/src/pages/assistant/list_assistant_page.dart';
import 'package:notary_admin/src/pages/customer/customer_selection_page.dart';
import 'package:notary_admin/src/pages/customer/customer_table_widget.dart';
import 'package:notary_admin/src/pages/customer/form_and_view_html.dart';
import 'package:notary_admin/src/pages/customer/list_customer_page.dart';
import 'package:notary_admin/src/pages/file/load_file.dart';
import 'package:notary_admin/src/pages/login_page.dart';
import 'package:notary_admin/src/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/device_screen_type.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/utils/injector.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/selection_type.dart';
import 'package:rapidoc_utils/widgets/image_utils.dart';
import 'package:rapidoc_utils/widgets/menu_drawer.dart';
import 'package:rapidoc_utils/widgets/route_guard_widget.dart';
import 'package:rapidoc_utils/widgets/template_builder.dart';

import '../pages/customer/add_folder_customer.dart';
import '../pages/file/file_spec_List.dart';

class WidgetUtils {
  static Widget wrapRoute(
      Widget Function(BuildContext context, DeviceScreenType type) route,
      {guard = true,
      useTemplate = true}) {
    final _authManager = Injector.provideAuthManager();
    if (guard) {
      return RouteGuardWidget(
        authStream: _authManager.subject,
        loggedOutBuilder: (context) => const LoginPage(),
        childBuilder: (context) {
          var user = _authManager.currentUser;
          if (user != null) {
            return TemplateBuilder(
              drawerBuilder: (BuildContext context, DeviceScreenType type) =>
                  useTemplate ? createDrawer(context) : SizedBox.shrink(),
              appBarBuilder: (BuildContext context, DeviceScreenType type) =>
                  buildAppBar(context),
              childBuilder: (context, type) => route(context, type),
            );
          } else {
            return const LoginPage();
          }
        },
      );
    }
    return TemplateBuilder(
      drawerBuilder: (BuildContext context, DeviceScreenType type) =>
          SizedBox(),
      appBarBuilder: (BuildContext context, DeviceScreenType type) =>
          buildAppBar(context),
      childBuilder: (context, type) => route(context, type),
    );
  }

  static AppBar buildAppBar(
    BuildContext context, {
    bool desktop = false,
    Function()? onMenuPressed,
  }) {
    var lang = getLang(context);
    var _auth = Injector.provideAuthManager();

    if (_auth.isLoggedIn) {
      return AppBar(
        leading: desktop
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onMenuPressed,
              )
            : null,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: getActions(context),
        title: Text(
          lang.appName,
        ),
      );
    } else {
      return AppBar(
        toolbarHeight: 72,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "images/logo.png",
            width: 60,
            height: 60,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(lang.appName),
        actions: getActions(context),
        elevation: 0.0,
      );
    }
  }

  static List<Widget> getActions(BuildContext context) {
    return [];
  }
}

Widget createDrawer(BuildContext context) {
  final authManager = Injector.provideAuthManager();
  final lang = getLang(context);
  return MenuDrawer(
    items: [
      DrawerMenuItem(
        title: (lang.search),
        icon: Icons.search,
        onTap: () => {},
      ),
      DrawerMenuItem(
        title: (lang.customers),
        icon: Icons.people,
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CustomerSelection(
                      selectionType: SelectionType.SINGLE,
                    )),
          )
        },
      ),
      DrawerMenuItem(
        title: (lang.assistantList),
        icon: Icons.people_alt_outlined,
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListAssistantPage()),
          )
        },
      ),
      DrawerMenuItem(
        title: (lang.fileList),
        icon: Icons.person,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoadFilePage()),
          );
        },
      ),
      DrawerMenuItem(
        title: (lang.profile),
        icon: Icons.person,
        onTap: () => Navigator.of(context).pushNamed(ProfilePage.routeName),
      ),
      DrawerMenuItem(
        title: (lang.logout),
        icon: Icons.logout,
        onTap: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(lang.confirm),
              content: Text(lang.confirmLogout),
              actions: <Widget>[
                TextButton(
                  child: Text(lang.no.toUpperCase()),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(lang.yes.toUpperCase()),
                  onPressed: () => Navigator.of(context).pop(true),
                )
              ],
            ),
          ).asStream().where((event) => event).asyncMap((event) {
            final userManager = Injector.provideAuthManager();
            return userManager.remove();
          }).asyncMap((event) {
            var service = GetIt.instance.get<TokenDbService>();
            return service.remove();
          }).listen((event) {
            //print("logged out");
          });
        },
      ),
      DrawerMenuItem(
        title: (lang.fileSpec),
        icon: Icons.file_download,
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: ((context) => FileSpecList()))),
      ),
      DrawerMenuItem(
        title: lang.addfolder,
        icon: Icons.folder,
        onTap: () => {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddFolderCustomer()))
        },
      ),
    ],
    header: DrawerHeader(
      decoration: const BoxDecoration(),
      child: StreamBuilder<Admin?>(
          stream: authManager.userSubject,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            var user = snapshot.data!;

            return Column(
              children: <Widget>[
                SizedBox(height: 60),
                Text(
                  "${user.firstName} ${user.lastName}".toUpperCase(),
                ),
                const SizedBox(height: 5),
              ],
            );
          }),
    ),
  );
}

AppBar defaultAppBar(BuildContext context, {List<Widget>? actions}) {
  return AppBar(
    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageUtils.fromAsset("assets/images/logo-no-bg.png", height: 45)
      ],
    ),
    actions: actions,
  );
}

Widget wrap(Widget child, {double radius = 16}) => Container(
    decoration: BoxDecoration(
        color: const Color(0xFFf2f2f2),
        borderRadius: BorderRadius.all(Radius.circular(radius))),
    child: child);

Widget logoutButton(BuildContext context) {
  var lang = getLang(context);
  return wrap(TextButton(
    onPressed: () async {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(lang.confirm),
          content: Text(lang.confirmLogout),
          actions: <Widget>[
            TextButton(
              child: Text(lang.no.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(lang.yes.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        ),
      ).asStream().where((event) => event).asyncMap((event) {
        final userManager = Injector.provideAuthManager();
        return userManager.remove();
      }).asyncMap((event) {
        var service = GetIt.instance.get<TokenDbService>();
        return service.remove();
      }).listen((event) {
        //print("logged out");
      });
    },
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const Icon(Icons.logout),
          const SizedBox(width: 10),
          Text(lang.logout),
        ],
      ),
    ),
  ));
}

StepperType getStepperType(DeviceScreenType type) {
  switch (type) {
    case DeviceScreenType.mobile:
      return StepperType.vertical;
    case DeviceScreenType.tablet:
      return StepperType.vertical;
    case DeviceScreenType.desktop:
      return StepperType.horizontal;
  }
}
