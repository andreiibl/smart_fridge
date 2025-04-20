class Product {
  // Atributos del producto
  int? id;
  String name;
  double quantity;
  String typeQuantity;
  String expDate;
  String imageUrl;
  String category;
  String userId;
  // Constructor de la clase
  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.typeQuantity,
    required this.expDate,
    required this.imageUrl,
    required this.category,
    required this.userId,
  });
  // Método predeterminado para crear un producto desde un JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] ?? 'Sin nombre',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      typeQuantity: json['typeQuantity'] ?? 'Sin unidad',
      expDate: json['expDate'] ?? 'Sin fecha',
      imageUrl: json['imageUrl'] ?? 'assets/images/default.png',
      category: json['category'] ?? 'Otros',
      userId: json['userId'] ?? 'Desconocido',
    );
  }
  // Método para convertir un producto a formato JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'typeQuantity': typeQuantity,
      'expDate': expDate,
      'imageUrl': imageUrl,
      'category': category,
      'user': {'id': userId},
    };
  }
}
