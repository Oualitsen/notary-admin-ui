import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/documents.dart';
import 'package:notary_model/model/files.dart';
import 'package:notary_model/model/files_archive.dart';
import 'package:notary_model/model/files_archive_input.dart';
import 'package:notary_model/model/files_input.dart';
import 'package:notary_model/model/printed_doc.dart';
import 'package:notary_model/model/steps.dart';
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

  @GET("/admin/archive/{id}")
  Future<FilesArchive> getFileArchiveById(@Path("id") String id);

  @GET("/admin/archive/number")
  Future<FilesArchive> getFilesArchiveByNumber(@Query("number") String number);

  @GET("/admin/archive/count")
  Future<int> getFilesArchiveCount();

  @DELETE("/admin/archive/{id}")
  Future<void> delete(@Path("id") String id);

  @GET("/admin/archive/archive-date")
  Future<List<FilesArchive>> getFilesArchiveByDate(
      @Query("startDate") int startDate, @Query("endDate") int endDate);

  @GET("/admin/archive/archive-date/count")
  Future<int> getCountFilesArchiveByDate(
      @Query("startDate") int startDate, @Query("endDate") int endDate);

  @GET("/admin/archive/printed-doc/{archiveId}")
  Future<PrintedDoc> getPrintedDocsById(
    @Path("archiveId") String archiveId,
  );
}
