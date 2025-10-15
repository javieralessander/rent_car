import 'package:flutter/material.dart';
import '../models/fuel_type_model.dart';
import '../services/fuel_type_service.dart';

class FuelTypeProvider extends ChangeNotifier {
  FuelTypeProvider() {
    cargarTiposCombustible();
  }
  List<FuelType> _todos = [];
  List<FuelType> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<FuelType> get tiposCombustible => _pagina;
  List<FuelType> get todosTiposCombustible => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<FuelType> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (f) =>
              f.descripcion.toLowerCase().contains(_busqueda) ||
              f.estado.toString().toLowerCase().contains(_busqueda),
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

  String? _error;
  String? get error => _error;

  Future<void> cargarTiposCombustible() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await FuelTypeService.getAll();
      debugPrint('Tipos de combustible recibidos: \\n$data');
      _todos = data;
      // Lista vacía es un estado válido, no un error
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar tipos de combustible: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar tipos de combustible: $e';
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

  Future<void> agregarTipoCombustible(FuelType tipoCombustible) async {
    try {
      final nuevo = await FuelTypeService.create(tipoCombustible);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar tipo de combustible: $e');
    }
  }

  Future<void> actualizarTipoCombustible(FuelType tipoCombustible) async {
    try {
      final actualizado = await FuelTypeService.update(tipoCombustible);
      final index = _todos.indexWhere((f) => f.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar tipo de combustible: $e');
    }
  }

  Future<void> eliminarTipoCombustible(int id) async {
    try {
      await FuelTypeService.delete(id);
      _todos.removeWhere((f) => f.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar tipo de combustible: $e');
    }
  }
}
