import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final _storage = LocalStorageService();

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  double get tax => subtotal * 0.08;
  double get total => subtotal + tax;

  /// Load persisted cart from SharedPreferences on app start.
  Future<void> init(List<Product> availableProducts) async {
    final cartJson = await _storage.loadCart();
    _items.clear();
    cartJson.forEach((key, value) {
      final itemMap = value as Map<String, dynamic>;
      final productJson = itemMap['product'] as Map<String, dynamic>;
      // Try to find the product from the live list first for fresh data
      Product? product;
      try {
        product = availableProducts.firstWhere((p) => p.id == productJson['id'].toString());
      } catch (_) {
        product = Product.fromJson(productJson);
      }
      _items[key] = CartItem(
        id: itemMap['id'] as String,
        product: product,
        quantity: itemMap['quantity'] as int,
      );
    });
    notifyListeners();
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          product: product,
          quantity: 1,
        ),
      );
    }
    _persist();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    _persist();
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
      _persist();
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    _persist();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _storage.clearCart();
    notifyListeners();
  }

  void _persist() {
    final cartJson = <String, dynamic>{};
    _items.forEach((key, item) {
      cartJson[key] = {
        'id': item.id,
        'quantity': item.quantity,
        'product': item.product.toJson(),
      };
    });
    _storage.saveCart(cartJson);
  }
}
