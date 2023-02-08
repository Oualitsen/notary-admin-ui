import 'package:dio/dio.dart';
import 'package:notary_model/model/template_document.dart';
import 'package:retrofit/http.dart';
part 'template_document_service.g.dart';

@RestApi()
abstract class TemplateDocumentService {
  factory TemplateDocumentService(Dio dio) = _TemplateDocumentService;
  @GET("/admin/template")
  Future<List<TemplateDocument>> getFiles({
    @Query("size") int pageSize: 20,
    @Query("index") int pageIndex: 0,
  });

  @PUT("/admin/template/{id}")
  Future<TemplateDocument> updateName(
    @Path("id") String id,
    @Body() String name,
  );
  @PUT("/admin/template/html/{id}")
  Future<TemplateDocument> updateHtmlData(
    @Path("id") String id,
    @Body() String newHtmlData,
  );
}
