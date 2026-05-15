import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final double rating;
  final String description;
  final Color color;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.rating,
    required this.description,
    required this.color,
    required this.imageUrl,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Parse a product from the SSP API response JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    // API uses brand + model_name, local JSON uses name directly
    final name = json.containsKey('brand')
        ? '${json['brand']} ${json['model_name']}'
        : (json['name'] as String? ?? 'Unknown');

    // Image: API returns a nested main_image object or images list
    String imageUrl = '';
    if (json['main_image'] != null) {
      imageUrl = (json['main_image']['image_path'] as String?) ?? '';
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'][0]['image_path'] as String?) ?? '';
    } else if (json['imageUrl'] != null) {
      imageUrl = json['imageUrl'] as String;
    }

    // Assign a subtle color based on category for the card background
    final category = (json['category'] as String?) ?? 'Other';
    final color = _categoryColor(category);

    return Product(
      id: json['id'].toString(),
      name: name,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: category,
      rating: double.tryParse(json['rating']?.toString() ?? '4.5') ?? 4.5,
      description: (json['description'] as String?) ?? '',
      color: color,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'rating': rating,
        'description': description,
        'imageUrl': imageUrl,
      };

  static Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'smartphones':
        return Colors.blueGrey.shade100;
      case 'laptops':
        return Colors.grey.shade300;
      case 'tablets':
        return Colors.indigo.shade100;
      case 'audio':
        return Colors.teal.shade100;
      case 'accessories':
        return Colors.blueAccent.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}

// Kept as local fallback if all network/asset sources fail during development
final List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'iPhone 16 Pro',
    price: 999.00,
    category: 'Smartphones',
    rating: 4.8,
    description: 'The latest iPhone with advanced camera system, titanium design, and A18 Pro chip.',
    color: Colors.blueGrey.shade100,
    imageUrl: 'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?q=80&w=600',
  ),
  Product(
    id: 'p2',
    name: 'MacBook Air M3',
    price: 1099.00,
    category: 'Laptops',
    rating: 4.9,
    description: 'Supercharged by M3, incredibly thin and light.',
    color: Colors.grey.shade300,
    imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=600',
  ),
];
