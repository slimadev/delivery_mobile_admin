import 'package:emartdriver/model/OrderModel.dart';
import 'package:emartdriver/services/api_service.dart';
import 'package:emartdriver/config/api_config.dart';

class OrderRepository {
  static const String _endpoint = '/api/orders/';

  // Buscar todos os pedidos
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await ApiService.get(_endpoint);
      List<dynamic> ordersData =
          response is List ? response as List<dynamic> : [];
      return ordersData.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar todos os pedidos: $e');
      return [];
    }
  }

  // Buscar pedido por ID
  static Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return OrderModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pedido por ID: $e');
      return null;
    }
  }

  // Buscar pedidos por status
  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final response = await ApiService.get('$_endpoint?status=$status');
      List<dynamic> ordersData =
          response is List ? response as List<dynamic> : [];
      return ordersData.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar pedidos por status: $e');
      return [];
    }
  }

  // Atualizar pedido
  static Future<OrderModel?> updateOrder(String id, OrderModel order) async {
    try {
      final response = await ApiService.put('$_endpoint$id/', order.toJson());
      if (response != null) {
        return OrderModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar pedido: $e');
      return null;
    }
  }

  // Buscar pedidos em andamento
  static Future<List<OrderModel>> getActiveOrders() async {
    try {
      final response = await ApiService.get('$_endpoint?status=active');
      List<dynamic> ordersData =
          response is List ? response as List<dynamic> : [];
      return ordersData.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar pedidos ativos: $e');
      return [];
    }
  }
}
