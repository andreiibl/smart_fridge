import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class Product {
  String name;
  String quantity;
  String unit;
  String expirationDate;

  Product({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
  });
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = [
    Product(name: 'Aceite de Oliva', quantity: '750', unit: 'ml', expirationDate: 'Caduca: 15/11/2023'),
    Product(name: 'Arroz Blanco', quantity: '1', unit: 'Kg', expirationDate: 'Caduca: 31/12/2023'),
    Product(name: 'Café Molido', quantity: '250', unit: 'gr', expirationDate: 'Caduca: 31/12/2024'),
    Product(name: 'Chocolate Negro', quantity: '100', unit: 'gr', expirationDate: 'Caduca: 31/12/2023'),
    Product(name: 'Espinacas', quantity: '200', unit: 'gr', expirationDate: 'Caduca: 21/10/2023'),
    Product(name: 'Galletas', quantity: '1', unit: 'Unidades', expirationDate: 'Caduca: 30/11/2023'),
    Product(name: 'Huevos', quantity: '12', unit: 'Unidades', expirationDate: 'Caduca: 20/10/2023'),
    Product(name: 'Jamón Cocido', quantity: '150', unit: 'gr', expirationDate: 'Caduca: 05/11/2023'),
    Product(name: 'Leche Entera', quantity: '1', unit: 'Litros', expirationDate: 'Caduca: 15/10/2023'),
    Product(name: 'Manzanas', quantity: '6', unit: 'Unidades', expirationDate: 'Caduca: 25/10/2023'),
    Product(name: 'Mantequilla', quantity: '200', unit: 'gr', expirationDate: 'Caduca: 10/11/2023'),
    Product(name: 'Pan Integral', quantity: '1', unit: 'Unidades', expirationDate: 'Caduca: 18/10/2023'),
    Product(name: 'Pasta Integral', quantity: '500', unit: 'gr', expirationDate: 'Caduca: 31/12/2023'),
    Product(name: 'Pechuga de Pollo', quantity: '500', unit: 'gr', expirationDate: 'Caduca: 17/10/2023'),
    Product(name: 'Plátanos', quantity: '4', unit: 'Unidades', expirationDate: 'Caduca: 26/10/2023'),
    Product(name: 'Queso Cheddar', quantity: '250', unit: 'gr', expirationDate: 'Caduca: 30/10/2023'),
    Product(name: 'Salmón', quantity: '300', unit: 'gr', expirationDate: 'Caduca: 19/10/2023'),
    Product(name: 'Tomates', quantity: '500', unit: 'gr', expirationDate: 'Caduca: 23/10/2023'),
    Product(name: 'Yogur Natural', quantity: '4', unit: 'Unidades', expirationDate: 'Caduca: 22/10/2023'),
    Product(name: 'Zanahorias', quantity: '1', unit: 'Kg', expirationDate: 'Caduca: 28/10/2023'),
  ];

  final List<String> unitOptions = ['gr', 'Kg', 'Litros', 'ml', 'Unidades'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
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
                    'Productos en tu nevera',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductItem(context, index),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF4B39EF),
            onPressed: () => _showAddProductDialog(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    final product = products[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/200?random=$index'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${product.quantity} ${product.unit}', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(product.expirationDate, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showProductOptions(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    String selectedUnit = unitOptions.first;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.fastfood),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.scale),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unidad de medida',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      items: unitOptions.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Fecha de caducidad',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF)),
                  child: const Text('Añadir', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (nameController.text.isEmpty || quantityController.text.isEmpty || dateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, completa todos los campos')),
                      );
                      return;
                    }

                    setState(() {
                      products.add(Product(
                        name: nameController.text,
                        quantity: quantityController.text,
                        unit: selectedUnit,
                        expirationDate: 'Caduca: ${dateController.text}',
                      ));
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${nameController.text} añadido'), backgroundColor: Colors.green),
                    );
                  },
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          },
        );
      },
    );
  }

  void _showProductOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar producto'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar producto'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    final String productName = products[index].name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de eliminar $productName?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  products.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$productName eliminado'), backgroundColor: Colors.red),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, int index) async {
    TextEditingController quantityController = TextEditingController(text: products[index].quantity);
    TextEditingController dateController = TextEditingController(text: products[index].expirationDate.replaceFirst('Caduca: ', ''));
    String selectedUnit = products[index].unit;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Editar ${products[index].name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.scale),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unidad de medida',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      items: unitOptions.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Fecha de caducidad',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF)),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (quantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingresa una cantidad válida')),
                      );
                      return;
                    }

                    setState(() {
                      products[index].quantity = quantityController.text;
                      products[index].unit = selectedUnit;
                      products[index].expirationDate = 'Caduca: ${dateController.text}';
                    });

                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductListScreen()),
                    );
                  },
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          },
        );
      },
    );
  }
}
