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

  double get totalPrice {
    // Remove currency symbol and convert to double
    String priceStr = product.price.replaceAll('¥', '');
    double price = double.tryParse(priceStr) ?? 0.0;
    return price * quantity;
  }

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'size': size,
    'color': color,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product']),
    size: json['size'],
    color: json['color'],
    quantity: json['quantity'],
  );
} 