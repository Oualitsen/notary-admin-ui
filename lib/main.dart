import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:notary_admin/src/init.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

final myAppKey = GlobalKey<MyAppState>();
final settingsController = SettingsController(SettingsService());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await settingsController.loadSettings();

  await initDio();
  initServices();
  runApp(DevicePreview(
    builder: (c) => MyApp(
      settingsController: settingsController,
      key: myAppKey,
    ),
    enabled: false,
  ));
}
