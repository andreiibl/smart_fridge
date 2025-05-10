import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_fridge/config/config.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  String decodeUtf8(String text) {
    try {
      return utf8.decode(text.codeUnits);
    } catch (e) {
      return text;
    }
  }

  String cleanIngredients(String ingredientes) {
    final regexId = RegExp(r'\s*\[ID:\s*\d+\]');
    final regexAsteriscos = RegExp(r'\*');
    return ingredientes
        .split('\n')
        .map(
          (line) =>
              line
                  .replaceAll(regexId, '')
                  .replaceAll(regexAsteriscos, '')
                  .trim(),
        )
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  Future<void> _confirmAndUpdateStock(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Receta realizada?'),
            content: const Text(
              '¿Quieres actualizar el stock de ingredientes según esta receta?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        final response = await http.post(
          Uri.parse(AppConfig.productsQuantityEndpoint),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode({'ingredientes': recipe['ingredients']}),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stock actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); 
        } else {
          String errorMsg = 'Error al actualizar el stock';
          try {
            final decoded = json.decode(response.body);
            if (decoded is Map && decoded['message'] != null) {
              errorMsg = decoded['message'];
            } else if (response.body.isNotEmpty) {
              errorMsg = response.body;
            }
          } catch (_) {
            if (response.body.isNotEmpty) {
              errorMsg = response.body;
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  

  Future<void> _confirmDeleteRecipe(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Eliminar receta?'),
      content: const Text('¿Seguro que quieres eliminar esta receta?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sí'),
        ),
      ],
    ),
  );

  if (result == true) {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.recipesEndpoint}/${recipe['id']}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta eliminada'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop(true); // Vuelve atrás tras eliminar
      } else {
        String errorMsg = 'Error al eliminar la receta';
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            errorMsg = decoded['message'];
          } else if (response.body.isNotEmpty) {
            errorMsg = response.body;
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMsg = response.body;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B39EF), Color(0xFF39D2C0)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Receta Generada',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Volver',
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          decodeUtf8(recipe['name'] ?? 'Sin título'),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B39EF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          decodeUtf8(recipe['shortDesc'] ?? 'Sin descripción'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(thickness: 1.2, color: Colors.grey[300]),
                      _buildSectionTitle(
                        'Ingredientes:',
                        icon: Icons.shopping_basket,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          cleanIngredients(
                            decodeUtf8(
                              recipe['ingredients'] ?? 'Sin ingredientes',
                            ),
                          ),
                          key: ValueKey(recipe['ingredients']),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(thickness: 1.2, color: Colors.grey[300]),
                      _buildSectionTitle(
                        'Pasos a seguir:',
                        icon: Icons.format_list_numbered,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          decodeUtf8(recipe['steps'] ?? 'Sin pasos'),
                          key: ValueKey(recipe['steps']),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmAndUpdateStock(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF39D2C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          label: const Text(
                            '¿Receta realizada?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
  child: ElevatedButton.icon(
    onPressed: () => _confirmDeleteRecipe(context),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 16,
      ),
      elevation: 4,
    ),
    icon: const Icon(Icons.delete, color: Colors.white),
    label: const Text(
      'Eliminar receta',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: const Color(0xFF4B39EF), size: 22),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B39EF),
          ),
        ),
      ],
    );
  }
}
