import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyCart = 'cart_items';
  static const _keyFavorites = 'favorite_ids';
  static const _keyProductsCache = 'products_cache';

  // ─── Cart ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCart);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveCart(Map<String, dynamic> cartJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCart, jsonEncode(cartJson));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCart);
  }

  // ─── Favorites ───────────────────────────────────────────────────────────────

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> saveFavorites(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, ids);
  }

  // ─── Product Cache ────────────────────────────────────────────────────────────

  Future<String?> loadProductsCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProductsCache);
  }

  Future<void> saveProductsCache(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProductsCache, jsonString);
  }
}
