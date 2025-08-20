import 'package:emartdriver/model/DocumentModel.dart';
import 'package:emartdriver/services/api_service.dart';

class DocumentRepository {
  static Future<List<DocumentModel>> getRequiredDocuments() async {
    try {
      final response =
          await ApiService.getExternal('api/partners/driver-document-types/');

      if (response is List) {
        // Filtra apenas documentos para motoristas ou para todos
        List<DocumentModel> allDocuments =
            response.map((json) => DocumentModel.fromJson(json)).toList();
        return allDocuments
            .where((doc) =>
                doc.requiredFor == 'Motorista' || doc.requiredFor == 'Todos')
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Error loading documents: $e');
    }
  }
}
