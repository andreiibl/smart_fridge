import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_fridge/config/config.dart';
import 'recipe_detail_screen.dart';

class RecipeHistoryScreen extends StatefulWidget {
  final int userId;
  
  const RecipeHistoryScreen({super.key, required this.userId});

  @override
  State<RecipeHistoryScreen> createState() => _RecipeHistoryScreenState();
}

class _RecipeHistoryScreenState extends State<RecipeHistoryScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.recipesHistoryEndpoint}/${widget.userId}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          recipes = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar las recetas: ${response.statusCode}');
      }
    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar recetas por nombre
    final filteredRecipes = recipes.where((recipe) {
      final name = (recipe['name'] ?? '').toString().toLowerCase();
      final filter = _filterController.text.toLowerCase();
      return name.contains(filter);
    }).toList();

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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Historial de Recetas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              controller: _filterController,
              decoration: InputDecoration(
                labelText: 'Filtrar por nombre de receta',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRecipes.isEmpty
                    ? const Center(
                        child: Text('No hay recetas guardadas'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCard(filteredRecipes[index], context);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
        if (result == true) {
          fetchRecipes();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF4B39EF), size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                recipe['name'] ?? 'Sin título',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
