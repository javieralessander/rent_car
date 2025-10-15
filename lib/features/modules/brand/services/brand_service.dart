import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/brand_model.dart';

class BrandService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Brand>> getAll() async {
    return await _client.getList<Brand>(
      '/marcas',
      (e) => Brand.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Brand?> getById(int id) async {
    return await _client.get<Brand>(
      '/marcas/$id',
      (e) => Brand.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Brand> create(Brand marca) async {
    return await _client.post<Brand>(
      '/marcas',
      marca.toJson(),
      (e) => Brand.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/marcas/$id');
  }

  static Future<Brand> update(Brand marca) async {
    return await _client.put<Brand>(
      '/marcas/${marca.id}',
      marca.toJson(),
      (e) => Brand.fromJson(e as Map<String, dynamic>),
    );
  }
}
