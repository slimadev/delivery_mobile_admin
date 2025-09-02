import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/services/api_service.dart';
import 'package:emartdriver/services/FirebaseHelper.dart';
import 'package:emartdriver/services/session_service.dart';
import 'package:emartdriver/userPrefrence.dart';
import 'package:emartdriver/config/api_config.dart';
import 'dart:io';
import 'dart:convert';

class UserRepository {
  // Buscar usuário por ID
  static Future<User?> getUserById(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.partnerById}/$id/');
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário por ID: $e');
      return null;
    }
  }

  static Future<User?> getUserProfile(String token) async {
    try {
      final response = await ApiService.get('${ApiConfig.profile}');
      print('Resposta do perfil: $response');
      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  static Future<User?> login(String phone, String password) async {
    try {
      // Formatar o número de telefone
      final formattedPhone = phone.replaceAll('+258', '');

      final response = await ApiService.post(ApiConfig.authenticate, {
        'phone_number': formattedPhone,
        'password': password,
      });

      print('Resposta da API de autenticação: $response');

      if (response != null && response['access_token'] != null) {
        final String token = response['access_token'];
        print('Token recebido: $token');

        // Salvar o token
        UserPreference.setUserToken(token: token);

        // Buscar dados do usuário
        User? user = await getUserProfile(token);
        if (user != null) {
          // Salvar sessão do usuário
          await SessionService.saveUserSession(user);
          return user;
        }
      }

      throw Exception('Resposta inválida da API de autenticação');
    } catch (e) {
      print('Erro ao autenticar: $e');
      return null;
    }
  }

  // Atualizar usuário
  static Future<User?> updateUser(String id, User user) async {
    try {
      final response =
          await ApiService.put('${ApiConfig.partnerById}/$id/', user.toJson());
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
      return await ApiService.delete('${ApiConfig.partnerById}/$id/');
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      return false;
    }
  }

  static Future<String> uploadUserImage(File image, String uid) async {
    return await FireStoreUtils.uploadUserImageToFireStorage(image, uid);
  }

  static Future<String> uploadCarImage(File image, String uid) async {
    return await FireStoreUtils.uploadCarImageToFireStorage(image, uid);
  }

  // Registrar motorista na API externa
  static Future<User?> registerDriver({
    required String name,
    required String email,
    required String phoneNumber,
    required File? profileImage,
    required String vehicleModel,
    required String registrationNumber,
    required String vehicleType,
    required int? vehicleMaker,
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
        "vehicle_maker_id": vehicleMaker,
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
        ApiConfig.registerDriver,
        requestData,
        files,
        documentsList,
      );

      if (response != null) {
        return User.fromJson(response);
      }

      return null;
    } catch (e) {
      print('Erro ao registrar motorista: $e');
      return null;
    }
  }

  static Future<User?> authenticate(
      String phone, String otp, String password) async {
    try {
      // Formatar o número de telefone removendo código do país se presente
      String formattedPhone = phone;
      if (phone.startsWith('+258')) {
        formattedPhone = phone.replaceAll('+258', '');
      } else if (phone.startsWith('258')) {
        formattedPhone = phone.replaceAll('258', '');
      }

      print('Ativando motorista com: $formattedPhone, OTP: $otp');

      final response = await ApiService.post(ApiConfig.activateDriver, {
        'phone_number': formattedPhone,
        'otp': otp,
        'password': password,
      });

      print('Resposta da ativação: $response');

      if (response != null) {
        // Se a ativação foi bem-sucedida, fazer login
        return await login(formattedPhone, password);
      }
      return null;
    } catch (e) {
      print('Erro ao autenticar: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Limpar token
      UserPreference.removeUserToken();

      print('Logout realizado com sucesso');
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  // Verificar se o usuário está autenticado
  static Future<bool> isAuthenticated() async {
    try {
      final token = UserPreference.getUserToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Verificar se o token ainda é válido fazendo uma requisição para o perfil
      final user = await getUserProfile(token);
      return user != null;
    } catch (e) {
      print('Erro ao verificar autenticação: $e');
      return false;
    }
  }
}
