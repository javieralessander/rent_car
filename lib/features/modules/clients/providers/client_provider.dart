import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/providers/base_collection_provider.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';

class ClientProvider extends BaseCollectionProvider<Client> {

  // Métodos requeridos por BaseCollectionProvider
  @override
  Future<List<Client>> fetchAll() async {
    return await ClientService.getAll();
  }

  @override
  Future<Client> create(Client item) async {
    return await ClientService.create(item);
  }

  @override
  Future<Client> update(Client item) async {
    return await ClientService.update(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    await ClientService.delete(id);
  }

  @override
  bool matchesSearch(Client item, String searchTerm) {
    return item.nombre.toLowerCase().contains(searchTerm) ||
           item.cedula.toLowerCase().contains(searchTerm) ||
           item.noTarjetaCr.toLowerCase().contains(searchTerm) ||
           item.tipoPersonaTexto.toLowerCase().contains(searchTerm) ||
           item.estado.toString().toLowerCase().contains(searchTerm);
  }

  @override
  dynamic getId(Client item) => item.id;

  // Métodos para compatibilidad con código existente
  List<Client> get clientes => items;
  List<Client> get todosClientes => allItems;

  set busqueda(String value) => setSearch(value);

  Future<void> cargarClientes() async => await initialize();

  void cambiarPagina(int nuevaPagina) => changePage(nuevaPagina);

  void cambiarRegistrosPorPagina(int cantidad) => changeItemsPerPage(cantidad);

  Future<void> agregarCliente(Client cliente) async => await addItem(cliente);

  Future<void> actualizarCliente(Client cliente) async => await updateItem(cliente);

  Future<void> eliminarCliente(int id) async => await removeItem(id);

  // Métodos específicos para clientes

  /// Busca cliente por cédula
  Client? findByCedula(String cedula) {
    try {
      return allItems.firstWhere((c) => c.cedula == cedula);
    } catch (e) {
      return null;
    }
  }

  /// Busca cliente por número de tarjeta
  Client? findByTarjeta(String noTarjeta) {
    try {
      return allItems.firstWhere((c) =>
        c.noTarjetaCr.toLowerCase() == noTarjeta.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  /// Filtra clientes por estado
  void filterByStatus(bool? activo) {
    if (activo == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((client) => client.estado == activo);
    }
  }

  /// Filtra clientes por tipo de persona
  void filterByPersonType(TipoPersona? tipoPersona) {
    if (tipoPersona == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((client) => client.tipoPersona == tipoPersona);
    }
  }

  /// Limpia filtros personalizados
  void clearCustomFilter() {
    resetPagination();
  }

  /// Valida si una cédula ya existe
  bool isCedulaExists(String cedula, {int? excludeId}) {
    return allItems.any((c) =>
      c.cedula == cedula && (excludeId == null || c.id != excludeId)
    );
  }

  /// Valida si una tarjeta ya existe
  bool isTarjetaExists(String noTarjeta, {int? excludeId}) {
    return allItems.any((c) =>
      c.noTarjetaCr.toLowerCase() == noTarjeta.toLowerCase() &&
      (excludeId == null || c.id != excludeId)
    );
  }

  /// Obtiene estadísticas de clientes
  Map<String, int> getClientStats() {
    final activos = allItems.where((c) => c.estado).length;
    final inactivos = allItems.length - activos;
    final fisicas = allItems.where((c) => c.tipoPersona == TipoPersona.FISICA).length;
    final juridicas = allItems.where((c) => c.tipoPersona == TipoPersona.JURIDICA).length;

    return {
      'total': allItems.length,
      'activos': activos,
      'inactivos': inactivos,
      'fisicas': fisicas,
      'juridicas': juridicas,
    };
  }

  /// Obtiene clientes agrupados por tipo de persona
  Map<String, List<Client>> getClientsByPersonType() {
    final grouped = <String, List<Client>>{};

    for (final client in allItems) {
      final tipo = client.tipoPersonaTexto;
      grouped.putIfAbsent(tipo, () => []).add(client);
    }

    return grouped;
  }

  /// Obtiene clientes recientes (últimos agregados)
  List<Client> getRecentClients({int limit = 5}) {
    final sorted = List<Client>.from(allItems);
    sorted.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return sorted.take(limit).toList();
  }
}
