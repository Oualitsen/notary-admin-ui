import 'package:notary_model/model/contract_category.dart';
import 'package:notary_model/model/contract_category_input.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'contract_category_service.g.dart';

@RestApi()
abstract class ContractCategoryService {
  factory ContractCategoryService(Dio dio) = _ContractCategoryService;

  @POST("/admin/contract-category/create")
  Future<ContractCategory> saveContractCategory(
      @Body() ContractCategoryInput input);

  @GET("/admin/contract-category")
  Future<List<ContractCategory>> getContractCategory({
    @Query("size") int pageSize: 20,
    @Query("index") int pageIndex: 0,
  });

  @DELETE("/admin/contract-category/{id}")
  Future<void> deleteContractCategory(@Path("id") String id);
}
