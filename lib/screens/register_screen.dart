import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smart_fridge/config/config.dart';

// Pantalla de registro de usuario
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos del formulario
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estado de visibilidad de contraseñas y otros controles
  bool _passwordVisible = false; // Visibilidad de la contraseña
  bool _confirmPasswordVisible = false; // Visibilidad de confirmar contraseña
  bool _acceptTerms = false; // Estado del checkbox de términos
  bool _receiveEmails = true; // Estado del checkbox de correos promocionales
  bool _isLoading = false; // Indicador de carga
  String? _errorMessage; // Mensaje de error

  @override
  void dispose() {
    // Liberar los controladores al destruir el widget
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y descripción
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear una cuenta',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Completa el formulario para registrarte',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

                      // Formulario de registro
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Campo nombre
                            _buildTextField(
                              controller: _nameController,
                              hintText: 'Nombre completo',
                              prefixIcon: Icons.person_outline,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 16),

                            // Campo usuario
                            _buildTextField(
                              controller: _usernameController,
                              hintText: 'Nombre de usuario',
                              prefixIcon: Icons.alternate_email,
                              validator: _validateUsername,
                            ),
                            const SizedBox(height: 16),

                            // Campo email
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Correo electrónico',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Campo contraseña
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Contraseña',
                              prefixIcon: Icons.lock_outline,
                              obscureText: !_passwordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16),

                            // Campo confirmar contraseña
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirmar contraseña',
                              prefixIcon: Icons.lock_outline,
                              obscureText: !_confirmPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                              ),
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 16),

                            // Checkbox aceptar términos
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value!;
                                    });
                                  },
                                  activeColor: theme.primaryColor,
                                  checkColor: Colors.white,
                                ),
                                Expanded(
                                  child: Wrap(
                                    children: [
                                      Text(
                                        'Acepto los ',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Acción para mostrar términos y condiciones
                                        },
                                        child: Text(
                                          'Términos y Condiciones',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Checkbox recibir correos
                            Row(
                              children: [
                                Checkbox(
                                  value: _receiveEmails,
                                  onChanged: (value) {
                                    setState(() {
                                      _receiveEmails = value!;
                                    });
                                  },
                                  activeColor: theme.primaryColor,
                                  checkColor: Colors.white,
                                ),
                                Text(
                                  'Recibir correos promocionales',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Botón de registro
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          'Registrarse',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Enlace a login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes una cuenta? ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Inicia sesión',
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

  // Función para enviar los datos del formulario
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar los términos y condiciones'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse(AppConfig.registerEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text,
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro exitoso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage = errorData["message"] ?? 'Error en el registro';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error de conexión: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Validaciones reutilizables
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(value)) {
      return 'El nombre solo puede contener letras y espacios';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa un nombre de usuario';
    }
    if (value.length < 4 || value.length > 20) {
      return 'Debe tener entre 4 y 20 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Solo se permiten letras, números y guiones bajos';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Correo electrónico no válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    if (!RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%^&*()_+{}[\]:;<>,.?~\\/-]).{6,}$',
    ).hasMatch(value)) {
      return 'Debe incluir mayúscula, minúscula, número y símbolo';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Método reutilizable para construir campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
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
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}
