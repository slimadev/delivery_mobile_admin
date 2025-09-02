import 'package:emartdriver/model/VehicleTypeModel.dart';
import 'package:emartdriver/services/api_service.dart';

import 'package:emartdriver/config/api_config.dart';

class VehicleTypeRepository {
  static const String _endpoint = ApiConfig.vehicleTypes;

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
}
