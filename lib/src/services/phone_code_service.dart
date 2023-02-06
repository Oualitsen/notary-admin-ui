import 'package:dio/dio.dart';
import 'package:rapidoc_utils/phone_number_input/phone_code.dart';
import 'package:retrofit/retrofit.dart';
part 'phone_code_service.g.dart';

@RestApi(baseUrl: "")
abstract class PhoneCodeService {
  factory PhoneCodeService(Dio dio) = _PhoneCodeService;

  @GET("/countries.json")
  Future<List<PhoneCode>> getPhoneCodes();
}
