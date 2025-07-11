import 'dart:io';
import 'package:flutter/material.dart';

// 通用商品卡片组件
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String? brand;
  final String? tag;
  final String? subInfo;
  final int? paymentCount;
  final bool isLowestPrice;
  final VoidCallback? onTap;
  final String? localImagePath;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.brand,
    this.tag,
    this.subInfo,
    this.paymentCount,
    this.isLowestPrice = false,
    this.onTap,
    this.localImagePath,
  });

  @override
  Widget build(BuildContext context) {
    // 添加调试信息
    print("ProductCard for $title: localImagePath=${localImagePath ?? 'null'}");
    
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  _buildProductImage(),
                  if (isLowestPrice)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '全网低价',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null && tag!.isNotEmpty && !isLowestPrice)
                    Row(
                      children: [
                        Text(
                          tag!,
                          style: const TextStyle(fontSize: 12, color: Colors.cyan, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        if (tag!.contains('NEW'))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                  if (brand != null && brand!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (brand == 'Apple')
                          const Icon(Icons.apple, size: 16, color: Colors.black),
                        if (brand == 'New Balance')
                          const Icon(Icons.sports_basketball, size: 16, color: Colors.black),
                        if (brand != 'Apple' && brand != 'New Balance')
                          const Icon(Icons.shopping_bag, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            brand!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (price.isNotEmpty)
                    Text(
                      price,
                      style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  if (paymentCount != null && paymentCount! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _formatPaymentCount(paymentCount!),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    )
                  else if (subInfo != null && subInfo!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subInfo!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建商品图片
  Widget _buildProductImage() {
    // 现在 imageUrl 字段存储的就是本地路径
    if (imageUrl.startsWith('/data/')) {
      // 处理本地文件路径
      print("ProductCard: 尝试加载本地图片: $imageUrl");
      try {
        return Image.file(
          File(imageUrl),
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("ProductCard: Error loading local image for $title: $error");
            print("ProductCard: Stack trace: $stackTrace");
            return _buildFallbackImage();
          },
        );
      } catch (e, stackTrace) {
        print("ProductCard: Exception loading local image: $e");
        print("ProductCard: Stack trace: $stackTrace");
        return _buildFallbackImage();
      }
    }
    
    // 如果路径格式不正确，显示备用图片
    print("ProductCard: 无效的图片路径: $imageUrl");
    return _buildFallbackImage();
  }

  // 构建备用图片
  Widget _buildFallbackImage() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }

  String _formatPaymentCount(int count) {
    if (count >= 10000) {
      double wan = count / 10000.0;
      return '${wan.toStringAsFixed(wan.truncateToDouble() == wan ? 0 : 1)}万+人付款';
    } else {
      return '$count人付款';
    }
  }
} 