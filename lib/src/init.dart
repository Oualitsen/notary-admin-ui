import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:notary_admin/src/services/admin/customer_service.dart';
import 'package:notary_admin/src/services/admin/printed_docs_service.dart';
import 'package:notary_admin/src/services/admin/profile_service.dart';
import 'package:notary_admin/src/services/admin/steps_service.dart';
import 'package:notary_admin/src/services/admin/template_document_service.dart';
import 'package:notary_admin/src/services/assistant/admin_assistant_service.dart';
import 'package:notary_admin/src/services/files/file_spec_service.dart';
import 'package:notary_admin/src/services/files/files_archive_service.dart';
import 'package:notary_admin/src/services/files/files_service.dart';
import 'package:notary_admin/src/services/files/data_manager_service.dart';
import 'package:notary_model/model/basic_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notary_admin/src/db_services/token_db_service.dart';
import 'package:notary_admin/src/services/login_service.dart';
import 'package:notary_admin/src/services/phone_code_service.dart';
import 'package:notary_admin/src/services/upload_service.dart';
import 'package:notary_admin/src/utils/http_interceptor.dart';
import 'package:rapidoc_utils/managers/auth_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:cookie_jar/cookie_jar.dart';

//const devUrlBase = "192.168.9.4:8080";
const devUrlBase = "localhost:8080";
const emuUrlBase = "10.0.2.2:8080";
const prodUrlBase = "ams.bms-data-collector.info";

const bool devMode = true;
const bool isEmulator = true;

RegExp emailRegExp = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
);

String getUrlBase() => (devMode ? "http://" : "https://") + getServerAddress();
String getServerAddress() {
  if (kIsWeb) {
    if (devMode) {
      return devUrlBase;
    }
    return html.window.location.host;
  }
  return devMode ? (isEmulator ? emuUrlBase : devUrlBase) : prodUrlBase;
}

Future<void> initDio() async {
  GetIt.instance.registerSingleton(TokenDbService());

  GetIt instance = GetIt.instance;
  Dio dio = Dio(BaseOptions(baseUrl: getUrlBase()));
  CookieJar jar;
  if (kIsWeb) {
    jar = CookieJar();
    CookieManager manager = CookieManager(jar);
    dio.interceptors.add(manager);
  } else {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    jar = PersistCookieJar(storage: FileStorage(appDocPath));
    dio.interceptors.add(CookieManager(jar));
  }
  instance.registerSingleton(jar);
  dio.interceptors.add(HttpInterceptor());
  dio.options.baseUrl = getUrlBase();
  instance.registerSingleton(dio);
}

void initServices() {
  Dio dio = GetIt.instance.get();

  GetIt.instance.registerSingleton(LoginService(dio));
  GetIt.instance.registerSingleton(FileSpecService(dio));
  GetIt.instance.registerSingleton(ProfileService(dio));
  GetIt.instance.registerSingleton(UploadService(dio));
  GetIt.instance.registerSingleton(PhoneCodeService(dio));
  GetIt.instance.registerSingleton(CustomerService(dio));
  GetIt.instance.registerSingleton(TemplateDocumentService(dio));
  GetIt.instance.registerSingleton(AdminAssistantService(dio));
  GetIt.instance.registerSingleton(FilesService(dio));
  GetIt.instance.registerSingleton(PrintedDocService(dio));
  GetIt.instance.registerSingleton(StepsService(dio));
  GetIt.instance.registerSingleton(FilesArchiveService(dio));
  GetIt.instance.registerSingleton(DataManagerService(dio));

  GetIt.instance.registerSingleton(
    AuthManager<BasicUser>(
      parser: (json) => BasicUser.fromJson(json),
      serializer: (client) => client.toJson(),
      getUserFromServer: (BasicUser? current) async {
        final _svc = GetIt.instance.get<ProfileService>();
        return _svc.getCurrentUser();
      },
    ),
  );
}

String? getImageUrl(String? imageId, [int? size = 1024]) {
  return _getMediaUrl(imageId, true, size);
}

String getVideoUrl(String? imageId) {
  return _getMediaUrl(imageId, false, null)!;
}

String? _getMediaUrl(String? imageId, bool image, [int? size = 1024]) {
  if (imageId == null || imageId.isEmpty) {
    return null;
  }

  String _imageId = imageId;

  if (devMode) {
    if (isEmulator) {
      _imageId = _imageId.replaceFirst("http://localhost", "http://10.0.2.2");
    }
  }

  if (!_imageId.startsWith("http")) {
    _imageId = "${getUrlBase()}/${image ? 'image' : 'video'}/$_imageId";
  }

  String result;

  if (size != null) {
    result = "$_imageId?size=$size";
  } else {
    result = _imageId;
  }

  if (!devMode) {
    result = result.replaceFirst("localhost", "197.140.16.226");
  }

  return result;
}

String getFlagUrl(String name) {
  return "${getUrlBase()}/flags/${name.toLowerCase()}.png";
}
