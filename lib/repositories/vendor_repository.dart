import 'package:emartdriver/model/VendorModel.dart';
import 'package:emartdriver/services/api_service.dart';

class VendorRepository {
  static const String _endpoint = '/vendors/';

  // Buscar todos os vendedores
  static Future<List<VendorModel>> getAllVendors() async {
    try {
      final response = await ApiService.get(_endpoint);
      List<dynamic> vendorsData =
          response is List ? response as List<dynamic> : [];
      return vendorsData.map((json) => VendorModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar todos os vendedores: $e');
      return [];
    }
  }

  // Buscar vendedor por ID
  static Future<VendorModel?> getVendorById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return VendorModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar vendedor por ID: $e');
      return null;
    }
  }

  // Buscar vendedores por seção
  static Future<List<VendorModel>> getVendorsBySection(String sectionId) async {
    try {
      final response = await ApiService.get('$_endpoint?sectionId=$sectionId');
      List<dynamic> vendorsData =
          response is List ? response as List<dynamic> : [];
      return vendorsData.map((json) => VendorModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar vendedores por seção: $e');
      return [];
    }
  }

  // Buscar vendedores ativos
  static Future<List<VendorModel>> getActiveVendors() async {
    try {
      final response = await ApiService.get('$_endpoint?active=true');
      List<dynamic> vendorsData =
          response is List ? response as List<dynamic> : [];
      return vendorsData.map((json) => VendorModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar vendedores ativos: $e');
      return [];
    }
  }

  // Criar novo vendedor
  static Future<VendorModel?> createVendor(VendorModel vendor) async {
    try {
      final response = await ApiService.post(_endpoint, vendor.toJson());
      if (response != null) {
        return VendorModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar vendedor: $e');
      return null;
    }
  }

  // Atualizar vendedor
  static Future<VendorModel?> updateVendor(
      String id, VendorModel vendor) async {
    try {
      final response = await ApiService.put('$_endpoint$id/', vendor.toJson());
      if (response != null) {
        return VendorModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar vendedor: $e');
      return null;
    }
  }

  // Deletar vendedor
  static Future<bool> deleteVendor(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar vendedor: $e');
      return false;
    }
  }

  // Buscar vendedores por localização
  static Future<List<VendorModel>> getVendorsByLocation(
      double lat, double lng, double radius) async {
    try {
      final response =
          await ApiService.get('$_endpoint?lat=$lat&lng=$lng&radius=$radius');
      List<dynamic> vendorsData =
          response is List ? response as List<dynamic> : [];
      return vendorsData.map((json) => VendorModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar vendedores por localização: $e');
      return [];
    }
  }
}
