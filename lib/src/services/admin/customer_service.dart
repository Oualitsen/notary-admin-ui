import 'package:dio/dio.dart';
import 'package:notary_model/model/customer.dart';
import 'package:notary_model/model/customer_input.dart';
import 'package:notary_model/model/files.dart';
import 'package:retrofit/http.dart';
part 'customer_service.g.dart';

@RestApi()
abstract class CustomerService {
  factory CustomerService(Dio dio) = _CustomerService;
  @GET("/admin/customers")
  Future<List<Customer>> getCustomers({
    @Query("size") int pageSize: 20,
    @Query("index") int pageIndex: 0,
  });
  @GET("/admin/customers/count")
  Future<int> getCustomersCount();
  @GET("/admin/customers/{id}")
  Future<Customer> getCustomer(@Path("id") String id);

  @POST("/admin/customers")
  Future<Customer> saveCustomer(@Body() CustomerInput input);

  @DELETE("/admin/customers/{id}")
  Future<void> deleteCustomer(@Path("id") String id);

  @GET("/admin/customers/files/{id}")
  Future<List<Files>> getFilesByCustomerId(@Path("id") String id);
  @GET("/admin/customers/search")
  Future<List<Customer>> searchCustomers({
    @Query("name") required String name,
    @Query("index") required int index,
    @Query("size") required int size,
  });

  @GET("/admin/customers/search/count")
  Future<int> searchCount({@Query("name") required String name});
}
