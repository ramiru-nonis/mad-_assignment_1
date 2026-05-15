import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

enum DataSource { api, external, local, cache, dummy }

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  DataSource _dataSource = DataSource.dummy;

  final _storage = LocalStorageService();
  final _apiService = ApiService();

  // External JSON URL (GitHub raw — satisfies "external JSON file" requirement)
  static const String _externalJsonUrl =
      'https://raw.githubusercontent.com/ramiru-nonis/MAD-Assignment-02/main/assets/data/products_offline.json';

  // ─── Getters ──────────────────────────────────────────────────────────────────

  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  DataSource get dataSource => _dataSource;
  String get dataSourceLabel {
    switch (_dataSource) {
      case DataSource.api:
        return 'Live API';
      case DataSource.external:
        return 'External JSON';
      case DataSource.local:
        return 'Offline';
      case DataSource.cache:
        return 'Cached';
      case DataSource.dummy:
        return 'Demo';
    }
  }

  List<Product> get favorites =>
      _products.where((p) => _favoriteIds.contains(p.id)).toList();

  List<String> get categories {
    final Set<String> uniqueCategories = {'All'};
    for (var p in _products) {
      uniqueCategories.add(p.category);
    }
    return uniqueCategories.toList();
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Product> get featuredProducts => _products.take(4).toList();
  List<Product> get bestSellers => _products.reversed.take(6).toList();

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Init ─────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _favoriteIds = await _storage.loadFavorites();
    await fetchProducts();
  }

  // ─── Multi-Source Fetch ───────────────────────────────────────────────────────

  /// Priority: SSP API → External JSON → Local Asset → Cached → Dummy
  Future<void> fetchProducts({String? token}) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    // 1. Try SSP API
    try {
      final raw = await _apiService.fetchProducts(token: token);
      _products = raw.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
      _dataSource = DataSource.api;
      await _storage.saveProductsCache(jsonEncode(raw));
      _isLoading = false;
      notifyListeners();
      return;
    } catch (_) {}

    // 2. Try external JSON (internet, non-API source)
    try {
      final response = await http.get(Uri.parse(_externalJsonUrl))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body) as List<dynamic>;
        _products = raw.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
        _dataSource = DataSource.external;
        await _storage.saveProductsCache(response.body);
        _isLoading = false;
        notifyListeners();
        return;
      }
    } catch (_) {}

    // 3. Try local asset JSON (bundled with app — offline fallback)
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/products_offline.json');
      final raw = jsonDecode(jsonString) as List<dynamic>;
      _products = raw.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
      _dataSource = DataSource.local;
      _isLoading = false;
      notifyListeners();
      return;
    } catch (_) {}

    // 4. Try SharedPreferences cache
    try {
      final cached = await _storage.loadProductsCache();
      if (cached != null) {
        final raw = jsonDecode(cached) as List<dynamic>;
        _products = raw.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
        _dataSource = DataSource.cache;
        _isLoading = false;
        notifyListeners();
        return;
      }
    } catch (_) {}

    // 5. Absolute fallback — hardcoded dummy products
    _products = dummyProducts;
    _dataSource = DataSource.dummy;
    _hasError = true;
    _errorMessage = 'Could not load products. Showing demo data.';
    _isLoading = false;
    notifyListeners();
  }

  // ─── Category & Search ────────────────────────────────────────────────────────

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Favorites ────────────────────────────────────────────────────────────────

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    _storage.saveFavorites(_favoriteIds);
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);
}
