import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fridge/screens/login_screen.dart';
import 'package:smart_fridge/screens/recipe_screen.dart';
import 'package:smart_fridge/screens/settings_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = ((screenWidth - 60) / 2).clamp(0, 250).toDouble();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B39EF), Color(0xFF39D2C0)],
            stops: [0, 1],
            begin: AlignmentDirectional(1, 1),
            end: AlignmentDirectional(-1, -1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome title
            Text(
              'Bienvenido a SmartFridge',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una opción',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 40),

            // Top buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Button products
                _buildMenuButton(
                  context,
                  size: buttonSize,
                  icon: Icons.shopping_basket_outlined,
                  label: 'Visualizar\nproductos',
                  onPressed: () {
                     // Nav to products
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListView()));
                  },
                ),
                const SizedBox(width: 20),
                // Button recipes
                _buildMenuButton(
                  context,
                  size: buttonSize,
                  icon: Icons.menu_book_outlined,
                  label: 'Visualizar\nrecetas',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RecipeGeneratorScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bottom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Button config
                _buildMenuButton(
                  context,
                  size: buttonSize,
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                ),
                const SizedBox(width: 20),
                _buildMenuButton(
                  context,
                  size: buttonSize,
                  icon: Icons.exit_to_app_outlined,
                  label: 'Cerrar sesión',
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required double size,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}