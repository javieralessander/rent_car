import 'package:flutter/material.dart';
import '../models/vehicle_type_model.dart';
import '../services/vehicle_type_service.dart';

class VehicleTypeProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  VehicleTypeProvider() {
    cargarTiposVehiculos();
  }
  List<VehicleType> _todos = [];
  List<VehicleType> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<VehicleType> get tiposVehiculos => _pagina;
  List<VehicleType> get todosTiposVehiculos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<VehicleType> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (v) =>
              v.descripcion.toLowerCase().contains(_busqueda) ||
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

  Future<void> cargarTiposVehiculos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await VehicleTypeService.getAll();
      debugPrint('Tipos de vehículos recibidos: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron tipos de vehículos.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar tipos de vehículos: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar tipos de vehículos: $e';
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

  Future<void> agregarTipoVehiculo(VehicleType tipoVehiculo) async {
    try {
      final nuevo = await VehicleTypeService.create(tipoVehiculo);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar tipo de vehículo: $e');
    }
  }

  Future<void> actualizarTipoVehiculo(VehicleType tipoVehiculo) async {
    try {
      final actualizado = await VehicleTypeService.update(tipoVehiculo);
      final index = _todos.indexWhere((v) => v.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar tipo de vehículo: $e');
    }
  }

  Future<void> eliminarTipoVehiculo(int id) async {
    try {
      await VehicleTypeService.delete(id);
      _todos.removeWhere((v) => v.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar tipo de vehículo: $e');
    }
  }
}
