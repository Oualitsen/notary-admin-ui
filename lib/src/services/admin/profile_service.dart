import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/password_change.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_service.g.dart';

@RestApi()
abstract class ProfileService {
  factory ProfileService(Dio dio) = _ProfileService;

  @GET("admin/profile")
  Future<Admin> getCurrentUser();

  @PUT("/admin/profile/reset_password")
  Future<Admin> updateAdminPassword({@Body() required PasswordChange password});

  // @PUT("admin/profile")
  // Future<Holidays> updateInfo(@Body() AdminInfoInput input);
}
