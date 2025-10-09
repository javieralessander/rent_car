import 'package:flutter/material.dart';
import '../models/rental_model.dart';
import '../services/rental_service.dart';

class RentalProvider extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  RentalProvider() {
    cargarRentas();
  }
  List<Rental> _todos = [];
  List<Rental> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 6;

  String _busqueda = '';

  List<Rental> get rentas => _pagina;
  List<Rental> get todasRentas => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Rental> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (r) =>
              r.cliente.toString().contains(_busqueda) ||
              r.vehiculo.toString().contains(_busqueda) ||
              r.estado.toString().toLowerCase().contains(_busqueda),
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

  Future<void> cargarRentas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await RentalService.getAll();
      debugPrint('Rentas recibidas: \n$data');
      _todos = data;
      if (_todos.isEmpty) {
        _error = 'No se encontraron rentas.';
      }
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar rentas: $e');
      _todos = [];
      _pagina = [];
      _error = 'Error al cargar rentas: $e';
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

  Future<void> agregarRenta(Rental renta) async {
    try {
      if (renta.fechaRenta.isAfter(DateTime.now())) {
        throw Exception('La fecha de renta no puede ser futura');
      }

      if (renta.cantidadDias <= 0) {
        throw Exception('La cantidad de días debe ser mayor a 0');
      }

      if (renta.montoPorDia <= 0) {
        throw Exception('El monto por día debe ser mayor a 0');
      }

      final nueva = await RentalService.create(renta);
      _todos.add(nueva);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar renta: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarRenta(Rental renta) async {
    try {
      final actualizada = await RentalService.update(renta);
      final index = _todos.indexWhere((r) => r.id == actualizada.id);
      if (index != -1) {
        _todos[index] = actualizada;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar renta: $e');
    }
  }

  Future<void> devolverVehiculo(int id, DateTime fechaDevolucion) async {
    try {
      final rental = _todos.firstWhere((r) => r.id == id);

      if (rental.esDevuelto) {
        throw Exception('Este vehículo ya ha sido devuelto');
      }

      if (fechaDevolucion.isBefore(rental.fechaRenta)) {
        throw Exception('La fecha de devolución no puede ser anterior a la fecha de renta');
      }

      final devuelta = await RentalService.devolver(id, fechaDevolucion);
      final index = _todos.indexWhere((r) => r.id == devuelta.id);
      if (index != -1) {
        _todos[index] = devuelta;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al devolver vehículo: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarRenta(int id) async {
    try {
      await RentalService.delete(id);
      _todos.removeWhere((r) => r.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar renta: $e');
    }
  }

  Future<void> buscarPorCriterios({
    int? clienteId,
    int? vehiculoId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await RentalService.buscarPorCriterios(
        clienteId: clienteId,
        vehiculoId: vehiculoId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al buscar rentas: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
