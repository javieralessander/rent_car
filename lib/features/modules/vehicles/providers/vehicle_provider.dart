import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  VehicleProvider() {
    cargarVehiculos();
  }
  List<Vehicle> _todos = [];
  List<Vehicle> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<Vehicle> get vehiculos => _pagina;
  List<Vehicle> get todosVehiculos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Vehicle> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (v) =>
              v.descripcion.toLowerCase().contains(_busqueda) ||
              v.numeroPlaca.toLowerCase().contains(_busqueda) ||
              v.numeroChasis.toLowerCase().contains(_busqueda) ||
              v.estado.toString().toLowerCase().contains(_busqueda),
        )
        .toList();
  }

  int get totalRegistros => _filtrados.length;
  int get totalPaginas => (totalRegistros / _registrosPorPagina).ceil();
  int get inicio => (_paginaActual - 1) * _registrosPorPagina;
  int get fin => (_paginaActual * _registrosPorPagina).clamp(0, totalRegistros);

  set busqueda(String value) {
    _busqueda = value.toLowerCase();
    _paginaActual = 1;
    _actualizarPagina();
  }

  Future<void> cargarVehiculos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await VehicleService.getAll();
      debugPrint('Vehículos recibidos: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron vehículos.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar vehículos: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar vehículos: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _actualizarPagina() {
    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      if (_pagina.isNotEmpty || _paginaActual != 1) {
        _paginaActual = 1;
        _pagina = [];
        notifyListeners();
      }
      return;
    }
    if (_paginaActual > totalPaginas) {
      _paginaActual = 1;
    }
    final start = inicio;
    final end = fin > filtrados.length ? filtrados.length : fin;
    _pagina = filtrados.sublist(start, end);
    notifyListeners();
  }

  void cambiarPagina(int nuevaPagina) {
    if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas) {
      _paginaActual = nuevaPagina;
      _actualizarPagina();
    }
  }

  void cambiarRegistrosPorPagina(int cantidad) {
    _registrosPorPagina = cantidad;
    _paginaActual = 1;
    _actualizarPagina();
  }

  Future<void> agregarVehiculo(Vehicle vehiculo) async {
    try {
      final nuevo = await VehicleService.create(vehiculo);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar vehículo: $e');
    }
  }

  Future<void> actualizarVehiculo(Vehicle vehiculo) async {
    try {
      final actualizado = await VehicleService.update(vehiculo);
      final index = _todos.indexWhere((v) => v.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar vehículo: $e');
    }
  }

  Future<void> eliminarVehiculo(int id) async {
    try {
      await VehicleService.delete(id);
      _todos.removeWhere((v) => v.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar vehículo: $e');
    }
  }
}
