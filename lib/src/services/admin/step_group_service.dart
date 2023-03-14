import 'package:dio/dio.dart';
import 'package:notary_model/model/step_group.dart';
import 'package:notary_model/model/step_group_input.dart';
import 'package:retrofit/http.dart';

part 'step_group_service.g.dart';

@RestApi()
abstract class StepGroupService {
    factory StepGroupService(Dio dio) = _StepGroupService;

  @GET("/admin/step-group")
  Future<List<StepGroup>> getStepGroupList(
    {
    @Query("size") int size: 20,
    @Query("index") int index: 0,
  });

  @POST("/admin/step-group")
  Future<StepGroup> saveStepGroup(@Body() StepGroupInput input);

  @GET("/admin/step-group/{id}")
  Future<StepGroup> getStepGroupById(@Path("id") String id);
  
  @GET("/admin/step-group/count")
  Future<int> getStepGroupCount();

  @DELETE("/admin/step-group/{id}")
  Future<void> delete(@Path("id") String id);
}
