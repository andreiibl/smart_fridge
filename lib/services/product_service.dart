import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_fridge/models/product.dart';
import 'package:smart_fridge/config/config.dart';

class ProductService {
  // Obtener todos los productos
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(AppConfig.productsEndpoint));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  // Obtener un producto por ID
  Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('${AppConfig.productsEndpoint}/$id'),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromJson(json.decode(decodedBody));
    } else {
      throw Exception('Error al cargar el producto');
    }
  }

  // Crear un producto
  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(AppConfig.productsEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromJson(json.decode(decodedBody));
    } else {
      throw Exception('Error al crear el producto');
    }
  }

  // Actualizar un producto
  Future<Product> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('El producto no tiene ID');
    }

    final response = await http.put(
      Uri.parse('${AppConfig.productsEndpoint}/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Product.fromJson(json.decode(decodedBody));
    } else {
      throw Exception(
        'Error al actualizar el producto. Código: ${response.statusCode}',
      );
    }
  }

  // Eliminar un producto
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.productsEndpoint}/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el producto');
    }
  }

  // Buscar productos por nombre
  Future<List<Product>> getProductsByName(String name) async {
    final response = await http.get(
      Uri.parse('${AppConfig.productsEndpoint}/search/name?name=$name'),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al buscar productos por nombre');
    }
  }

  // Buscar productos por categoría
  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.productsEndpoint}/search/category?category=$category',
      ),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al buscar productos por categoría');
    }
  }

  // Buscar productos por usuario
  Future<List<Product>> getProductsByUserId(String userId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.productsEndpoint}/search/user/$userId'),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al buscar productos por userId');
    }
  }
  // Borrar todos los productos de un usuario
  Future<bool> deleteAllProductsByUserId(String userId) async {
  final response = await http.delete(
    Uri.parse('${AppConfig.productsEndpoint}/all/$userId'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
  );
  return response.statusCode == 200;
}
}
