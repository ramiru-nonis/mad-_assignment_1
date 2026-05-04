import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = dummyProducts;
  String _selectedCategory = 'All';

  List<Product> get allProducts => _products;

  List<String> get categories {
    final Set<String> uniqueCategories = {'All'};
    for (var p in _products) {
      uniqueCategories.add(p.category);
    }
    return uniqueCategories.toList();
  }

  String get selectedCategory => _selectedCategory;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  List<Product> get featuredProducts {
    return _products.take(4).toList(); // Mock featured
  }

  List<Product> get bestSellers {
    return _products.reversed.take(6).toList(); // Mock best sellers
  }
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
