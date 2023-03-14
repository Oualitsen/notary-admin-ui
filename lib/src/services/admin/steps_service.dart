import 'package:dio/dio.dart';
import 'package:notary_model/model/step_group.dart';
import 'package:notary_model/model/step_group_input.dart';
import 'package:notary_model/model/step_input.dart';
import 'package:notary_model/model/steps.dart';
import 'package:retrofit/http.dart';

part 'steps_service.g.dart';

@RestApi()
abstract class StepsService {
    factory StepsService(Dio dio) = _StepsService;

  @GET("/admin/step")
  Future<List<Steps>> getStepList(
    {
    @Query("size") int size: 20,
    @Query("index") int index: 0,
  });

  @POST("/admin/step")
  Future<Steps> saveStep(@Body() StepInput input);

  @GET("/admin/step/{id}")
  Future<Steps> getStepById(@Path("id") String id);
  
  @GET("/admin/step/count")
  Future<int> getStepCount();

  @DELETE("/admin/step/{id}")
  Future<void> delete(@Path("id") String id);
}