import 'package:notary_admin/src/pages/customer/form_and_view_html.dart';
import 'package:notary_admin/src/pages/file/load_file.dart';
import 'package:notary_admin/src/pages/home/home_page.dart';
import 'package:notary_admin/src/pages/profile_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:notary_admin/src/pages/login_page.dart';
import 'package:notary_admin/src/pages/not_found_page.dart';
import 'package:notary_admin/src/widgets/form_convert_map.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'settings/settings_controller.dart';
import 'package:month_year_picker/month_year_picker.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  void setLang(Locale locale) {
    widget.settingsController.updateLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          scrollBehavior: MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown
            },
            scrollbars: true,
            overscroll: true,
          ),
          useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          restorationScopeId: 'app',
          locale: widget.settingsController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MonthYearPickerLocalizations.delegate
          ],
          supportedLocales: widget.settingsController.supportedLocales,
          onGenerateTitle: (BuildContext context) => getLang(context).appName,
          theme: ThemeData(),
          //darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (context) {
                switch (settings.name) {
                  case "files":
                    return LoadFilePage();
                  case HomePage.home:
                    return HomePage();

                  case ProfilePage.routeName:
                    return const ProfilePage();

                  default:
                    return const NotFoundPage();
                }
              },
            );
          },
        );
      },
    );
  }
}
