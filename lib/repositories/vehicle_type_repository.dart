import 'package:emartdriver/model/VehicleTypeModel.dart';
import 'package:emartdriver/services/api_service.dart';

class VehicleTypeRepository {
  static const String _endpoint = '/vehicle-types/';

  static Future<List<VehicleTypeModel>> getVehicleTypes() async {
    try {
      print('$_endpoint');
      final response = await ApiService.get(_endpoint);
      List<dynamic> vehicleTypesData =
          response is List ? response as List<dynamic> : [];

      print('Vehicle Types Data: $vehicleTypesData');
      return vehicleTypesData
          .map((json) => VehicleTypeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar todos os tipos de veículo: $e');
      return [];
    }
  }

  // Buscar tipo de veículo por ID
  static Future<VehicleTypeModel?> getVehicleTypeById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return VehicleTypeModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar tipo de veículo por ID: $e');
      return null;
    }
  }

  // Buscar tipos de veículo ativos
  static Future<List<VehicleTypeModel>> getActiveVehicleTypes() async {
    try {
      final response = await ApiService.get('$_endpoint?active=true');
      List<dynamic> vehicleTypesData =
          response is List ? response as List<dynamic> : [];
      return vehicleTypesData
          .map((json) => VehicleTypeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar tipos de veículo ativos: $e');
      return [];
    }
  }

  // Criar novo tipo de veículo
  static Future<VehicleTypeModel?> createVehicleType(
      VehicleTypeModel vehicleType) async {
    try {
      final response = await ApiService.post(_endpoint, vehicleType.toJson());
      if (response != null) {
        return VehicleTypeModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar tipo de veículo: $e');
      return null;
    }
  }

  // Atualizar tipo de veículo
  static Future<VehicleTypeModel?> updateVehicleType(
      String id, VehicleTypeModel vehicleType) async {
    try {
      final response =
          await ApiService.put('$_endpoint$id/', vehicleType.toJson());
      if (response != null) {
        return VehicleTypeModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar tipo de veículo: $e');
      return null;
    }
  }

  // Deletar tipo de veículo
  static Future<bool> deleteVehicleType(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar tipo de veículo: $e');
      return false;
    }
  }
}
