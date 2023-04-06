import 'package:dio/dio.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:notary_model/model/files_archive_input.dart';
import 'package:retrofit/retrofit.dart';

part 'files_archive_service.g.dart';

@RestApi()
abstract class FilesArchiveService {
  factory FilesArchiveService(Dio dio) = _FilesArchiveService;
  @GET("/admin/archive")
  Future<List<FilesArchive>> getFilesArchive(
      {@Query("size") int pageSize: 20, @Query("index") int pageIndex: 0});

  @POST("/admin/archive")
  Future<FilesArchive> saveFilesArchive(@Body() FilesArchiveInput input);

  @GET("/admin/archive/documents/{archiveId}")
  Future<List<String>> getDocumentsName(@Path("archiveId") String archiveId);

  @GET("/admin/archive/{id}")
  Future<FilesArchive> getFileArchiveById(@Path("id") String id);

  @GET("/admin/archive/number")
  Future<FilesArchive> getFilesArchiveByNumber(@Query("number") String number);

  @GET("/admin/archive/count")
  Future<int> getFilesArchiveCount();

  @DELETE("/admin/archive/{id}")
  Future<void> delete(@Path("id") String id);

  @GET("/admin/archive/date")
  Future<List<FilesArchive>> getFilesArchiveByDate(
      @Query("startDate") int startDate, @Query("endDate") int endDate);

  @GET("/admin/archive/date/count")
  Future<int> getCountFilesArchiveByDate(
      @Query("startDate") int startDate, @Query("endDate") int endDate);

  @GET("/admin/archive/pdf/images/ids/{pdfId}")
  Future<List<String>> getPdfImages(@Path("pdfId") String pdfId);

  @POST("/admin/archive/rotate/{imageId}")
  Future<void> rotateImage(
      @Path("imageId") String imageId, @Query("angle") double angle);
}
