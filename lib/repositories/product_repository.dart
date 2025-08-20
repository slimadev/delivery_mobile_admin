import 'package:emartdriver/model/ProductModel.dart';
import 'package:emartdriver/services/api_service.dart';

class ProductRepository {
  static const String _endpoint = '/products/';

  // Buscar todos os produtos
  static Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await ApiService.get(_endpoint);
      List<dynamic> productsData =
          response is List ? response as List<dynamic> : [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar todos os produtos: $e');
      return [];
    }
  }

  // Buscar produto por ID
  static Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return ProductModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar produto por ID: $e');
      return null;
    }
  }

  // Buscar produtos por vendedor
  static Future<List<ProductModel>> getProductsByVendor(String vendorId) async {
    try {
      final response = await ApiService.get('$_endpoint?vendorId=$vendorId');
      List<dynamic> productsData =
          response is List ? response as List<dynamic> : [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar produtos por vendedor: $e');
      return [];
    }
  }

  // Buscar produtos por categoria
  static Future<List<ProductModel>> getProductsByCategory(
      String categoryId) async {
    try {
      final response =
          await ApiService.get('$_endpoint?categoryId=$categoryId');
      List<dynamic> productsData =
          response is List ? response as List<dynamic> : [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar produtos por categoria: $e');
      return [];
    }
  }

  // Buscar produtos ativos
  static Future<List<ProductModel>> getActiveProducts() async {
    try {
      final response = await ApiService.get('$_endpoint?active=true');
      List<dynamic> productsData =
          response is List ? response as List<dynamic> : [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar produtos ativos: $e');
      return [];
    }
  }

  // Criar novo produto
  static Future<ProductModel?> createProduct(ProductModel product) async {
    try {
      final response = await ApiService.post(_endpoint, product.toJson());
      if (response != null) {
        return ProductModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar produto: $e');
      return null;
    }
  }

  // Atualizar produto
  static Future<ProductModel?> updateProduct(
      String id, ProductModel product) async {
    try {
      final response = await ApiService.put('$_endpoint$id/', product.toJson());
      if (response != null) {
        return ProductModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar produto: $e');
      return null;
    }
  }

  // Deletar produto
  static Future<bool> deleteProduct(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar produto: $e');
      return false;
    }
  }

  // Buscar produtos por nome (busca)
  static Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await ApiService.get('$_endpoint?search=$query');
      List<dynamic> productsData =
          response is List ? response as List<dynamic> : [];
      return productsData.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return [];
    }
  }
}
