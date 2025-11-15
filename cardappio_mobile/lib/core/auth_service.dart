import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/token_response.dart';
import 'app_config.dart';

class AuthService {
  final http.Client _client;
  TokenResponse? _currentToken;
  static const String _tokenStorageKey = 'keycloak_token';

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> initialize() async {
    await _loadStoredToken();

    if (_currentToken == null) {
      await serviceAccountLogin();
    } else if (_currentToken!.isExpired || _currentToken!.isAboutToExpire) {
      await _refreshTokenIfNeeded();
    }
  }

  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString(_tokenStorageKey);

      if (tokenJson != null) {
        final Map<String, dynamic> tokenData = json.decode(tokenJson);
        _currentToken = TokenResponse.fromJsonWithTimestamp(tokenData);

        if (_currentToken!.isExpired) {
          _currentToken = null;
          await _clearStoredToken();
        }
      }
    } catch (e) {
      _currentToken = null;
      await _clearStoredToken();
    }
  }

  Future<void> _saveToken(TokenResponse token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenStorageKey, json.encode(token.toJson()));
      _currentToken = token;
    } catch (e) {
      throw Exception('Erro ao salvar token: ${e.toString()}');
    }
  }

  Future<void> _clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenStorageKey);
    } catch (e) {
    }
  }

  Future<TokenResponse> serviceAccountLogin() async {
    return await _authenticateWithKeycloak(
      clientId: AppConfig.keycloakClientId,
      clientSecret: AppConfig.keycloakClientSecret,
    );
  }

  Future<TokenResponse> serviceAccountLoginWithCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    return await _authenticateWithKeycloak(
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }

  Future<TokenResponse> _authenticateWithKeycloak({
    required String clientId,
    required String clientSecret,
  }) async {
    final endpoint = AppConfig.keycloakTokenUrl;

    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(utf8.decode(response.bodyBytes));
        final token = TokenResponse.fromJson(tokenData);
        await _saveToken(token);
        return token;
      } else if (response.statusCode == 401) {
        throw Exception('Credenciais inválidas do service account');
      } else {
        throw Exception('Falha na autenticação: Status ${response.statusCode}. Resposta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao autenticar service account: ${e.toString()}');
    }
  }

  Future<TokenResponse> refreshToken() async {
    if (_currentToken?.refreshToken == null) {
      return await serviceAccountLogin();
    }

    final endpoint = AppConfig.keycloakTokenUrl;

    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': AppConfig.keycloakClientId,
          'client_secret': AppConfig.keycloakClientSecret,
          'grant_type': 'refresh_token',
          'refresh_token': _currentToken!.refreshToken!,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(utf8.decode(response.bodyBytes));
        final token = TokenResponse.fromJson(tokenData);
        await _saveToken(token);
        return token;
      } else {
        return await serviceAccountLogin();
      }
    } catch (e) {
      return await serviceAccountLogin();
    }
  }

  Future<void> _refreshTokenIfNeeded() async {
    if (_currentToken == null || _currentToken!.isExpired) {
      await serviceAccountLogin();
    } else if (_currentToken!.isAboutToExpire) {
      await refreshToken();
    }
  }

  Future<String> getValidAccessToken() async {
    await _refreshTokenIfNeeded();

    if (_currentToken == null) {
      throw Exception('Não foi possível obter um token válido');
    }

    return _currentToken!.accessToken;
  }

  String? get accessToken => _currentToken?.accessToken;

  bool get isAuthenticated {
    if (_currentToken == null) return false;
    return !_currentToken!.isExpired;
  }

  TokenResponse? get currentToken => _currentToken;

  Future<void> logout() async {
    _currentToken = null;
    await _clearStoredToken();
  }
}