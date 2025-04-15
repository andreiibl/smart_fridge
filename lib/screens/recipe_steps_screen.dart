import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            child: const Text(
              'Receta Generada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ensalada de Pollo con Aguacate',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B39EF),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Una receta deliciosa y saludable para disfrutar de una ensalada fresca con pollo y aguacate.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Ingredientes:'),
                  const Text(
                    '• 2 pechugas de pollo a la parrilla\n'
                    '• 1 aguacate maduro\n'
                    '• 100 g de lechuga\n'
                    '• 50 g de tomates cherry\n'
                    '• 1 cucharada de aceite de oliva\n'
                    '• Jugo de 1 limón\n'
                    '• Sal y pimienta al gusto',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Instrucciones:'),
                  const Text(
                    '1. Cocina las pechugas de pollo a la parrilla y córtalas en tiras.\n'
                    '2. Lava la lechuga y los tomates cherry, y córtalos en trozos.\n'
                    '3. Pela y corta el aguacate en cubos.\n'
                    '4. En un tazón grande, mezcla todos los ingredientes.\n'
                    '5. Añade el aceite de oliva, el jugo de limón, sal y pimienta.\n'
                    '6. Sirve y disfruta de esta deliciosa ensalada.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Tiempo de preparación:'),
                  const Text(
                    '25 minutos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  // Botón volver
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B39EF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Volver',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B39EF),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
