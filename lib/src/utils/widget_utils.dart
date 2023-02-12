import 'package:notary_admin/src/pages/assistant/list_assistant_page.dart';
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
import 'package:rapidoc_utils/widgets/image_utils.dart';
import 'package:rapidoc_utils/widgets/menu_drawer.dart';
import 'package:rapidoc_utils/widgets/route_guard_widget.dart';
import 'package:rapidoc_utils/widgets/template_builder.dart';

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
            MaterialPageRoute(builder: (context) => ProfilePage()),
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
        title: ("Html view"),
        icon: Icons.people_alt_outlined,
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FormAndViewHtml(
                      listFormField: [
                        lang.lastName,
                        lang.firstName,
                        lang.gender
                      ],
                      text: '''<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">

    <title>Intitulé de ma page</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans+Condensed:300|Sonsie+One" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="style.css">

    <!-- Les trois lignes ci‑dessous sont un correctif pour que la sémantique
          HTML5 fonctionne correctement avec les anciennes versions de
          Internet Explorer-->
    <!--[if lt IE 9]>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv.js"></script>
    <![endif]-->
  </head>

  <body>
    <!-- Voici notre en‑tête principale utilisée dans toutes les pages
          de notre site web -->
    <header>
      <h1>En-tête</h1>
    </header>

    <nav>
      <ul>
        <li><a href="#">Accueil</a></li>
        <li><a href="#">L'équipe</a></li>
        <li><a href="#">Projets</a></li>
        <li><a href="#">Contact</a></li>
      </ul>

        <!-- Un formulaire de recherche est une autre façon de naviguer de
            façon non‑linéaire dans un site. -->

        <form>
          <input type="search" name="q" placeholder="Rechercher">
          <input type="submit" value="Lancer !">
        </form>
      </nav>

    <!-- Ici nous mettons le contenu de la page -->
    <main>

      <!-- Il contient un article -->
      <article>
        <h2>En-tête d'article</h2>
        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Donec a diam lectus. Set sit amet ipsum mauris. Maecenas congue ligula as quam viverra nec consectetur ant hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue. Nam tincidunt congue enim, ut porta lorem lacinia consectetur.</p>

        <h3>Sous‑section</h3>
        <p>Donec ut librero sed accu vehicula ultricies a non tortor. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Aenean ut gravida lorem. Ut turpis felis, pulvinar a semper sed, adipiscing id dolor.</p>
        <p>Pelientesque auctor nisi id magna consequat sagittis. Curabitur dapibus, enim sit amet elit pharetra tincidunt feugiat nist imperdiet. Ut convallis libero in urna ultrices accumsan. Donec sed odio eros.</p>

        <h3>Autre sous‑section</h3>
        <p>Donec viverra mi quis quam pulvinar at malesuada arcu rhoncus. Cum soclis natoque penatibus et manis dis parturient montes, nascetur ridiculus mus. In rutrum accumsan ultricies. Mauris vitae nisi at sem facilisis semper ac in est.</p>
        <p>Vivamus fermentum semper porta. Nunc diam velit, adipscing ut tristique vitae sagittis vel odio. Maecenas convallis ullamcorper ultricied. Curabitur ornare, ligula semper consectetur sagittis, nisi diam iaculis velit, is fringille sem nunc vet mi.</p>
      </article>

      <!-- Le contenu « à côté » peut aussi être intégré dans le contenu
            principal -->
      <aside>
        <h2>En relation</h2>
        <ul>
          <li><a href="#">Combien j'aime être près des rivages</a></li>
          <li><a href="#">Combien j'aime être près de la mer</a></li>
          <li><a href="#">Bien que dans le nord de l'Angleterre</a></li>
          <li><a href="#">Il n'arrête jamais de pleuvoir</a></li>
          <li><a href="#">Eh bien…</a></li>
        </ul>
      </aside>

    </main>

    <!-- Et voici notre pied de page utilisé sur toutes les pages du site -->
    <footer>
      <p>©Copyright 2050 par personne. Tous droits reversés.</p>
    </footer>

  </body>
</html>''',
                    )),
          )
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
