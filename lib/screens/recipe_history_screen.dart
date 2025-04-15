import 'package:flutter/material.dart';

class RecipeHistoryScreen extends StatelessWidget {
  const RecipeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de recetas previas generadas
    final List<String> recipeTitles = [
      'Ensalada de Pollo con Aguacate',
      'Pasta con Salsa Alfredo',
      'Tacos de Pescado al Horno',
      'Sopa de Calabaza Cremosa',
      'Pollo Teriyaki con Arroz',
    ];

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

          // Lista de recetas generadas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: recipeTitles.length,
              itemBuilder: (context, index) {
                return _buildRecipeCard(recipeTitles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(String title) {
    return Container(
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
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }
}
