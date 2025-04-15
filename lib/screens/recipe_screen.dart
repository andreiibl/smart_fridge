import 'package:flutter/material.dart';
import 'package:smart_fridge/screens/recipe_history_screen.dart';
import 'package:smart_fridge/screens/recipe_steps_screen.dart';

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
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipeDetailScreen()),
                      ).then((newRecipe) {
                        if (newRecipe != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nueva receta creada')));
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  _buildMenuButton(
                    context,
                    icon: Icons.history,
                    label: 'Ver Recetas Anteriores',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipeHistoryScreen()),
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
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 3,
          shadowColor: Colors.grey.withOpacity(0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color(0xFF4B39EF),
            ),
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
