import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/auth_result.dart';
import 'package:notary_model/model/password_change.dart';
import 'package:dio/dio.dart';
import 'package:notary_model/model/login_object.dart';
import 'package:retrofit/retrofit.dart';

part 'login_service.g.dart';

@RestApi()
abstract class LoginService {
  factory LoginService(Dio dio) = _LoginService;

  @POST("/auth/admin/login")
  Future<AuthResult<Admin>> login({
    @Body() required LoginObject loginObject,
  });

  @GET("/auth/admin/{userName}")
  Future<AuthResult<Admin>> testLogin(@Path("userName") int id);

  @POST("/auth/admin/recover-password")
  Future<AuthResult<Admin>> recoverPassword(
      @Body() PasswordChange passwordChange);
}
