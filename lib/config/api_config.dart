class ApiConfig {
  // URLs base das APIs
  static const String baseUrl = 'http://192.168.30.224:8000/api';

  // Endpoints para Parceiros
  static const String partnersBase = '/partners';
  static const String documentTypes = '$partnersBase/document-types/';
  static const String driverDocumentTypes =
      '$partnersBase/driver-document-types/';
  static const String sessions = '$partnersBase/sessions/';
  static const String partnersBySession = '$partnersBase/by_session';
  static const String partnersByCategory = '$partnersBase/by_category';
  static const String partnerById = '$partnersBase';
  static const String vendorCategoriesBySession =
      '$partnersBase/vendor_categories/by_session';
  static const String authenticate = '$partnersBase/authenticate/';
  static const String profile = '$partnersBase/profile/';

  // Endpoints para Motoristas
  static const String driversBase = '/drivers';
  static const String vehicleMakers = '$driversBase/vehicle-makers/';
  static const String vehicleTypes = '$driversBase/vehicle-types/';
  static const String vehicleModels = '$driversBase/vehicle-models/';
  static const String registerDriver = '$driversBase/register-driver';
  static const String activateDriver = '$driversBase/activate-driver';

  // Endpoints para Vendedores
  static const String vendorsBase = '/vendors';
  static const String productsBySession = '$vendorsBase/products/by_session';
  static const String productsByCategory = '$vendorsBase/products/category';
  static const String favoriteProducts = '$vendorsBase/products/favorites';

  // Endpoints para Pedidos
  static const String ordersBase = '/orders';
  static const String createOrder = '$ordersBase/';
  static const String orderDetail = '$ordersBase';
  static const String pendingOrders = '$ordersBase/pending/';
  static const String pendingOrdersFiltered = '$ordersBase/pending/by/';
  static const String updateOrderStatus = '$ordersBase';
  static const String assignDriver = '$ordersBase';
  static const String updateDriverLocation =
      '$ordersBase/driver/update-location/';
  static const String nearbyDrivers = '$ordersBase/drivers/nearby/';
  static const String driverLocationFromOrder = '$ordersBase';
}
