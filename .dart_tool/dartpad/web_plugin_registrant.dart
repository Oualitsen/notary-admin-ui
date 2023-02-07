// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:devicelocale/devicelocale_web.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_messaging_web/firebase_messaging_web.dart';
import 'package:flutter_keyboard_visibility_web/flutter_keyboard_visibility_web.dart';
import 'package:geolocator_web/geolocator_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:image_cropper_for_web/image_cropper_for_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:maps_launcher/maps_launcher_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:wakelock_web/wakelock_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  DevicelocaleWeb.registerWith(registrar);
  FilePickerWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FirebaseMessagingWeb.registerWith(registrar);
  FlutterKeyboardVisibilityPlugin.registerWith(registrar);
  GeolocatorPlugin.registerWith(registrar);
  GoogleMapsPlugin.registerWith(registrar);
  ImageCropperPlugin.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  MapsLauncherWeb.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  WakelockWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
