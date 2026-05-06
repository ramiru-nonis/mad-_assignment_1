import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = dummyProducts;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _favoriteIds = [];

  List<Product> get allProducts => _products;

  List<Product> get favorites => _products.where((p) => _favoriteIds.contains(p.id)).toList();

  List<String> get categories {
    final Set<String> uniqueCategories = {'All'};
    for (var p in _products) {
      uniqueCategories.add(p.category);
    }
    return uniqueCategories.toList();
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
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

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }
}
