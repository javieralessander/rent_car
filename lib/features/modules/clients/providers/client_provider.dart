import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';

class ClientProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  ClientProvider() {
    cargarClientes();
  }
  List<Client> _todos = [];
  List<Client> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<Client> get clientes => _pagina;
  List<Client> get todosClientes => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Client> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (c) =>
              c.nombre.toLowerCase().contains(_busqueda) ||
              c.cedula.toLowerCase().contains(_busqueda) ||
              c.estado.toString().toLowerCase().contains(_busqueda),
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

  Future<void> cargarClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ClientService.getAll();
      debugPrint('Clientes recibidos: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron clientes.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar clientes: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar clientes: $e';
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

  Future<void> agregarCliente(Client cliente) async {
    try {
      final nuevo = await ClientService.create(cliente);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar cliente: $e');
    }
  }

  Future<void> actualizarCliente(Client cliente) async {
    try {
      final actualizado = await ClientService.update(cliente);
      final index = _todos.indexWhere((c) => c.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar cliente: $e');
    }
  }

  Future<void> eliminarCliente(int id) async {
    try {
      await ClientService.delete(id);
      _todos.removeWhere((c) => c.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar cliente: $e');
    }
  }
}
