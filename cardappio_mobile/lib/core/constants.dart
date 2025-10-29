const String kBaseUrl = 'http://10.0.2.2:8080';

// Endpoints
const String kMenusEndpoint = '$kBaseUrl/menus';
const String kTicketsEndpoint = '$kBaseUrl/tickets';
const String kCategoriesEndpoint = '$kBaseUrl/api/categories'; // <-- ADICIONE ESTA LINHA
// ... suas outras constantes
const String kProductsEndpoint = '$kBaseUrl/api/products'; // <-- ADICIONE ESTA LINHA

const Duration kApiMockDelay = Duration(milliseconds: 700);