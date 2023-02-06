import 'package:notary_model/model/admin.dart';
import 'package:get_it/get_it.dart';
import 'package:rapidoc_utils/managers/auth_manager.dart';

abstract class Injector {
  static AuthManager<Admin> provideAuthManager() {
    return GetIt.instance.get<AuthManager<Admin>>();
  }
}
