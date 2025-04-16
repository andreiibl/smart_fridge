import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
// Pantalla de login de usuario
class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos del formulario
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estado de visibilidad de contraseñas y otros controle
  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Liberar los controladores al destruir el widget
  @override
  void dispose() 
  {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() 
  {
    super.initState();
    _checkLoginStatus(); // Verifica el estado de login al iniciar
  }

  // Revisa si el usuario ya está logueado en las preferencias locales
  Future<void> _checkLoginStatus() async 
  {
    final prefs = await SharedPreferences.getInstance(); // Obtener instancia de SharedPreferences
    final username = prefs.getString('username'); // Recuperar el nombre de usuario guardado
    // Si el usuario está logueado, redirige a la pantalla principal
    if (username != null) 
    {
      Navigator.pushReplacement
      (
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Función que maneja el proceso de login
  Future<void> _login() async 
  {
    // Validar el formulario
    if (_formKey.currentState?.validate() ?? false) 
    {
      setState(() => _isLoading = true);

      try 
      {
        final response = await http.post
        (
          // Enviar solicitud POST para loguear usuario
          Uri.parse('http://10.0.2.2:8080/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode
          (
            {
            'usernameOrEmail': _usernameOrEmailController.text,
            'password': _passwordController.text,
            }
          ),
        );

        // Detener la carga independientemente de la respuesta del servidor
        setState(() => _isLoading = false);

        if (response.statusCode == 200) 
        {
          // Parsear la respuesta
          final data = jsonDecode(response.body);
          
          // Guardar datos en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', data['username']);
          await prefs.setString('email', data['email']);

          // Redirigir a la pantalla principal
          Navigator.pushReplacement
          (
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (response.statusCode == 401) 
        {
          // Si el login es fallido, mostrar un mensaje de error
          _setErrorMessage('Usuario o contraseña incorrectos');
        } else 
        {
          // Si hay otro error, mostrar un mensaje genérico
          _setErrorMessage('Ha ocurrido un error inesperado');
        }
      } catch (e) 
      {
        // Manejar cualquier error de conexión
        setState(() {
          _isLoading = false;
        });
        _setErrorMessage('Error de conexión. Intenta nuevamente.');
      }
    }
  }

  // Mostrar un cuadro de diálogo con un mensaje de error
  void _setErrorMessage(String message) 
  {
      setState(() {
        _errorMessage = message;
      });
  }

  @override
  Widget build(BuildContext context) 
  {
    final theme = Theme.of(context);

    return GestureDetector
    (
      // Oculta el teclado al tocar fuera del campo
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold
      (
        body: Stack
        (
          children: 
          [
            // Fondo con gradiente
            Container
            (
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration
              (
                gradient: LinearGradient
                (
                  colors: [Color(0xFF4B39EF), Color(0xFF39D2C0)],
                  stops: [0, 1],
                  begin: AlignmentDirectional(1, 1),
                  end: AlignmentDirectional(-1, -1),
                ),
              ),
              child: Padding
              (
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: SingleChildScrollView
                (
                  child: Column
                  (
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: 
                    [
                      // Título y descripción
                      Column
                      (
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: 
                        [
                          Text
                          (
                            '¡Bienvenido de nuevo!',
                            style: theme.textTheme.headlineSmall?.copyWith
                            (
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text
                          (
                            'Inicia sesión en tu cuenta para continuar',
                            style: theme.textTheme.bodyLarge?.copyWith
                            (
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Mostrar mensaje de error si existe
                      if (_errorMessage != null)
                        Container
                        (
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration
                          (
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text
                          (
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      if (_errorMessage != null) const SizedBox(height: 16),


                      // Formulario de registro
                      Form
                      (
                        key: _formKey,
                        child: Column
                        (
                          mainAxisSize: MainAxisSize.max,
                          children: 
                          [
                            // Campo usuario
                            Container
                            (
                              decoration: BoxDecoration
                              (
                                color: Colors.white,
                                boxShadow: const 
                                [
                                  BoxShadow
                                  (
                                    blurRadius: 5,
                                    color: Color(0x1A000000),
                                    offset: Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField
                              (
                                controller: _usernameOrEmailController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration
                                (
                                  hintText: 'Correo electrónico o usuario',
                                  hintStyle: theme.textTheme.bodyMedium?.copyWith
                                  (
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: const Icon
                                  (
                                    Icons.mail_outline,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo contraseña
                            Container
                            (
                              decoration: BoxDecoration
                              (
                                color: Colors.white,
                                boxShadow: const 
                                [
                                  BoxShadow
                                  (
                                    blurRadius: 5,
                                    color: Color(0x1A000000),
                                    offset: Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextFormField
                              (
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration
                                (
                                  hintText: 'Contraseña',
                                  hintStyle: theme.textTheme.bodyMedium?.copyWith
                                  (
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: const Icon
                                  (
                                    Icons.lock_outline,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                  suffixIcon: IconButton
                                  (
                                    icon: Icon
                                    (
                                      _passwordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                    onPressed: () 
                                    {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Botón de login
                            SizedBox
                            (
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton
                              (
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom
                                (
                                  backgroundColor: theme.primaryColor,
                                  shape: RoundedRectangleBorder
                                  (
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text
                                    (
                                        'Iniciar sesión',
                                        style: theme.textTheme.titleSmall?.copyWith
                                        (
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Enlace para registro
                            Row
                            (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: 
                              [
                                Text
                                (
                                  '¿No tienes una cuenta? ',
                                  style: theme.textTheme.bodyMedium?.copyWith
                                  (
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton
                                (
                                  onPressed: () 
                                  {
                                    Navigator.push
                                    (
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                                  style: TextButton.styleFrom
                                  (
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text
                                  (
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
}
