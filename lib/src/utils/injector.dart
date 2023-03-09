import 'package:get_it/get_it.dart';
import 'package:notary_model/model/basic_user.dart';
import 'package:rapidoc_utils/managers/auth_manager.dart';

abstract class Injector {
  static AuthManager<BasicUser> provideAuthManager() {
    return GetIt.instance.get<AuthManager<BasicUser>>();
  }
}
