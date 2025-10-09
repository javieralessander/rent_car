import 'package:flutter/material.dart';
import '../models/model_model.dart';
import '../services/model_service.dart';

class ModelProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  ModelProvider() {
    cargarModelos();
  }
  List<VehicleModel> _todos = [];
  List<VehicleModel> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<VehicleModel> get modelos => _pagina;
  List<VehicleModel> get todosModelos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<VehicleModel> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (m) =>
              m.descripcion.toLowerCase().contains(_busqueda) ||
              m.estado.toString().toLowerCase().contains(_busqueda),
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

  Future<void> cargarModelos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ModelService.getAll();
      debugPrint('Modelos recibidos: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron modelos.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar modelos: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar modelos: $e';
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

  Future<void> agregarModelo(VehicleModel modelo) async {
    try {
      final nuevo = await ModelService.create(modelo);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar modelo: $e');
    }
  }

  Future<void> actualizarModelo(VehicleModel modelo) async {
    try {
      final actualizado = await ModelService.update(modelo);
      final index = _todos.indexWhere((m) => m.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar modelo: $e');
    }
  }

  Future<void> eliminarModelo(int id) async {
    try {
      await ModelService.delete(id);
      _todos.removeWhere((m) => m.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar modelo: $e');
    }
  }
}
