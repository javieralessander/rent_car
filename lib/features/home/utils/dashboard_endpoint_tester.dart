import 'package:rent_car/core/config/http_api_client.dart';
import 'package:rent_car/core/config/env.dart';

/// Clase para probar la conectividad de los endpoints del dashboard
class DashboardEndpointTester {
  final HttpApiClient _httpClient;

  DashboardEndpointTester() : _httpClient = HttpApiClient(Environment.apiUrl);

  /// Prueba todos los endpoints y muestra el resultado
  Future<void> testAllEndpoints() async {
    print('=== PROBANDO CONECTIVIDAD DE ENDPOINTS ===');
    print('API Base URL: ${Environment.apiUrl}');
    print('');

    await _testEndpoint('/articulos', 'Artículos');
    await _testEndpoint('/proveedores', 'Proveedores');
    await _testEndpoint('/ordenescompra', 'Órdenes de Compra');
    await _testEndpoint('/solicitudes', 'Solicitudes');

    print('=== FIN DE PRUEBAS ===');
  }

  /// Prueba un endpoint específico
  Future<void> _testEndpoint(String endpoint, String description) async {
    try {
      print('🔄 Probando: $description ($endpoint)');
      final response = await _httpClient.getList<dynamic>(
        endpoint,
        (json) => json, // Simplemente devolver el JSON sin parsear
      );

      print(' $description: OK - ${response.length} elementos');
      if (response.isNotEmpty && response.length > 0) {
        print('   📄 Ejemplo del primer elemento:');
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic>) {
          firstItem.forEach((key, value) {
            print('      $key: $value');
          });
        }
      }
      print('');
    } catch (e) {
      print('$description: ERROR');
      print('   Error: $e');
      print('');
    }
  }

  /// Prueba solo un endpoint específico
  Future<void> testSingleEndpoint(String endpoint, String description) async {
    print('=== PROBANDO ENDPOINT INDIVIDUAL ===');
    await _testEndpoint(endpoint, description);
  }
}

/// Función helper para probar endpoints desde el main o cualquier lugar
Future<void> testDashboardEndpoints() async {
  final tester = DashboardEndpointTester();
  await tester.testAllEndpoints();
}
