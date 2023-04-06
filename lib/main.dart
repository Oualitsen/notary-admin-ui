import 'dart:isolate';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:notary_admin/src/init.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

final myAppKey = GlobalKey<MyAppState>();
final settingsController = SettingsController(SettingsService());

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send!.send([id, status, progress]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
    FlutterDownloader.registerCallback(downloadCallback);
  }
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
