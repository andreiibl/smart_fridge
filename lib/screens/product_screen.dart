import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fridge/models/product.dart';
import 'package:smart_fridge/services/product_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// Quitar tildes y acentos de un texto
String removeDiacritics(String text) {
  return text
      .toLowerCase()
      .replaceAllMapped(RegExp(r'[^\x00-\x7F]'), (match) => '')
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '');
}

// Convierte todo a minúsculas y la primera letra a mayúscula
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  final lower = text.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

// Pantalla de lista de productos
class ProductListView extends StatefulWidget {
  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  // Variables de estado
  late Future<List<Product>> products = Future.value([]);
  final List<String> unitOptions = ['gr', 'Kg', 'Litros', 'ml', 'Unidades'];
  final List<String> categoryOptions = [
    'Lácteos',
    'Carnes',
    'Pescados y mariscos',
    'Huevos',
    'Frutas',
    'Verduras',
    'Hierbas frescas',
    'Bebidas',
    'Salsas y condimentos',
    'Congelados',
    'Cereales y granos cocidos',
    'Panadería y masas',
    'Otros',
  ];

  // Controladores y variables para filtros
  bool _showFilters = false;
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _expDateFilterController =
      TextEditingController();
  String _selectedCategory = "";

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [_buildHeader(), _buildFilters(), _buildProductList()],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Método reutilizable para construir campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(prefixIcon),
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
    );
  }

  // Método para obtener la imagen predeterminada según la categoría
  String _getDefaultImageForCategory(String category) {
    const categoryImageMap = {
      'Lácteos': 'assets/images/dairy.png',
      'Carnes': 'assets/images/meat.png',
      'Pescados y mariscos': 'assets/images/fish.png',
      'Huevos': 'assets/images/eggs.png',
      'Frutas': 'assets/images/fruits.png',
      'Verduras': 'assets/images/vegetables.png',
      'Hierbas frescas': 'assets/images/herbs.png',
      'Bebidas': 'assets/images/drinks.png',
      'Salsas y condimentos': 'assets/images/sauces.png',
      'Congelados': 'assets/images/frozen.png',
      'Cereales y granos cocidos': 'assets/images/cereals.png',
      'Panadería y masas': 'assets/images/bakery.png',
      'Otros': 'assets/images/others.png',
    };
    return categoryImageMap[category] ?? 'assets/images/default.png';
  }

  // Conversión para almacenar siempre en gr/ml
  double _parseQuantity(String cantidad, String unidad) {
    double value = double.tryParse(cantidad.replaceAll(',', '.')) ?? 0;
    switch (unidad.toLowerCase()) {
      case 'kg':
        return value * 1000;
      case 'litros':
        return value * 1000;
      default:
        return value;
    }
  }

  String _unitySaved(String unidad) {
    switch (unidad.toLowerCase()) {
      case 'kg':
        return 'gr';
      case 'litros':
        return 'ml';
      default:
        return unidad;
    }
  }

  // Mostrar en kg/l si >= 1000 gr/ml
  String showQuantity(double cantidad, String unidad) {
    if ((unidad == 'gr' || unidad == 'ml') && cantidad >= 1000) {
      final double convertido = cantidad / 1000;
      final String nuevaUnidad = (unidad == 'gr') ? 'Kg' : 'L';
      return '${convertido.toStringAsFixed(2)} $nuevaUnidad';
    }
    return '${cantidad.toStringAsFixed(2)} $unidad';
  }

  // Método genérico para añadir o editar un producto
  Future<void> _showProductDialog({
    required BuildContext context,
    Product? product, // Producto existente (null si es un nuevo producto)
  }) async {
    // Inicializar controladores y variables
    final TextEditingController nameController = TextEditingController(
      text: product?.name ?? "",
    );
    final TextEditingController quantityController = TextEditingController(
      text: product?.quantity.toString() ?? "",
    );
    final TextEditingController dateController = TextEditingController(
      text: product?.expDate ?? "",
    );
    final TextEditingController imageUrlController = TextEditingController(
      text: product?.imageUrl ?? "",
    );
    String selectedUnit = product?.typeQuantity ?? unitOptions.first;
    String selectedCategory = product?.category ?? categoryOptions.first;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                product == null ? 'Añadir producto' : 'Editar producto',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo de texto para el nombre del producto
                    _buildTextField(
                      controller: nameController,
                      labelText: 'Nombre del producto',
                      prefixIcon: Icons.fastfood,
                    ),
                    const SizedBox(height: 15),

                    // Campo de texto para la cantidad
                    _buildTextField(
                      controller: quantityController,
                      labelText: 'Cantidad',
                      prefixIcon: Icons.scale,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Dropdown para unidad de medida
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unidad de medida',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      items:
                          unitOptions.map((String unit) {
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

                    // Dropdown para categoría
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items:
                          categoryOptions.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo de texto para la fecha de caducidad
                    _buildTextField(
                      controller: dateController,
                      labelText: 'Fecha de caducidad',
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              selectedDate ??
                              (product != null
                                  ? DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(product.expDate)
                                  : DateTime.now()),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(picked);
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B39EF),
                  ),
                  child: Text(
                    product == null ? 'Añadir' : 'Guardar',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        quantityController.text.isEmpty ||
                        dateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor, completa los campos requeridos',
                          ),
                        ),
                      );
                      return;
                    }

                    // Asignar imagen por defecto si no se proporciona una o si la categoría cambia
                    String imageUrl = imageUrlController.text.trim();
                    if (product == null ||
                        product.category != selectedCategory) {
                      imageUrl = _getDefaultImageForCategory(selectedCategory);
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('userId');

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error: No se encontró un usuario logueado',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      if (product == null) {
                        // Normaliza el nombre a comparar
                        final normalizedNewName = capitalizeFirst(
                          removeDiacritics(nameController.text.trim()),
                        );

                        // Obtén los productos actuales del usuario
                        final existingProducts = await ProductService()
                            .getProductsByUserId(userId);

                        final exists = existingProducts.any(
                          (p) =>
                              capitalizeFirst(
                                removeDiacritics(p.name.trim()),
                              ) ==
                              normalizedNewName,
                        );

                        if (exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ya existe un producto con ese nombre',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Crear un nuevo producto
                        final newProduct = Product(
                          name: normalizedNewName,
                          quantity: _parseQuantity(
                            quantityController.text,
                            selectedUnit,
                          ),
                          typeQuantity: _unitySaved(selectedUnit),
                          expDate: dateController.text,
                          imageUrl: imageUrl,
                          category: selectedCategory,
                          userId: userId,
                        );

                        await ProductService().createProduct(newProduct);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${newProduct.name} añadido'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Actualizar producto existente
                        final updatedProduct = Product(
                          id: product.id,
                          name: capitalizeFirst(
                            removeDiacritics(nameController.text.trim()),
                          ),
                          quantity: _parseQuantity(
                            quantityController.text,
                            selectedUnit,
                          ),
                          typeQuantity: _unitySaved(selectedUnit),
                          expDate: dateController.text,
                          category: selectedCategory,
                          imageUrl: imageUrl,
                          userId: userId,
                        );

                        await ProductService().updateProduct(updatedProduct);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${updatedProduct.name} actualizado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }

                      _refreshProducts();
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            product == null
                                ? 'Error al añadir producto: $e'
                                : 'Error al actualizar producto: $e',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        );
      },
    );
  }

  // Muestra el diálogo para añadir un nuevo producto
  void _showAddProductDialog(BuildContext context) {
    _showProductDialog(context: context);
  }

  // Muestra el diálogo para editar un producto existente
  void _showEditDialog(BuildContext context, Product product, int index) {
    _showProductDialog(context: context, product: product);
  }

  // Construye el encabezado de la pantalla
  Widget _buildHeader() {
    return Container(
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construye los filtros
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(
              _showFilters ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            ),
            label: const Text('Filtrar productos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B39EF),
              foregroundColor: Colors.white,
            ),
          ),
          if (_showFilters)
            Column(
              children: [
                const SizedBox(height: 10),
                // Filtro por nombre
                _buildTextField(
                  controller: _nameFilterController,
                  labelText: 'Filtrar por nombre',
                  prefixIcon: Icons.search,
                ),
                const SizedBox(height: 10),
                // Filtro por categoría
                DropdownButtonFormField<String>(
                  value:
                      _selectedCategory.isNotEmpty ? _selectedCategory : null,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items:
                      [""].followedBy(categoryOptions).map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category.isEmpty ? "Todas" : category),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? "";
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Filtro por fecha de caducidad
                TextFormField(
                  controller: _expDateFilterController,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por fecha de caducidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _expDateFilterController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Botones para aplicar o limpiar filtros
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_alt),
                        label: const Text('Aplicar filtros'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B39EF),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: "Limpiar filtros",
                      onPressed: () {
                        setState(() {
                          _nameFilterController.clear();
                          _selectedCategory = "";
                          _expDateFilterController.clear();
                          _refreshProducts();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Construye la lista de productos
  Widget _buildProductList() {
    return Expanded(
      child: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'Error al cargar los productos:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay productos disponibles',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                _refreshProducts();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data![index];
                  return _buildProductItem(context, product, index);
                },
              ),
            );
          }
        },
      ),
    );
  }

  // Construye un elemento de producto
  Widget _buildProductItem(BuildContext context, Product product, int index) {
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
                image:
                    product.imageUrl.startsWith('http')
                        ? NetworkImage(product.imageUrl)
                        : AssetImage(product.imageUrl) as ImageProvider,
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
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    showQuantity(product.quantity, product.typeQuantity),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Caduca: ${product.expDate}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showProductOptions(context, product, index),
            ),
          ),
        ],
      ),
    );
  }

  // Construye el botón flotante
  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF4B39EF),
          onPressed: () => _showAddProductDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // Método reutilizable para obtener productos del backend
  Future<List<Product>> _fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se encontró un usuario logueado'),
        ),
      );
      return [];
    }

    return ProductService().getProductsByUserId(userId);
  }

  // Refresca la lista de productos
  void _refreshProducts() async {
    setState(() {
      products = _fetchProducts();
    });
  }

  // Aplica los filtros seleccionados
  void _applyFilters() async {
    final allProducts = await _fetchProducts();
    setState(() {
      products = Future.value(
        allProducts.where((product) {
          final matchesName =
              _nameFilterController.text.isEmpty ||
              product.name.toLowerCase().contains(
                _nameFilterController.text.toLowerCase(),
              );
          final matchesCategory =
              _selectedCategory.isEmpty ||
              product.category == _selectedCategory;
          final matchesExpDate =
              _expDateFilterController.text.isEmpty ||
              DateTime.parse(product.expDate).isBefore(
                DateFormat('yyyy-MM-dd').parse(_expDateFilterController.text),
              );

          return matchesName && matchesCategory && matchesExpDate;
        }).toList(),
      );
    });
  }

  // Muestra las opciones de un producto
  void _showProductOptions(BuildContext context, Product product, int index) {
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
                _showEditDialog(context, product, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar producto'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, product, index);
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

  // Muestra un diálogo de confirmación para eliminar un producto
  void _confirmDelete(BuildContext context, Product product, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de eliminar ${product.name}?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  await ProductService().deleteProduct(product.id!);

                  _refreshProducts();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} eliminado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
