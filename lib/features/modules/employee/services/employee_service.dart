import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/employee_model.dart';

class EmployeeService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Employee>> getAll() async {
    return await _client.getList<Employee>(
      '/empleados',
      (e) => Employee.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Employee?> getById(int id) async {
    try {
      return await _client.get<Employee>(
        '/empleados/$id',
        (e) => Employee.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Employee?> getByCedula(String cedula) async {
    try {
      return await _client.get<Employee>(
        '/empleados/cedula/$cedula',
        (e) => Employee.fromJson(e as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Employee> create(Employee empleado) async {
    return await _client.post<Employee>(
      '/empleados',
      empleado.toJson(),
      (e) => Employee.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/empleados/$id');
  }

  static Future<Employee> update(Employee empleado) async {
    return await _client.put<Employee>(
      '/empleados/${empleado.id}',
      empleado.toJson(),
      (e) => Employee.fromJson(e as Map<String, dynamic>),
    );
  }
}
