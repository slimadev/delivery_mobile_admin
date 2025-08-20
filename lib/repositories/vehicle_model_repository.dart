import 'package:emartdriver/model/VehicleModel.dart';
import 'package:emartdriver/services/api_service.dart';

class VehicleModelRepository {
  static const String _endpoint = '/vehicles-models/';

  // Buscar todos os modelos de veículo
  static Future<List<VehicleModel>> getVehicleModels() async {
    try {
      final response = await ApiService.get(_endpoint);
      List<dynamic> vehicleModelsData =
          response is List ? response as List<dynamic> : [];
      return vehicleModelsData
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar todos os modelos de veículo: $e');
      return [];
    }
  }

  // Buscar modelo por ID
  static Future<VehicleModel?> getVehicleModelById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return VehicleModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar modelo por ID: $e');
      return null;
    }
  }

  // Buscar modelos ativos
  static Future<List<VehicleModel>> getActiveVehicleModels() async {
    try {
      final response = await ApiService.get('$_endpoint?active=true');
      List<dynamic> vehicleModelsData =
          response is List ? response as List<dynamic> : [];
      return vehicleModelsData
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar modelos ativos: $e');
      return [];
    }
  }

  // Buscar modelos por marca
  static Future<List<VehicleModel>> getVehicleModelsByMake(
      String vehicleMakeId) async {
    try {
      final response =
          await ApiService.get('$_endpoint?vehicleMakeId=$vehicleMakeId');
      List<dynamic> vehicleModelsData =
          response is List ? response as List<dynamic> : [];
      return vehicleModelsData
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar modelos por marca: $e');
      return [];
    }
  }

  // Buscar modelos por tipo de veículo
  static Future<List<VehicleModel>> getVehicleModelsByType(
      String vehicleTypeId) async {
    try {
      final response =
          await ApiService.get('$_endpoint?vehicleTypeId=$vehicleTypeId');
      List<dynamic> vehicleModelsData =
          response is List ? response as List<dynamic> : [];
      return vehicleModelsData
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar modelos por tipo de veículo: $e');
      return [];
    }
  }

  // Criar novo modelo
  static Future<VehicleModel?> createVehicleModel(
      VehicleModel vehicleModel) async {
    try {
      final response = await ApiService.post(_endpoint, vehicleModel.toJson());
      if (response != null) {
        return VehicleModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar modelo: $e');
      return null;
    }
  }

  // Atualizar modelo
  static Future<VehicleModel?> updateVehicleModel(
      String id, VehicleModel vehicleModel) async {
    try {
      final response =
          await ApiService.put('$_endpoint$id/', vehicleModel.toJson());
      if (response != null) {
        return VehicleModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar modelo: $e');
      return null;
    }
  }

  // Deletar modelo
  static Future<bool> deleteVehicleModel(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar modelo: $e');
      return false;
    }
  }
}
