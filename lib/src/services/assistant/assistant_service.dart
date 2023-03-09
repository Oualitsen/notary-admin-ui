import 'package:notary_model/model/admin.dart';
import 'package:notary_model/model/assistant.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
part 'assistant_service.g.dart';

@RestApi()
abstract class AssistantService {
  factory AssistantService(Dio dio) = _AssistantService;
  @POST("/admin/assistant")
  Future<Admin> saveAssistant(@Body() AssistantInput input);

  @GET("/admin/assistant/by-username")
  Future<Admin> getByUsername(@Body() String text);

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
}
