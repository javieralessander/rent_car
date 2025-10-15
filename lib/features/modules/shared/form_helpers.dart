/// Helpers para conversión entre modelos completos y modelos de formulario
/// Estos helpers facilitan la conversión bidireccional para usar en formularios

import '../models/models/model_model.dart';
import '../models/models/model_form.dart';
import '../brand/models/brand_model.dart';

import '../vehicles/models/vehicle_model.dart';
import '../vehicles/models/vehicle_form_model.dart';
import '../vehicle_types/models/vehicle_type_model.dart';
import '../fuel_types/models/fuel_type_model.dart';

import '../rental/models/rental_model.dart';
import '../rental/models/rental_form.dart';
import '../employee/models/employee_model.dart';
import '../clients/models/client_model.dart';

class FormHelpers {
  /// Convertir ModelForm a Model usando Brand provider
  static Model modelFormToModel(ModelForm form, Brand brand) {
    return form.toModel(brand: brand);
  }

  /// Convertir Model a ModelForm
  static ModelForm modelToModelForm(Model model) {
    return ModelForm.fromModel(model);
  }

  /// Convertir VehicleForm a Vehicle usando providers
  static Vehicle vehicleFormToVehicle(
    VehicleForm form, {
    required VehicleType vehicleType,
    required Brand brand,
    required Model model,
    required FuelType fuelType,
  }) {
    return form.toVehicle(
      vehicleType: vehicleType,
      brand: brand,
      model: model,
      fuelType: fuelType,
    );
  }

  /// Convertir Vehicle a VehicleForm
  static VehicleForm vehicleToVehicleForm(Vehicle vehicle) {
    return VehicleForm.fromVehicle(vehicle);
  }

  /// Convertir RentalForm a Rental usando providers
  static Rental rentalFormToRental(
    RentalForm form, {
    required Employee empleado,
    required Vehicle vehiculo,
    required Client cliente,
  }) {
    return form.toRental(
      empleado: empleado,
      vehiculo: vehiculo,
      cliente: cliente,
    );
  }

  /// Convertir Rental a RentalForm
  static RentalForm rentalToRentalForm(Rental rental) {
    return RentalForm.fromRental(rental);
  }

  /// Validar que todos los objetos requeridos estén disponibles para Vehicle
  static bool canCreateVehicle({
    required List<VehicleType> vehicleTypes,
    required List<Brand> brands,
    required List<Model> models,
    required List<FuelType> fuelTypes,
  }) {
    return vehicleTypes.isNotEmpty &&
        brands.isNotEmpty &&
        models.isNotEmpty &&
        fuelTypes.isNotEmpty;
  }

  /// Validar que todos los objetos requeridos estén disponibles para Rental
  static bool canCreateRental({
    required List<Employee> employees,
    required List<Vehicle> vehicles,
    required List<Client> clients,
  }) {
    return employees.isNotEmpty &&
        vehicles.isNotEmpty &&
        clients.isNotEmpty;
  }

  /// Validar que todos los objetos requeridos estén disponibles para Model
  static bool canCreateModel({
    required List<Brand> brands,
  }) {
    return brands.isNotEmpty;
  }

  /// Obtener mensaje de error cuando no se pueden crear entidades
  static String getCreationErrorMessage(String entityType, List<String> missingEntities) {
    final missing = missingEntities.join(', ');
    return 'Debe registrar $missing antes de crear $entityType.';
  }
}