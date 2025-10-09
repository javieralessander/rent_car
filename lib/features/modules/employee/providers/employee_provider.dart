import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  List<Employee> _todos = [];
  List<Employee> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<Employee> get empleados => _pagina;
  List<Employee> get todosEmpleados => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  // Devuelve la lista filtrada según la búsqueda
  List<Employee> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (e) =>
              e.nombre.toLowerCase().contains(_busqueda) ||
              e.cedula.toLowerCase().contains(_busqueda) ||
              e.tandaLabor.name.toLowerCase().contains(_busqueda) ||
              e.estado.toString().toLowerCase().contains(_busqueda),
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

  Future<void> cargarEmpleados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await EmployeeService.getAll();
      debugPrint('Empleados recibidos: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron empleados.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar empleados: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar empleados: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void _actualizarPagina() {
    final filtrados = _filtrados;
    // Si no hay resultados, muestra una página vacía y resetea la página actual solo si es necesario
    if (filtrados.isEmpty) {
      if (_pagina.isNotEmpty || _paginaActual != 1) {
        _paginaActual = 1;
        _pagina = [];
        notifyListeners();
      }
      return;
    }
    // Si la página actual es mayor que el total de páginas, vuelve a la primera
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

  Future<void> agregarEmpleado(Employee empleado) async {
    try {
      final nuevo = await EmployeeService.create(empleado);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar empleado: $e');
    }
  }

  Future<void> actualizarEmpleado(Employee empleado) async {
    try {
      final actualizado = await EmployeeService.update(empleado);
      final index = _todos.indexWhere((e) => e.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar empleado: $e');
    }
  }

  Future<void> eliminarEmpleado(int id) async {
    try {
      await EmployeeService.delete(id);
      _todos.removeWhere((e) => e.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar empleado: $e');
    }
  }
}
