import 'package:emartdriver/model/VehicleMake.dart';
import 'package:emartdriver/services/api_service.dart';

class VehicleMakeRepository {
  static const String _endpoint = '/vehicle-makers/';

  // Buscar todas as marcas de veículo
  static Future<List<VehicleMake>> getVehicleMakes() async {
    try {
      final response = await ApiService.get(_endpoint);
      List<dynamic> vehicleMakesData =
          response is List ? response as List<dynamic> : [];
      return vehicleMakesData
          .map((json) => VehicleMake.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar todas as marcas de veículo: $e');
      return [];
    }
  }

  // Buscar marca por ID
  static Future<VehicleMake?> getVehicleMakeById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return VehicleMake.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar marca por ID: $e');
      return null;
    }
  }

  // Buscar marcas ativas
  static Future<List<VehicleMake>> getActiveVehicleMakes() async {
    try {
      final response = await ApiService.get('$_endpoint?active=true');
      List<dynamic> vehicleMakesData =
          response is List ? response as List<dynamic> : [];
      return vehicleMakesData
          .map((json) => VehicleMake.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar marcas ativas: $e');
      return [];
    }
  }

  // Buscar marcas por tipo de veículo
  static Future<List<VehicleMake>> getVehicleMakesByType(
      String vehicleTypeId) async {
    try {
      final response =
          await ApiService.get('$_endpoint?vehicleTypeId=$vehicleTypeId');
      List<dynamic> vehicleMakesData =
          response is List ? response as List<dynamic> : [];
      return vehicleMakesData
          .map((json) => VehicleMake.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar marcas por tipo de veículo: $e');
      return [];
    }
  }

  // Criar nova marca
  static Future<VehicleMake?> createVehicleMake(VehicleMake vehicleMake) async {
    try {
      final response = await ApiService.post(_endpoint, vehicleMake.toJson());
      if (response != null) {
        return VehicleMake.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar marca: $e');
      return null;
    }
  }

  // Atualizar marca
  static Future<VehicleMake?> updateVehicleMake(
      String id, VehicleMake vehicleMake) async {
    try {
      final response =
          await ApiService.put('$_endpoint$id/', vehicleMake.toJson());
      if (response != null) {
        return VehicleMake.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar marca: $e');
      return null;
    }
  }

  // Deletar marca
  static Future<bool> deleteVehicleMake(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar marca: $e');
      return false;
    }
  }
}
