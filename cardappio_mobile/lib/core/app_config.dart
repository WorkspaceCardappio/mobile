import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { local, production }

class AppConfig {
  static Environment _currentEnvironment = Environment.local;

  static Environment get currentEnvironment => _currentEnvironment;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final envString = dotenv.env['ENVIRONMENT']?.toLowerCase() ?? 'local';
    _currentEnvironment = envString == 'production'
        ? Environment.production
        : Environment.local;
  }

  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  static String get keycloakClientId =>
      dotenv.env['KEYCLOAK_CLIENT_ID'] ?? '';

  static String get keycloakClientSecret =>
      dotenv.env['KEYCLOAK_CLIENT_SECRET'] ?? '';

  static String get keycloakRealm =>
      dotenv.env['KEYCLOAK_REALM'] ?? 'cardappio';

  static String get keycloakUrl {
    return _currentEnvironment == Environment.production
        ? dotenv.env['KEYCLOAK_URL_PRODUCTION'] ?? ''
        : dotenv.env['KEYCLOAK_URL_LOCAL'] ?? 'http://localhost:8090';
  }

  static String get baseUrl {
    return _currentEnvironment == Environment.production
        ? dotenv.env['API_BASE_URL_PRODUCTION'] ?? ''
        : dotenv.env['API_BASE_URL_LOCAL'] ?? 'http://localhost:8080';
  }

  static String get keycloakTokenUrl =>
      '$keycloakUrl/realms/$keycloakRealm/protocol/openid-connect/token';

  static String get authEndpoint => '$baseUrl/api/auth';
  static String get serviceAccountLoginEndpoint => '$authEndpoint/service-account/login';
  static String get menusEndpoint => '$baseUrl/menus';
  static String get ticketsEndpoint => '$baseUrl/tickets';
  static String get categoriesEndpoint => '$baseUrl/api/categories';
  static String get productsEndpoint => '$baseUrl/api/products';
  static String get productVariablesEndpoint => '$baseUrl/api/variables';
  static String get additionalsEndpoint => '$baseUrl/api/additionals';
  static String get ordersEndpoint => '$baseUrl/api/orders';

  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isLocal => _currentEnvironment == Environment.local;

  static String get environmentName =>
      _currentEnvironment == Environment.production ? 'Production' : 'Local';
}
