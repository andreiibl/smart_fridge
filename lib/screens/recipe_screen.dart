import 'package:flutter/material.dart';
import 'package:smart_fridge/config/config.dart';
import 'package:smart_fridge/screens/recipe_history_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_fridge/screens/recipe_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeGeneratorScreen extends StatelessWidget {
  const RecipeGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60.0,
              bottom: 30.0,
              left: 20.0,
              right: 20.0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4B39EF), Color(0xFF39D2C0)],
                stops: [0, 1],
                begin: AlignmentDirectional(1, 1),
                end: AlignmentDirectional(-1, -1),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generador de Recetas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.restaurant_menu,
                    label: 'Generar Receta Nueva',
                    onPressed: () async {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );
                        final prefs = await SharedPreferences.getInstance();
                        final userId = int.parse(
                          prefs.getString('userId') ?? '0',
                        );
                        final recipe = await generateRecipe(userId);
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      } catch (e) {
                        Navigator.of(context).pop();

                        String errorMsg = 'Error al generar la receta';
                        if (e is http.Response) {
                          try {
                            final decoded = json.decode(
                              utf8.decode(e.bodyBytes),
                            );
                            if (decoded is Map && decoded['message'] != null) {
                              errorMsg = decoded['message'];
                            }
                          } catch (_) {}
                        } else if (e is Exception &&
                            e.toString().contains(
                              'No se puede generar una receta',
                            )) {
                          errorMsg =
                              'No se puede generar una receta con los ingredientes disponibles.';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30),

                  _buildMenuButton(
                    context,
                    icon: Icons.history,
                    label: 'Ver Recetas Anteriores',
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = int.parse(
                        prefs.getString('userId') ?? '0',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RecipeHistoryScreen(userId: userId),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          elevation: 3,
          shadowColor: Colors.grey.withOpacity(0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF4B39EF)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4B39EF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> generateRecipe(int userId) async {
  final url = Uri.parse('${AppConfig.generateRecipeEndpoint}/$userId');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );

  if (response.statusCode == 200) {
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    throw response;
  }
}
