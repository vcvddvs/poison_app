import 'package:flutter/foundation.dart';

class ProductVariant {
  final int? id;
  final int productId;
  final String color;
  final String size;
  final String price;
  final int stock;
  final String? imageUrl;
  final String? localImagePath;

  ProductVariant({
    this.id,
    required this.productId,
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.localImagePath,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'],
      productId: map['product_id'],
      color: map['color'],
      size: map['size'],
      price: map['price'],
      stock: map['stock'],
      imageUrl: map['image_url'],
      localImagePath: map['local_image_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'local_image_path': localImagePath,
    };
  }
} 