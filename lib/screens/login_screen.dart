import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:smart_fridge/config/config.dart';

// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estado de la pantalla
  bool _passwordVisible = false; // Visibilidad de la contraseña
  bool _isLoading = false; // Indicador de carga
  String? _errorMessage; // Mensaje de error

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Verificar si el usuario ya está logueado
  }

  @override
  void dispose() {
    // Liberar recursos al destruir el widget
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      // Oculta el teclado al tocar fuera del campo
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo con gradiente
            Container(
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y descripción
                      Text(
                        '¡Bienvenido de nuevo!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Inicia sesión en tu cuenta para continuar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Mostrar mensaje de error si existe
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      if (_errorMessage != null) const SizedBox(height: 16),

                      // Formulario de inicio de sesión
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Campo de usuario
                            _buildTextField(
                              controller: _usernameOrEmailController,
                              hintText: 'Correo electrónico o usuario',
                              icon: Icons.mail_outline,
                              isPassword: false,
                            ),
                            const SizedBox(height: 16),

                            // Campo de contraseña
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Contraseña',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              togglePasswordVisibility: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              passwordVisible: _passwordVisible,
                            ),
                            const SizedBox(height: 16),

                            // Botón de inicio de sesión
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          'Iniciar sesión',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Enlace para registro
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿No tienes una cuenta? ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Regístrate',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Verifica si el usuario ya está logueado
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      // Redirigir a la pantalla principal si está logueado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Maneja el proceso de inicio de sesión
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse(AppConfig.loginEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usernameOrEmail': _usernameOrEmailController.text,
            'password': _passwordController.text,
          }),
        );

        setState(() => _isLoading = false);

        if (response.statusCode == 200) {
          // Guardar datos del usuario y redirigir
          final data = jsonDecode(response.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data['id'].toString());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (response.statusCode == 401) {
          setState(() => _errorMessage = 'Usuario o contraseña incorrectos');
        } else {
          setState(() => _errorMessage = 'Ha ocurrido un error inesperado');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de conexión. Intenta nuevamente.';
        });
      }
    }
  }

  // Widget para construir campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
    bool? passwordVisible,
    VoidCallback? togglePasswordVisibility,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !(passwordVisible ?? false),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: Colors.grey, size: 24),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      (passwordVisible ?? false)
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                      size: 24,
                    ),
                    onPressed: togglePasswordVisibility,
                  )
                  : null,
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
