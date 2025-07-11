import 'dart:io';
import 'package:flutter/material.dart';
import '../backend/database_helper.dart';
import '../models/product.dart';
import '../backend/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 数据库检查工具类
class DatabaseInspector {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  /// 检查产品表中的所有数据
  static Future<List<Map<String, dynamic>>> inspectProductsTable() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> products = await db.query('products');
      
      print("DatabaseInspector: 产品表中有 ${products.length} 条记录");
      
      for (var product in products) {
        print("DatabaseInspector: 产品ID: ${product['id']}");
        print("DatabaseInspector: 标题: ${product['title']}");
        print("DatabaseInspector: 图片URL: ${product['image_url']}");
        print("DatabaseInspector: 本地图片路径: ${product['local_image_path']}");
        
        // 检查本地图片路径
        if (product['local_image_path'] != null && product['local_image_path'].toString().isNotEmpty) {
          final file = File(product['local_image_path']);
          if (await file.exists()) {
            final size = await file.length();
            print("DatabaseInspector: 本地图片文件存在，大小: $size 字节");
          } else {
            print("DatabaseInspector: 本地图片文件不存在: ${product['local_image_path']}");
          }
        }
        print("DatabaseInspector: -------------------------");
      }
      
      return products;
    } catch (e, stackTrace) {
      print("DatabaseInspector: 检查产品表时出错: $e");
      print("DatabaseInspector: 堆栈跟踪: $stackTrace");
      return [];
    }
  }
  
  /// 显示数据库检查对话框
  static void showDatabaseInspectorDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('数据库检查'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: inspectProductsTable(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (snapshot.hasError) {
              return Text('检查数据库时出错: ${snapshot.error}');
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('没有找到任何产品数据');
            }
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('共找到 ${snapshot.data!.length} 条产品记录', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...snapshot.data!.map((product) => _buildProductInfo(product, context)),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () async {
              // 清除所有本地图片路径
              final db = await _databaseHelper.database;
              await db.update('products', {'local_image_path': null});
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已清除所有本地图片路径')),
                );
                Navigator.of(ctx).pop();
                
                // 重新加载产品数据
                await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
              }
            },
            child: const Text('清除所有本地路径'),
          ),
          TextButton(
            onPressed: () async {
              // 修复所有图片路径
              final result = await _fixAllImagePaths(context);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已修复 ${result['fixed']} 个图片路径')),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('修复图片路径'),
          ),
        ],
      ),
    );
  }
  
  /// 修复所有图片路径
  static Future<Map<String, dynamic>> _fixAllImagePaths(BuildContext context) async {
    final result = {
      'total': 0,
      'fixed': 0,
    };
    
    try {
      final db = await _databaseHelper.database;
      final products = await db.query('products');
      result['total'] = products.length;
      
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/product_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      for (var product in products) {
        final productId = product['id'];
        final localImagePath = product['local_image_path'];
        
        if (localImagePath != null && localImagePath.toString().isNotEmpty) {
          // 检查是否是Windows路径
          if (localImagePath.toString().contains('\\')) {
            // 提取文件名
            final fileName = path.basename(localImagePath.toString());
            // 创建新的路径
            final newPath = '${imageDir.path}/$fileName';
            
            // 更新数据库
            await db.update(
              'products',
              {'local_image_path': newPath},
              where: 'id = ?',
              whereArgs: [productId],
            );
            
            result['fixed'] = (result['fixed'] as int) + 1;
            print("已修复产品 $productId 的图片路径: $localImagePath -> $newPath");
          }
        }
      }
      
      // 重新加载产品数据
      if (context.mounted) {
        await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      }
    } catch (e) {
      print("修复图片路径时出错: $e");
    }
    
    return result;
  }
  
  /// 构建产品信息卡片
  static Widget _buildProductInfo(Map<String, dynamic> product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${product['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('标题: ${product['title']}'),
            Text('价格: ${product['price']}'),
            Text('图片URL: ${product['image_url'] ?? "无"}'),
            Text('本地图片路径: ${product['local_image_path'] ?? "无"}'),
            const SizedBox(height: 8),
            if (product['local_image_path'] != null && product['local_image_path'].toString().isNotEmpty)
              FutureBuilder<bool>(
                future: File(product['local_image_path']).exists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('检查文件中...');
                  }
                  return Text('本地文件存在: ${snapshot.data == true ? "是" : "否"}',
                    style: TextStyle(
                      color: snapshot.data == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    // 清除此产品的本地图片路径
                    final db = await _databaseHelper.database;
                    await db.update(
                      'products', 
                      {'local_image_path': null},
                      where: 'id = ?',
                      whereArgs: [product['id']],
                    );
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已清除产品 ${product['id']} 的本地图片路径')),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('清除本地路径'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 