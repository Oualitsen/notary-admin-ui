import 'package:notary_model/model/auth_result.dart';
import 'package:notary_model/model/basic_user.dart';
import 'package:notary_model/model/password_change.dart';
import 'package:dio/dio.dart';
import 'package:notary_model/model/login_object.dart';
import 'package:retrofit/retrofit.dart';

part 'login_service.g.dart';

@RestApi()
abstract class LoginService {
  factory LoginService(Dio dio) = _LoginService;

  @POST("/auth/admin/login")
  Future<AuthResult<BasicUser>> login({
    @Body() required LoginObject loginObject,
  });

  @GET("/auth/admin/{userName}")
  Future<AuthResult<BasicUser>> testLogin(@Path("userName") int id);

  @POST("/auth/admin/recover-password")
  Future<AuthResult<BasicUser>> recoverPassword(
      @Body() PasswordChange passwordChange);
}
