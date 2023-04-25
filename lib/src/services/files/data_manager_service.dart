import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'data_manager_service.g.dart';

@RestApi()
abstract class DataManagerService {
  factory DataManagerService(Dio dio) = _DataManagerService;

  @POST("/admin/manager/pdf/create/{pdfName}")
  Future<String> createPdfFromImageIds(
      @Body() List<String> imageIdsList, @Path("pdfName") String pdfName);

  @POST("/admin/manager/pdf/html/{pdfName}")
  Future<String> pdfFromImageIdsToHtml(
      @Body() List<String> imageIdsList, @Path("pdfName") String pdfName);

  @GET("/admin/manager/pdf/download/{pdfId}")
  Future<String> downloadPdfById(@Path("pdfId") String pdfId);

  @GET("/admin/manager/pdf/image/ids/{pdfId}")
  Future<List<String>> getPdfImageIds(@Path("pdfId") String pdfId);

  @POST("/admin/manager/image/rotate/{imageId}")
  Future<String> rotateImage(
      @Path("imageId") String imageId, @Query("angle") double angle);

  @GET("/admin/manager/image/base64/{imageId}")
  Future<String> getImageInBase64ById(@Path("imageId") String imageId);

  @GET("/admin/manager/docx-to-html/{docxId}")
  Future<String> wordToHtml(@Path("docxId") String docxId);

  @GET("/admin/manager/download/{id}")
  Future<String> downloadFilesById(@Path("id") String id);

  @DELETE("/admin/manager/delete/{id}")
  Future<void> deleteFileById(@Path("id") String id);
}
