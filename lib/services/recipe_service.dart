import 'package:http/http.dart' as http;
import 'package:smart_fridge/config/config.dart';

class RecipeService {
  // Borrar todas las recetas de un usuario
  Future<bool> deleteAllRecipesByUserId(int userId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.recipesEndpoint}/all/$userId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    return response.statusCode == 200;
  }
}