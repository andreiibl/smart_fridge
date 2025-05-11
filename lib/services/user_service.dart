import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_fridge/config/config.dart';

class UserService {
  // Borra la cuenta del usuario y todos sus datos relacionados en el backend.
  Future<bool> deleteAccount(int userId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.usersEndpoint}/delete/$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    return response.statusCode == 200;
  }
  // Cambia la contraseña del usuario usando su userId.
  Future<bool> changePassword(int userId, String newPassword) async {
    final response = await http.put(
      Uri.parse('${AppConfig.usersEndpoint}/change-password/$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'newPassword': newPassword}),
    );
    return response.statusCode == 200;
  }
}