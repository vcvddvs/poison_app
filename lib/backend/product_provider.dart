import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import 'database_helper.dart';

class ProductVariant {
  final int productId;
  final String color;
  final String size;
  final String price;
  final int stock;
  final String? localImagePath;

  ProductVariant({
    required this.productId,
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
    this.localImagePath,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      productId: map['product_id'] as int,
      color: map['color'] as String,
      size: map['size'] as String,
      price: map['price'] as String,
      stock: map['stock'] as int,
      localImagePath: map['local_image_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
      'local_image_path': localImagePath,
    };
  }
}

class ProductProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isLoading = false;
  Map<int, List<ProductVariant>> _productVariants = {};

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;

  // 获取指定商品的所有规格
  List<ProductVariant> getVariantsForProduct(int productId) {
    return _productVariants[productId] ?? [];
  }

  // 获取指定商品的所有颜色选项
  List<String> getColorsForProduct(int productId) {
    final variants = _productVariants[productId] ?? [];
    final colors = variants.map((v) => v.color).toSet().toList();
    print("获取商品 $productId 的所有颜色: $colors");
    return colors;
  }

  // 获取指定商品和颜色的所有尺码选项
  List<String> getSizesForProductAndColor(int productId, String color) {
    final variants = _productVariants[productId] ?? [];
    final sizes = variants
        .where((v) => v.color == color)
        .map((v) => v.size)
        .toSet()
        .toList();
    print("获取商品 $productId 颜色 $color 的所有尺码: $sizes");
    return sizes;
  }

  // 获取指定规格的变体
  ProductVariant? getVariant(int productId, String color, String size) {
    final variants = _productVariants[productId] ?? [];
    try {
      final variant = variants.firstWhere(
        (v) => v.color == color && (size.isEmpty || v.size == size),
      );
      print("找到商品变体: productId=$productId, color=$color, size=$size, price=${variant.price}");
      return variant;
    } catch (e) {
      print("未找到变体: productId=$productId, color=$color, size=$size");
      return null;
    }
  }

  // 初始化获取所有商品
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _databaseHelper.getProducts();
      print("加载了 ${_products.length} 个商品");
      
      // 验证和修复图片路径
      await _verifyAndFixImagePaths();
      
      // 加载所有商品的变体
      for (var product in _products) {
        if (product.id != null) {
          await loadProductVariants(product.id!);
        }
      }
    } catch (e) {
      print("加载商品时出错: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
  
  // 验证和修复图片路径
  Future<void> _verifyAndFixImagePaths() async {
    for (var i = 0; i < _products.length; i++) {
      final product = _products[i];
      
      // 检查本地路径是否存在
      if (product.localImagePath != null && product.localImagePath!.isNotEmpty) {
        final file = File(product.localImagePath!);
        if (!await file.exists()) {
          print("产品 ${product.id} 的本地图片不存在: ${product.localImagePath}");
          
          // 如果本地图片不存在，尝试使用imageUrl字段
          if (product.imageUrl.isNotEmpty) {
            if (product.imageUrl.startsWith('assets/')) {
              // 如果是资源路径，不需要修改
              print("产品 ${product.id} 使用资源路径: ${product.imageUrl}");
            } else if (product.imageUrl.startsWith('http')) {
              // 如果是网络路径，不需要修改
              print("产品 ${product.id} 使用网络路径: ${product.imageUrl}");
            }
          }
        } else {
          print("产品 ${product.id} 的本地图片存在: ${product.localImagePath}");
        }
      } else {
        print("产品 ${product.id} 没有本地图片路径，使用imageUrl: ${product.imageUrl}");
      }
    }
  }

  Future<void> loadProductVariants(int productId) async {
    try {
      final variants = await _databaseHelper.getProductVariants(productId);
      _productVariants[productId] = variants.map((v) => ProductVariant.fromMap(v)).toList();
      print("加载商品 $productId 的变体: ${variants.length} 个");
      notifyListeners();
    } catch (e) {
      print("加载商品变体时出错: $e");
    }
  }

  // 根据ID获取商品
  Future<Product?> getProductById(int id) async {
    try {
      return await _databaseHelper.getProduct(id);
    } catch (e) {
      print('获取商品失败: $e');
      return null;
    }
  }

  // 添加商品规格
  Future<bool> addProductVariant(ProductVariant variant) async {
    try {
      final id = await _databaseHelper.addProductVariant(variant.toMap());
      if (id > 0) {
        final variants = _productVariants[variant.productId] ?? [];
        variants.add(variant);
        _productVariants[variant.productId] = variants;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("ProductProvider: 添加商品规格时出错: $e");
    }
    return false;
  }

  void resetDatabase() async {
    try {
      await _databaseHelper.resetDatabase();
      await fetchProducts();
    } catch (e) {
      print("重置数据库时出错: $e");
    }
  }

  // 获取商品规格信息
  Future<List<Map<String, dynamic>>> getProductSpecifications(int productId) async {
    try {
      final specs = await _databaseHelper.getProductSpecifications(productId);
      print("加载商品 $productId 的规格信息: ${specs.length} 条");
      return specs;
    } catch (e) {
      print("加载商品规格时出错: $e");
      return [];
    }
  }

  Future<void> updateBrandPath(int productId, String newPath) async {
    try {
      await _databaseHelper.updateBrandPath(productId, newPath);
      notifyListeners();
    } catch (e) {
      print("更新品牌路径时出错: $e");
    }
  }
  
  // 强制刷新产品数据
  Future<void> forceRefreshProducts() async {
    print("开始强制刷新产品数据");
    _products = [];
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await _databaseHelper.getProducts();
      print("强制刷新：加载了 ${_products.length} 个商品");
      
      // 验证和修复图片路径
      await _verifyAndFixImagePaths();
      
      // 加载所有商品的变体
      for (var product in _products) {
        if (product.id != null) {
          await loadProductVariants(product.id!);
        }
      }
    } catch (e) {
      print("强制刷新时出错: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // 搜索商品
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    try {
      // 转换查询为小写以进行不区分大小写的搜索
      final lowercaseQuery = query.toLowerCase();
      
      // 如果商品列表为空，先加载商品
      if (_products.isEmpty) {
        await fetchProducts();
      }
      
      // 在内存中过滤商品
      final results = _products.where((product) {
        final titleMatch = product.title.toLowerCase().contains(lowercaseQuery);
        final brandMatch = product.brand != null && 
                          product.brand!.toLowerCase().contains(lowercaseQuery);
        final tagMatch = product.tag != null && 
                        product.tag!.toLowerCase().contains(lowercaseQuery);
        
        return titleMatch || brandMatch || tagMatch;
      }).toList();
      
      print("搜索 '$query' 找到 ${results.length} 个结果");
      return results;
    } catch (e) {
      print("搜索商品时出错: $e");
      return [];
    }
  }
} 