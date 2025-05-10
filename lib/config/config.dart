import 'dart:io';

class AppConfig {
  // URL base según la plataforma
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:8080'; 
    } else {
      throw UnsupportedError('Plataforma no soportada');
    }
  }

  // Endpoints específicos
  static String get loginEndpoint => '$baseUrl/users/login';
  static String get registerEndpoint => '$baseUrl/users/register';
  static String get productsEndpoint => '$baseUrl/products';
  static String get productsQuantityEndpoint => '$baseUrl/products/update-quantities';
  static String get generateRecipeEndpoint => '$baseUrl/products/generate-recipe';
  static String get recipesEndpoint => '$baseUrl/recipes';
  static String get recipesHistoryEndpoint => '$baseUrl/recipes/user';
  
}