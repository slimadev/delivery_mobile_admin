import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emartdriver/model/User.dart';
import 'package:emartdriver/userPrefrence.dart';

class SessionService {
  static const String _userSessionKey = "user_session";
  static const String _isLoggedInKey = "is_logged_in";
  static const String _lastLoginTimeKey = "last_login_time";

  /// Inicializa o serviço de sessão
  static Future<void> init() async {
    await UserPreference.init();
  }

  /// Salva a sessão do usuário
  static Future<void> saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userSessionKey, userJson);

      await prefs.setBool(_isLoggedInKey, true);

      await prefs.setString(
          _lastLoginTimeKey, DateTime.now().toIso8601String());

      UserPreference.setUserId(userID: user.userID);

      print('Sessão do usuário salva com sucesso: ${user.userID}');
    } catch (e) {
      print('Erro ao salvar sessão do usuário: $e');
    }
  }

  static Future<User?> getUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedIn) {
        return null;
      }

      final userJson = prefs.getString(_userSessionKey);
      if (userJson == null) {
        return null;
      }

      final userData = jsonDecode(userJson);
      final user = User.fromJson(userData);

      print('Sessão do usuário recuperada: ${user.userID}');
      return user;
    } catch (e) {
      print('Erro ao recuperar sessão do usuário: $e');
      return null;
    }
  }

  /// Verifica se o usuário está logado
  static Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Erro ao verificar status de login: $e');
      return false;
    }
  }

  /// Atualiza a sessão do usuário (útil quando dados são modificados)
  static Future<void> updateUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Atualiza o usuário na sessão
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userSessionKey, userJson);

      print('Sessão do usuário atualizada: ${user.userID}');
    } catch (e) {
      print('Erro ao atualizar sessão do usuário: $e');
    }
  }

  /// Limpa a sessão do usuário (logout)
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove todos os dados da sessão
      await prefs.remove(_userSessionKey);
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_lastLoginTimeKey);

      // Limpa também o userID do sistema existente
      await prefs.remove('userId');

      print('Sessão do usuário limpa com sucesso');
    } catch (e) {
      print('Erro ao limpar sessão do usuário: $e');
    }
  }

  /// Obtém o timestamp do último login
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginString = prefs.getString(_lastLoginTimeKey);

      if (lastLoginString != null) {
        return DateTime.parse(lastLoginString);
      }
      return null;
    } catch (e) {
      print('Erro ao obter timestamp do último login: $e');
      return null;
    }
  }

  /// Verifica se a sessão ainda é válida (opcional: pode implementar expiração)
  static Future<bool> isSessionValid() async {
    try {
      final isLoggedIn = await isUserLoggedIn();
      if (!isLoggedIn) return false;

      // Opcional: implementar verificação de expiração de sessão
      // Por exemplo, verificar se o último login foi há mais de X dias
      final lastLogin = await getLastLoginTime();
      if (lastLogin != null) {
        final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;
        // Sessão expira após 30 dias (configurável)
        if (daysSinceLogin > 30) {
          await clearUserSession();
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Erro ao verificar validade da sessão: $e');
      return false;
    }
  }
}
