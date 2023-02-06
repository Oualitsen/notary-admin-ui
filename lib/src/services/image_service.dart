import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'image_service.g.dart';

@RestApi()
abstract class ImageService {
  factory ImageService(Dio dio) = _ImageService;
}
