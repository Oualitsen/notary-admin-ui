import 'package:dio/dio.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/steps.dart';
import 'package:retrofit/retrofit.dart';

part 'files_service.g.dart';

@RestApi()
abstract class FilesService {
  factory FilesService(Dio dio) = _FilesService;

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

  @GET("/admin/files/load/{filesId}/{partId}/{docId}")
  Future<String> loadFileDocuments(
    @Path("filesId") String filesId,
    @Path("partId") String partId,
    @Path("docId") String docId,
  );

  @GET("/admin/files/printed/{filesId}")
  Future<PrintedDoc> getPrintedDoc(@Path("filesId") String filesId);

  @PUT("/admin/files/current-step/{filesId}")
  Future<Files> updateCurrentStep(
      @Path("filesId") String filesId, @Body() Steps newStep);

  @PUT("/admin/files/archive/{id}")
  Future archiveFiles(@Path("id") String id);

  @GET("/admin/files/search")
  Future<List<Files>> searchFiles({
    @Query("number") required String number,
    @Query("filesSpecName") required String filesSpecName,
    @Query("customerIds") required String customerIds,
    @Query("startDate") required int startDate,
    @Query("endDate") required int endDate,
  });

  @GET("/admin/files/search/count")
  Future<int> countSearchFiles({
    @Query("number") required String number,
    @Query("filesSpecName") required String filesSpecName,
    @Query("customerIds") required String customerIds,
    @Query("startDate") required int startDate,
    @Query("endDate") required int endDate,
  });
}
