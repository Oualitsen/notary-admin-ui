import 'package:dio/dio.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:retrofit/retrofit.dart';

part 'files_service.g.dart';

@RestApi()
abstract class FilesService {
  factory FilesService(Dio dio) = _FilesService;
  // @PUT("/upload/{id}/{fileSpecId}/{docSpecId}")
  // Future <Files> addDocSpec(@Path("id") String id,@Path("fileSpecId") String fileSpecId,
  // @Path("docSpecId")String docSpecId,@Query("document") <DocumentSpec> document);

  @POST("/admin/files")
  Future<Files> saveFiles(@Body() FilesInput files);
}
