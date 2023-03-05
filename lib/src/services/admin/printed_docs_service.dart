import 'package:dio/dio.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/printed_doc_input.dart';
import 'package:retrofit/http.dart';
part 'printed_docs_service.g.dart';

@RestApi()
abstract class PrintedDocService {
  factory PrintedDocService(Dio dio) = _PrintedDocService;
  @GET("/admin/printed")
  Future<List<PrintedDoc>> getAllPrinted({
    @Query("size") int pageSize: 20,
    @Query("index") int pageIndex: 0,
  });
  @GET("/admin/printed/count")
  Future<int> getPrintedDocsCount();
  @GET("/admin/printed/{id}")
  Future<PrintedDoc> getPrintedDocsById(@Path("id") String id);

  @POST("/admin/printed")
  Future<PrintedDoc> create(@Body() PrintedDocInput input);

  @DELETE("/admin/printed/{id}")
  Future<void> delete(@Path("id") String id);
}
