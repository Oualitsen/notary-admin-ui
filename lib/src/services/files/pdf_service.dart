import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'pdf_service.g.dart';

@RestApi()
abstract class PdfService {
  factory PdfService(Dio dio) = _PdfService;

  @POST("/admin/pdf/image/rotate/{imageId}")
  Future<String> rotateImage(
      @Path("imageId") String imageId, @Query("angle") double angle);

  @GET("/admin/pdf/image/ids/{pdfId}")
  Future<List<String>> getPdfImages(@Path("pdfId") String pdfId);

  @GET("/admin/pdf/docx/{docxId}")
  Future<String> wordToHtml(@Path("docxId") String docxId);
}
