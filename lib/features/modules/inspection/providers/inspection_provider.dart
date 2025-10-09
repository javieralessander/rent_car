import 'package:flutter/material.dart';
import '../models/inspection_model.dart';
import '../services/inspection_service.dart';

class InspectionProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;

  InspectionProvider() {
    cargarInspecciones();
  }
  List<Inspection> _todos = [];
  List<Inspection> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<Inspection> get inspecciones => _pagina;
  List<Inspection> get todasInspecciones => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Inspection> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (i) =>
              i.vehiculo.toString().contains(_busqueda) ||
              i.cliente.toString().contains(_busqueda) ||
              i.estado.toString().toLowerCase().contains(_busqueda),
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

  Future<void> cargarInspecciones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await InspectionService.getAll();
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron inspecciones.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar inspecciones: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar inspecciones: $e';
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

  Future<void> agregarInspeccion(Inspection inspeccion) async {
    try {
      final nueva = await InspectionService.create(inspeccion);
      _todos.add(nueva);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar inspección: $e');
    }
  }

  Future<void> actualizarInspeccion(Inspection inspeccion) async {
    try {
      final actualizada = await InspectionService.update(inspeccion);
      final index = _todos.indexWhere((i) => i.id == actualizada.id);
      if (index != -1) {
        _todos[index] = actualizada;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar inspección: $e');
    }
  }

  Future<void> eliminarInspeccion(int id) async {
    try {
      await InspectionService.delete(id);
      _todos.removeWhere((i) => i.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar inspección: $e');
    }
  }
}
