import '../../../../core/providers/base_collection_provider.dart';
import '../models/model_model.dart';
import '../services/model_service.dart';

/// Provider mejorado para modelos usando el provider base
class ModelProviderImproved extends BaseCollectionProvider<Model> {
  @override
  Future<List<Model>> fetchAll() async {
    return await ModelService.getAll();
  }

  @override
  Future<Model> create(Model item) async {
    return await ModelService.create(item);
  }

  @override
  Future<Model> update(Model item) async {
    return await ModelService.update(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    await ModelService.delete(id);
  }

  @override
  bool matchesSearch(Model item, String searchTerm) {
    return item.descripcion.toLowerCase().contains(searchTerm) ||
           item.estado.toString().toLowerCase().contains(searchTerm) ||
           (item.marca?.descripcion.toLowerCase().contains(searchTerm) ?? false);
  }

  @override
  dynamic getId(Model item) => item.id;

  // Métodos específicos para modelos

  /// Filtra modelos por marca
  void filterByBrand(int? marcaId) {
    if (marcaId == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((model) => model.marca?.id == marcaId);
    }
  }

  /// Filtra modelos por estado
  void filterByStatus(bool? activo) {
    if (activo == null) {
      clearCustomFilter();
    } else {
      applyCustomFilter((model) => model.estado == activo);
    }
  }

  /// Obtiene modelos por marca
  List<Model> getModelsByBrand(int marcaId) {
    return allItems.where((m) => m.marca?.id == marcaId).toList();
  }

  /// Limpia filtros personalizados
  void clearCustomFilter() {
    resetPagination();
  }

  /// Valida si una descripción ya existe para una marca específica
  bool isDescriptionExists(String description, int brandId, {int? excludeId}) {
    return allItems.any((m) =>
      m.descripcion.toLowerCase() == description.toLowerCase() &&
      m.marca?.id == brandId &&
      (excludeId == null || m.id != excludeId)
    );
  }

  /// Obtiene estadísticas de modelos
  Map<String, int> getModelStats() {
    final activos = allItems.where((m) => m.estado).length;
    final inactivos = allItems.length - activos;

    return {
      'total': allItems.length,
      'activos': activos,
      'inactivos': inactivos,
    };
  }

  /// Obtiene modelos agrupados por marca
  Map<String, List<Model>> getModelsByBrandGroup() {
    final grouped = <String, List<Model>>{};

    for (final model in allItems) {
      final marca = model.marca?.descripcion ?? 'Sin marca';
      grouped.putIfAbsent(marca, () => []).add(model);
    }

    return grouped;
  }

  /// Busca modelos por descripción
  List<Model> findByDescription(String description) {
    if (description.isEmpty) return [];
    return allItems.where((m) =>
      m.descripcion.toLowerCase().contains(description.toLowerCase())
    ).toList();
  }

  /// Obtiene modelos recientes (últimos agregados)
  List<Model> getRecentModels({int limit = 5}) {
    final sorted = List<Model>.from(allItems);
    sorted.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return sorted.take(limit).toList();
  }
}