import 'package:notary_model/model/files_spec.dart';
import 'package:notary_model/model/files_spec_input.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
part 'file_spec_service.g.dart';

@RestApi()
abstract class FileSpecService {
  factory FileSpecService(Dio dio) = _FileSpecService;
  @GET("/admin/files-spec")
  Future<List<FilesSpec>> getFileSpecs({
    @Query("size") int pageSize: 20,
    @Query("index") int pageIndex: 0,
  });
  @POST("/admin/files-spec")
  Future<FilesSpec> saveFileSpec(@Body() FilesSpecInput input);
  @GET("/admin/files-spec/count")
  Future<int> getFilesSpecCount();

  @DELETE("/admin/files-spec/{id}")
  Future<void> deleteFileSpec(@Path("id") String id);
}
