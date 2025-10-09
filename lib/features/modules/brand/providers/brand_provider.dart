import 'package:flutter/material.dart';
import '../models/brand_model.dart';
import '../services/brand_service.dart';

class BrandProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  BrandProvider() {
    cargarMarcas();
  }
  List<Brand> _todos = [];
  List<Brand> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<Brand> get marcas => _pagina;
  List<Brand> get todasMarcas => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Brand> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where((m) => m.descripcion.toLowerCase().contains(_busqueda))
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

  Future<void> cargarMarcas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await BrandService.getAll();
      debugPrint('Marcas recibidas: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron marcas.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar marcas: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar marcas: $e';
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

  Future<void> agregarMarca(Brand marca) async {
    try {
      final nuevo = await BrandService.create(marca);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar marca: $e');
    }
  }

  Future<void> actualizarMarca(Brand marca) async {
    try {
      final actualizado = await BrandService.update(marca);
      final index = _todos.indexWhere((m) => m.id == marca.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error al actualizar marca: $e');
    }
  }

  Future<void> eliminarMarca(int id) async {
    try {
      await BrandService.delete(id);
      _todos.removeWhere((m) => m.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar marca: $e');
    }
  }
}
