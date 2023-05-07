import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
part 'admin_assistant_service.g.dart';

@RestApi()
abstract class AdminAssistantService {
  factory AdminAssistantService(Dio dio) = _AdminAssistantService;
  @POST("/admin/assistant")
  Future<Admin> saveAssistant(@Body() AssistantInput input);

  @GET("/admin/assistant")
  Future<List<Admin>> getAssistants(
      {@Query("index") required int index, @Query("size") required int size});

  @PUT("/admin/assistant/{id}")
  Future<Admin> ResetPasswordAssistant(
      @Path("id") String id, @Body() String password);

  @GET("/admin/assistant/count")
  Future<int> getAssistantsCount();

  @DELETE("/admin/assistant/{id}")
  Future<void> deleteAssistant(@Path("id") String id);

  @GET("/admin/assistant/search")
  Future<List<Admin>> searchAssistant({
    @Query("name") required String name,
    @Query("index") required int index,
    @Query("size") required int size,
  });

  @GET("/admin/assistant/search/count")
  Future<int> searchCount({@Query("name") required String name});
}
