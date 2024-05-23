class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.inStock,
  });

  Map<String, dynamic> toMap() {
    // really not sure if we need to store more though..
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'inStock': inStock ? 1 : 0,
    };
  }
  // Factory is a very cool way of managing the creation of objects,
  //in React i have to use singleton to manage the state of the app to this extent,
  //but in dart i can use factories to create objects, 
  //and i can use them to create objects from json, maps, etc.
  // Very cool!
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      inStock: map['inStock'] == 1,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['src']
          : '',
      price: json['regular_price'] is String
          ? double.tryParse(json['regular_price']) ?? 0.0
          : json['regular_price'] is int
              ? (json['regular_price'] as int).toDouble()
              : 0.0,
      inStock: json['in_stock'] ?? false,
    );
  }
}
