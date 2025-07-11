import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../main.dart';
import '../models/product.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 显示登录成功提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登录成功！'),
          duration: Duration(seconds: 2),
        ),
      );
    });
    
    // 使用MainApp作为主页面
    return const MainApp();
  }

  Widget _buildProductImage(Product product) {
    // 现在 imageUrl 字段存储的就是本地路径
    final imagePath = product.imageUrl;
    
    if (imagePath.startsWith('/data/')) {
      // 处理本地文件路径
      print("HomePage: 尝试加载本地图片: $imagePath");
      try {
        return Image.file(
          File(imagePath),
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("HomePage: Error loading local image: $imagePath, Error: $error");
            print("HomePage: Stack trace: $stackTrace");
            return _buildFallbackImage();
          },
        );
      } catch (e, stackTrace) {
        print("HomePage: Exception loading image: $e");
        print("HomePage: Stack trace: $stackTrace");
        return _buildFallbackImage();
      }
    }
    
    // 只有在确实是网络URL的情况下才使用Image.network
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      print("HomePage: 尝试加载网络图片: $imagePath");
      return Image.network(
        imagePath,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("HomePage: Error loading network image: $imagePath, Error: $error");
          print("HomePage: Stack trace: $stackTrace");
          return _buildFallbackImage();
        },
      );
    }
    
    // 如果路径格式不正确，显示备用图片
    print("HomePage: 无效的图片路径: $imagePath");
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    // Implementation of _buildFallbackImage method
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }
} 