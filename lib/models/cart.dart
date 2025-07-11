import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  String get variantKey => '${product.id}_${color}_$size';

  Map<String, dynamic> toJson() {
    return {
      'product': product.toMap(),
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromMap(json['product']),
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'],
    );
  }
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) {
      final price = double.tryParse(item.product.price.replaceAll('¥', '')) ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  void addItem({
    required Product product,
    required String size,
    required String color,
  }) {
    final key = '${product.id}_${color}_$size';
    
    if (_items.containsKey(key)) {
      // 如果已经存在相同规格的商品，增加数量
      _items.update(
        key,
        (existingItem) => CartItem(
          product: existingItem.product,
          size: existingItem.size,
          color: existingItem.color,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // 添加新的商品规格
      _items.putIfAbsent(
        key,
        () => CartItem(
          product: product,
          size: size,
          color: color,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    if (_items.containsKey(key)) {
      if (quantity > 0) {
        _items.update(
          key,
          (existingItem) => CartItem(
            product: existingItem.product,
            size: existingItem.size,
            color: existingItem.color,
            quantity: quantity,
          ),
        );
      } else {
        _items.remove(key);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  // For persistence
  String toJson() {
    final itemsList = _items.values.map((item) => item.toJson()).toList();
    return jsonEncode(itemsList);
  }
  
  void fromJson(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final Map<String, CartItem> newItems = {};
    for (var json in jsonList) {
      final item = CartItem.fromJson(json);
      newItems[item.variantKey] = item;
    }
    _items = newItems;
    notifyListeners();
  }
} 