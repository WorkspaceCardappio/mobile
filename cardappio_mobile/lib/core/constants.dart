// TODO: Remover após migração completa para AppConfig
const String kBaseUrl = 'http://10.0.2.2:8080';
const String kAuthEndpoint = '$kBaseUrl/api/auth';
const String kServiceAccountLoginEndpoint = '$kAuthEndpoint/service-account/login';
const String kMenusEndpoint = '$kBaseUrl/menus';
const String kTicketsEndpoint = '$kBaseUrl/tickets';
const String kCategoriesEndpoint = '$kBaseUrl/api/categories';
const String kProductsEndpoint = '$kBaseUrl/api/products';
const Duration kApiMockDelay = Duration(milliseconds: 700);
const String kProductVariablesEndpoint = '$kBaseUrl/api/variables';
const String kAdditionalsEndpoint = '$kBaseUrl/api/additionals';