import 'package:emartdriver/model/VehicleMake.dart';
import 'package:emartdriver/services/api_service.dart';

import 'package:emartdriver/config/api_config.dart';

class VehicleMakeRepository {
  static const String _endpoint = ApiConfig.vehicleMakers;

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
}
