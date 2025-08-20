import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.1.25.56:8000/api/drivers';
  static const String externalBaseUrl = 'http://10.1.25.56:8000/';

  // Headers padrão
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<dynamic> getExternal(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$externalBaseUrl$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // POST request
  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erro na requisição: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // DELETE request
  static Future<bool> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // POST Multipart request para envio de arquivos
  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, dynamic> data,
    Map<String, File?> files,
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

      // Adicionar headers sem Content-Type (será definido automaticamente)
      request.headers['Accept'] = 'application/json';

      // Adicionar campos de texto
      data.forEach((key, value) {
        if (value != null) {
          if (value is Map) {
            // Se for um Map, enviar como JSON string
            final cleanMap = Map<String, dynamic>.from(value);
            cleanMap.removeWhere((k, v) => v == null);

            print('Processing Map: $key = $cleanMap');
            request.fields[key] = json.encode(cleanMap);
            print('Map Field JSON: $key = ${json.encode(cleanMap)}');
          } else {
            request.fields[key] = value.toString();
            print('Simple Field: $key = $value');
          }
        }
      });

      print('All request fields: ${request.fields}');
      print(
          'All request files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}');

      // Adicionar arquivos simples
      files.forEach((key, file) {
        if (file != null) {
          request.files.add(
            http.MultipartFile(
              key,
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: file.path.split('/').last,
            ),
          );
        }
      });

      // Adicionar documentos com document_type_id
      for (int i = 0; i < documents.length; i++) {
        final doc = documents[i];
        final documentTypeId = doc['document_type_id'];
        final file = doc['document'] as File?;

        print(
            'Processing document $i: document_type_id=$documentTypeId, file=$file');

        if (file != null) {
          request.files.add(
            http.MultipartFile(
              documentTypeId.toString(), // O field é o ID do documento
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: file.path.split('/').last,
            ),
          );

          print(
              'Added document file: field=${documentTypeId.toString()}, file=${file.path}');
        }
      }

      print('Final request fields: ${request.fields}');
      print('Final request files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erro na requisição: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
