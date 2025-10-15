import 'package:flutter/material.dart';
import '../models/rental_model.dart';
import '../models/rental_form.dart';
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
      // Lista vacía es un estado válido, no un error
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar rentas: $e');
      _todos = [];
      _pagina = [];

      // Mejorar el mensaje de error basado en el tipo
      if (e.toString().contains('Sin conexión al servidor') ||
          e.toString().contains('Error de conexión') ||
          e.toString().contains('Error de red')) {
        _error = 'No se puede conectar al servidor. Verifique que el backend esté ejecutándose.';
      } else {
        _error = 'Error al cargar rentas: $e';
      }
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
      // Permitir fechas futuras para rentas

      if (renta.cantidadDias <= 0) {
        throw Exception('La cantidad de días debe ser mayor a 0');
      }

      if (renta.montoDia <= 0) {
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

  // Método optimizado que usa RentalForm directamente
  Future<void> agregarRentaFromForm(RentalForm rentalForm) async {
    try {
      if (rentalForm.cantidadDias <= 0) {
        throw Exception('La cantidad de días debe ser mayor a 0');
      }

      if (rentalForm.montoDia <= 0) {
        throw Exception('El monto por día debe ser mayor a 0');
      }

      final nueva = await RentalService.createFromForm(rentalForm);
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
      final index = _todos.indexWhere((r) => r.noRenta == actualizada.noRenta);
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
      final rental = _todos.firstWhere((r) => r.noRenta == id);

      if (rental.esDevuelto) {
        throw Exception('Este vehículo ya ha sido devuelto');
      }

      // Usar el servicio backend que maneja la fecha automáticamente
      final devuelta = await RentalService.devolver(id);
      final index = _todos.indexWhere((r) => r.noRenta == devuelta.noRenta);
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
      _todos.removeWhere((r) => r.noRenta == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar renta: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Método auxiliar para corregir rentas inconsistentes (solo para desarrollo/admin)
  void marcarComoDevuelta(int rentalId) {
    final index = _todos.indexWhere((r) => r.noRenta == rentalId);
    if (index != -1) {
      final rental = _todos[index];
      final rentaCorregida = Rental(
        noRenta: rental.noRenta,
        empleado: rental.empleado,
        vehiculo: rental.vehiculo,
        cliente: rental.cliente,
        fechaRenta: rental.fechaRenta,
        fechaDevolucion: DateTime.now(), // Establecer fecha actual
        montoDia: rental.montoDia,
        cantidadDias: rental.cantidadDias,
        comentario: rental.comentario,
        estado: EstadoRenta.DEVUELTA, // Asegurar estado correcto
      );
      _todos[index] = rentaCorregida;
      _actualizarPagina();
      debugPrint('Renta $rentalId marcada como devuelta localmente');
    }
  }

  // Método para recibir vehículo cuando llega antes de la fecha programada
  Future<void> recibirVehiculo(int id) async {
    try {
      final rental = _todos.firstWhere((r) => r.noRenta == id);

      if (rental.esDevuelto) {
        throw Exception('Este vehículo ya ha sido recibido');
      }

      if (!rental.necesitaRecibir) {
        throw Exception('Esta renta no necesita ser recibida manualmente');
      }

      // Usar el servicio de devolución existente
      final devuelta = await RentalService.devolver(id);
      final index = _todos.indexWhere((r) => r.noRenta == devuelta.noRenta);
      if (index != -1) {
        _todos[index] = devuelta;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al recibir vehículo: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
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
      // Por ahora usamos getAll y filtramos localmente
      // TODO: Implementar endpoint de búsqueda por criterios en el API
      final data = await RentalService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al buscar rentas: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
