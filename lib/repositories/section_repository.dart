import 'package:emartdriver/model/SectionModel.dart';
import 'package:emartdriver/services/api_service.dart';

class SectionRepository {
  static const String _endpoint = '/vendor_sessions/';

  static Future<List<SectionModel>> getSections() async {
    try {
      print('getSections');
      print('################################');
      print('################################');
      final response = await ApiService.get(_endpoint);

      // A API retorna uma lista direta, não um objeto com 'data'
      List<dynamic> sectionsData =
          response is List ? response as List<dynamic> : [];

      return sectionsData.map((json) => SectionModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar seções da API: $e');
      // Em caso de erro, retorna lista vazia
      return [];
    }
  }

  // Buscar seção por ID
  static Future<SectionModel?> getSectionById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint$id/');
      if (response != null) {
        return SectionModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar seção por ID: $e');
      return null;
    }
  }

  // Criar nova seção
  static Future<SectionModel?> createSection(SectionModel section) async {
    try {
      final response = await ApiService.post(_endpoint, section.toJson());
      if (response != null) {
        return SectionModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao criar seção: $e');
      return null;
    }
  }

  // Atualizar seção
  static Future<SectionModel?> updateSection(
      String id, SectionModel section) async {
    try {
      final response = await ApiService.put('$_endpoint$id/', section.toJson());
      if (response != null) {
        return SectionModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar seção: $e');
      return null;
    }
  }

  // Deletar seção
  static Future<bool> deleteSection(String id) async {
    try {
      return await ApiService.delete('$_endpoint$id/');
    } catch (e) {
      print('Erro ao deletar seção: $e');
      return false;
    }
  }

  // Buscar seções ativas
  static Future<List<SectionModel>> getActiveSections() async {
    try {
      final allSections = await getSections();
      return allSections.where((section) => section.isActive == true).toList();
    } catch (e) {
      print('Erro ao buscar seções ativas: $e');
      return [];
    }
  }
}
