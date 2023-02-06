import 'package:notary_model/model/assistant.dart';
import 'package:notary_model/model/assistant_input.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
part 'assistant_service.g.dart';

@RestApi()
abstract class AssistantService {
  factory AssistantService(Dio dio) = _AssistantService;
  @POST("/admin/assistant")
  Future<Assistant> saveAssistant(@Body() AssistantInput input);

  @GET("/admin/assistant/by-username")
  Future<Assistant> getByUsername(@Body() String text);

  @GET("/admin/assistant")
  Future<List<Assistant>> getAssistants(
      {required int pageIndex, required int pageSize});
}
