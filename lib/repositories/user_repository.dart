import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/api_service.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'dart:io';
import 'dart:convert';

class UserRepository {
  static const String _endpoint = '/users/';

  // Buscar usuário por ID
  static Future<User?> getUserById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário por ID: $e');
      return null;
    }
  }

  // Criar novo usuário
  static Future<User?> createUser(User user) async {
    try {
      final response = await ApiService.post(_endpoint, user.toJson());
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      return null;
    }
  }

  // Atualizar usuário
  static Future<User?> updateUser(String id, User user) async {
    try {
      final response = await ApiService.put('$_endpoint$id/', user.toJson());
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return null;
    }
  }

  // Deletar usuário
  static Future<bool> deleteUser(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      return false;
    }
  }

  // Buscar usuários por tipo de serviço
  static Future<List<User>> getUsersByServiceType(String serviceType) async {
    try {
      final response =
          await ApiService.get('$_endpoint?serviceType=$serviceType');
      List<dynamic> usersData =
          response is List ? response as List<dynamic> : [];
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar usuários por tipo de serviço: $e');
      return [];
    }
  }

  // Buscar usuários ativos
  static Future<List<User>> getActiveUsers() async {
    try {
      final response = await ApiService.get('$_endpoint?active=true');
      List<dynamic> usersData =
          response is List ? response as List<dynamic> : [];
      return usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar usuários ativos: $e');
      return [];
    }
  }

  static Future<String> uploadUserImage(File image, String uid) async {
    return await FireStoreUtils.uploadUserImageToFireStorage(image, uid);
  }

  static Future<String> uploadCarImage(File image, String uid) async {
    return await FireStoreUtils.uploadCarImageToFireStorage(image, uid);
  }

  // Registrar motorista na API externa
  static Future<Map<String, dynamic>?> registerDriver({
    required String name,
    required String email,
    required String phoneNumber,
    required File? profileImage,
    required String vehicleModel,
    required String registrationNumber,
    required String vehicleType,
    required String? vehicleMaker,
    required File? vehiclePhoto,
    required Map<int, File?> documents,
  }) async {
    try {
      // Converter tipo de veículo para o formato da API

      final requestData = {
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "vehicle_type": vehicleType,
        "vehicle_maker_id": 1,
        "vehicle_model": vehicleModel,
        "vehicle_registration_number": registrationNumber,
      };

      print('Request Data: $requestData');

      // Preparar arquivos simples
      final Map<String, File?> files = {};
      if (profileImage != null) {
        files['driver_photo'] = profileImage;
      }
      if (vehiclePhoto != null) {
        files['photo'] = vehiclePhoto;
      }

      // Preparar documentos com document_id
      final List<Map<String, dynamic>> documentsList = [];
      documents.forEach((documentId, file) {
        if (file != null) {
          documentsList.add({
            'document_type_id': documentId,
            'document': file,
          });
          print('Document ID: $documentId');
          print('File: $file');
        }
      });

      print('Documents List: $documentsList');
      print('Documents Count: ${documentsList.length}');

      final response = await ApiService.postMultipart(
        '/register-driver',
        requestData,
        files,
        documentsList,
      );

      if (response != null) {
        return response;
      }

      return null;
    } catch (e) {
      print('Erro ao registrar motorista: $e');
      return null;
    }
  }
}
