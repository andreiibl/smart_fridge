import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fridge/screens/change_password_screen.dart';
import 'package:smart_fridge/screens/login_screen.dart';
import 'package:smart_fridge/services/product_service.dart';
import 'package:smart_fridge/services/recipe_service.dart';
import 'package:smart_fridge/services/user_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    'Configuración',
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildSettingsOption(
                  icon: Icons.lock,
                  title: 'Cambiar contraseña',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsOption(
                  icon: Icons.delete_forever,
                  title: 'Vaciar nevera',
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      title: "Vaciar Nevera",
                      content: "¿Estás seguro de que deseas vaciar la nevera?",
                      onConfirm: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getString('userId');
                        if (userId != null) {
                          final success = await ProductService()
                              .deleteAllProductsByUserId(userId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Nevera vaciada correctamente'
                                    : 'Error al vaciar la nevera',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                _buildSettingsOption(
                  icon: Icons.delete_sweep,
                  title: 'Borrar todas las recetas',
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      title: "Borrar Recetas",
                      content:
                          "¿Estás seguro de que deseas borrar todas las recetas?",
                      onConfirm: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userIdStr = prefs.getString('userId');
                        if (userIdStr != null) {
                          final userId = int.parse(userIdStr);
                          final success = await RecipeService()
                              .deleteAllRecipesByUserId(userId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Recetas borradas correctamente'
                                    : 'Error al borrar las recetas',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                const Divider(height: 40),
                _buildSettingsOption(
                  icon: Icons.person_remove,
                  title: 'Borrar cuenta',
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      title: "Borrar Cuenta",
                      content: "¿Estás seguro de que deseas borrar tu cuenta?",
                      onConfirm: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final userIdStr = prefs.getString('userId');
                        if (userIdStr != null) {
                          final userId = int.parse(userIdStr);
                          final success = await UserService().deleteAccount(
                            userId,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Cuenta borrada correctamente'
                                    : 'Error al borrar la cuenta',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                          if (success) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF4B39EF),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
