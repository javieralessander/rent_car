import 'dart:async';
import 'package:flutter/material.dart';

/// Proveedor base genérico para colecciones con paginación, búsqueda y CRUD
abstract class BaseCollectionProvider<T> extends ChangeNotifier {
  List<T> _todos = [];
  List<T> _pagina = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;
  String _busqueda = '';
  Timer? _debounceTimer;

  // Getters públicos
  List<T> get items => _pagina;
  List<T> get allItems => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;
  String get busqueda => _busqueda;

  // Getters calculados
  List<T> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos.where((item) => matchesSearch(item, _busqueda)).toList();
  }

  int get totalRegistros => _filtrados.length;
  int get totalPaginas => totalRegistros == 0 ? 1 : (totalRegistros / _registrosPorPagina).ceil();
  int get inicio => (_paginaActual - 1) * _registrosPorPagina;
  int get fin => (_paginaActual * _registrosPorPagina).clamp(0, totalRegistros);
  bool get isEmpty => _todos.isEmpty && !_isLoading;
  bool get hasData => _todos.isNotEmpty;

  // Métodos abstractos que deben implementar las clases hijas
  Future<List<T>> fetchAll();
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(dynamic id);
  bool matchesSearch(T item, String searchTerm);
  dynamic getId(T item);

  /// Inicialización diferida - no cargar en constructor
  Future<void> initialize() async {
    if (!_isInitialized) {
      await loadItems();
      _isInitialized = true;
    }
  }

  /// Carga los elementos desde el servicio
  Future<void> loadItems({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final data = await fetchAll();
      _todos = data;
      _updatePage();
      _error = null;
    } catch (e) {
      debugPrint('Error al cargar elementos: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar datos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza la página actual basada en filtros y paginación
  void _updatePage() {
    final filtrados = _filtrados;

    if (filtrados.isEmpty) {
      if (_pagina.isNotEmpty || _paginaActual != 1) {
        _paginaActual = 1;
        _pagina = [];
        notifyListeners();
      }
      return;
    }

    // Ajustar página si es mayor al total disponible
    if (_paginaActual > totalPaginas) {
      _paginaActual = 1;
    }

    final start = inicio;
    final end = fin > filtrados.length ? filtrados.length : fin;
    _pagina = filtrados.sublist(start, end);
    notifyListeners();
  }

  /// Cambia la página actual
  void changePage(int nuevaPagina) {
    if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas && nuevaPagina != _paginaActual) {
      _paginaActual = nuevaPagina;
      _updatePage();
    }
  }

  /// Cambia la cantidad de registros por página
  void changeItemsPerPage(int cantidad) {
    if (cantidad != _registrosPorPagina && cantidad > 0) {
      _registrosPorPagina = cantidad;
      _paginaActual = 1;
      _updatePage();
    }
  }

  /// Establece el término de búsqueda con debounce
  void setSearch(String value, {Duration debounce = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(debounce, () {
      if (value.toLowerCase() != _busqueda) {
        _busqueda = value.toLowerCase();
        _paginaActual = 1;
        _updatePage();
      }
    });
  }

  /// Búsqueda inmediata sin debounce
  void searchImmediate(String value) {
    _debounceTimer?.cancel();
    _busqueda = value.toLowerCase();
    _paginaActual = 1;
    _updatePage();
  }

  /// Agrega un nuevo elemento
  Future<bool> addItem(T item) async {
    try {
      _setLoading(true);
      final nuevo = await create(item);
      _todos.add(nuevo);
      _updatePage();
      _error = null;
      return true;
    } catch (e) {
      debugPrint('Error al agregar elemento: $e');
      _error = 'Error al agregar: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza un elemento existente
  Future<bool> updateItem(T item) async {
    try {
      _setLoading(true);
      final actualizado = await update(item);
      final id = getId(actualizado);
      final index = _todos.indexWhere((element) => getId(element) == id);

      if (index != -1) {
        _todos[index] = actualizado;
        _updatePage();
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al actualizar elemento: $e');
      _error = 'Error al actualizar: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un elemento
  Future<bool> removeItem(dynamic id) async {
    try {
      _setLoading(true);
      await delete(id);
      _todos.removeWhere((element) => getId(element) == id);
      _updatePage();
      _error = null;
      return true;
    } catch (e) {
      debugPrint('Error al eliminar elemento: $e');
      _error = 'Error al eliminar: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Encuentra un elemento por ID
  T? findById(dynamic id) {
    try {
      return _todos.firstWhere((element) => getId(element) == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresca los datos desde el servidor
  Future<void> refresh() async {
    await loadItems(showLoading: false);
  }

  /// Limpia el error actual
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Resetea la búsqueda
  void clearSearch() {
    if (_busqueda.isNotEmpty) {
      _debounceTimer?.cancel();
      _busqueda = '';
      _paginaActual = 1;
      _updatePage();
    }
  }

  /// Resetea la paginación a la primera página
  void resetPagination() {
    if (_paginaActual != 1) {
      _paginaActual = 1;
      _updatePage();
    }
  }

  /// Establece el estado de carga
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Método de utilidad para aplicar filtros personalizados
  void applyCustomFilter(bool Function(T) filter) {
    final filtered = _todos.where(filter).toList();
    _pagina = filtered.take(_registrosPorPagina).toList();
    _paginaActual = 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}