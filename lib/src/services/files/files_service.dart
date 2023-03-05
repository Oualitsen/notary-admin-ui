import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/documents.dart';
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
  @GET("/admin/files")
  Future<List<Files>> getFilesAll(
      {@Query("size") int pageSize: 20, @Query("index") int pageIndex: 0});

  @GET("/admin/files/count")
  Future<int> getFilesCount();

  @DELETE("/admin/files/{id}")
  Future<void> deleteFile(@Path("id") String id);
  @GET("/admin/files/customer/{filesId}")
  Future<List<Customer>> getFilesCustomers(@Path("filesId") String filesId);

  @GET("/admin/files/load/{filesId}")
  Future<List<String>> loadFileDocuments(@Path("filesId") String filesId);
  
 
    
}
