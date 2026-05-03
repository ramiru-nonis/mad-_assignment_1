import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final double rating;
  final String description;
  final Color color;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.rating,
    required this.description,
    required this.color,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

final List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'iPhone 16 Pro',
    price: 999.00,
    category: 'Smartphones',
    rating: 4.8,
    description: 'The latest iPhone with advanced camera system, titanium design, and A18 Pro chip.',
    color: Colors.blueGrey.shade100,
  ),
  Product(
    id: 'p2',
    name: 'Samsung Galaxy S25 Ultra',
    price: 1199.00,
    category: 'Smartphones',
    rating: 4.9,
    description: 'Ultimate Android experience with S-Pen, quad camera setup, and Snapdragon 8 Gen 4.',
    color: Colors.teal.shade100,
  ),
  Product(
    id: 'p3',
    name: 'MacBook Air M3',
    price: 1099.00,
    category: 'Laptops',
    rating: 4.9,
    description: 'Supercharged by M3, incredibly thin and light. Up to 18 hours of battery life.',
    color: Colors.grey.shade300,
  ),
  Product(
    id: 'p4',
    name: 'Dell XPS 15',
    price: 1499.00,
    category: 'Laptops',
    rating: 4.7,
    description: 'A perfect balance of power and portability with a stunning OLED display.',
    color: Colors.blueAccent.shade100,
  ),
  Product(
    id: 'p5',
    name: 'iPad Pro 13"',
    price: 1299.00,
    category: 'Tablets',
    rating: 4.8,
    description: 'The ultimate iPad experience with M4 chip, OLED display, and all-day battery life.',
    color: Colors.indigo.shade100,
  ),
  Product(
    id: 'p6',
    name: 'Sony WH-1000XM5',
    price: 398.00,
    category: 'Audio',
    rating: 4.8,
    description: 'Industry-leading noise cancellation, exceptional sound quality, and comfortable design.',
    color: Colors.black87,
  ),
  Product(
    id: 'p7',
    name: 'AirPods Pro 2',
    price: 249.00,
    category: 'Audio',
    rating: 4.9,
    description: 'Rich, high-quality audio and magic AirPods experience with next-level active noise cancellation.',
    color: Colors.grey.shade200,
  ),
  Product(
    id: 'p8',
    name: 'Logitech MX Master 3S',
    price: 99.00,
    category: 'Accessories',
    rating: 4.8,
    description: 'An iconic mouse remastered. Feel every moment of your workflow with even more precision.',
    color: Colors.blueGrey.shade200,
  ),
];
