import 'package:flutter/material.dart';
import 'dart:io';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailPage({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 确保订单金额正确显示
    final dynamic totalPriceValue = orderData['totalPrice'];
    final String totalPrice = totalPriceValue is double 
        ? totalPriceValue.toStringAsFixed(1) 
        : totalPriceValue?.toString() ?? '0.0';
    
    // 确保订单号正确显示
    final String orderNumber = orderData['orderNumber']?.toString() ?? 'ORDER${DateTime.now().millisecondsSinceEpoch}';
    
    // 确保地址正确显示
    final String address = orderData['address']?.toString() ?? '未设置地址';
    
    // 商品价格
    final dynamic priceValue = orderData['price'];
    final String price = priceValue is double 
        ? priceValue.toStringAsFixed(1) 
        : priceValue?.toString() ?? '0.0';
    
    // 配送费用
    final dynamic deliveryFeeValue = orderData['deliveryFee'];
    final String deliveryFee = deliveryFeeValue is double 
        ? deliveryFeeValue.toStringAsFixed(1) 
        : deliveryFeeValue?.toString() ?? '0.0';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('已付款', style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 地址信息
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('修改', style: TextStyle(color: Colors.blue, fontSize: 13)),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 商品信息
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品标签和图片
                  Stack(
                    children: [
                      // 商品图片
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildProductImage(orderData['productImage']),
                      ),
                      // 李宁标签
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: const Text('李宁', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // 商品详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                orderData['productName'] ?? 'WOW 1 魔鬼鱼 高帮篮 硬核 减震轻便 高...',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '¥$price',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${orderData['color'] ?? '紫色'} ${orderData['size'] ?? '39.5'}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            Text(
                              'x${orderData['quantity'] ?? '1'}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 服务信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('顺丰速达', style: TextStyle(fontSize: 14)),
                  Text('¥$deliveryFee', 
                    style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 总价信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('已付款', style: TextStyle(fontSize: 14)),
                  Text(
                    '已支付 ¥$totalPrice',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 8, thickness: 8, color: Color(0xFFF5F5F5)),
            
            // 订单信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildOrderInfoRow('商家信息', orderData['merchantInfo'] ?? 'P142181426', '查看'),
                  const SizedBox(height: 12),
                  _buildOrderInfoRow('订单编号', orderNumber, '复制'),
                  const SizedBox(height: 12),
                  _buildOrderInfoRow('购买渠道', orderData['purchaseChannel'] ?? '闪电仓发'),
                  const SizedBox(height: 12),
                  _buildOrderInfoRow('创建时间', orderData['createTime'] ?? '2025-05-25 15:06:53'),
                  const SizedBox(height: 12),
                  _buildOrderInfoRow('支付方式', orderData['paymentMethod'] ?? '支付宝'),
                  const SizedBox(height: 12),
                  _buildOrderInfoRow('交易状态', '支付成功', '查看'),
                ],
              ),
            ),
            
            // 收起订单信息
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('收起订单信息', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  Icon(Icons.keyboard_arrow_up, color: Colors.grey[600], size: 16),
                ],
              ),
            ),
            
            const Divider(height: 8, thickness: 8, color: Color(0xFFF5F5F5)),
            
            // 官方客服
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic, color: Colors.black, size: 18),
                  const SizedBox(width: 8),
                  const Text('官方客服', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  Text('商品/退换/服务', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
            
            const Divider(height: 1),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // 复制订单号
                    // 实际应用中可以使用Clipboard功能
                  },
                  child: const Text('复制'),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 导航到主页（首页）
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C1B3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '看看其它商品',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderInfoRow(String label, String value, [String? action]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 13)),
            if (action != null) ...[
              const SizedBox(width: 8),
              Text(action, style: const TextStyle(color: Colors.blue, fontSize: 13)),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _buildProductImage(String? imagePath) {
    print("OrderDetailPage: 尝试加载商品图片: $imagePath");
    
    if (imagePath == null || imagePath.isEmpty) {
      print("OrderDetailPage: 图片路径为空，显示默认紫色背景");
      return Container(
        width: 70,
        height: 70,
        color: Colors.purple[800],
      );
    }
    
    // 尝试加载本地文件路径
    if (imagePath.startsWith('/data/') || 
        imagePath.startsWith('C:\\') || 
        imagePath.startsWith('C:/')) {
      
      final normalizedPath = imagePath.replaceAll('\\', '/');
      print("OrderDetailPage: 尝试加载本地文件: $normalizedPath");
      
      return Image.file(
        File(normalizedPath),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("OrderDetailPage: 加载本地文件失败: $error");
          return Container(
            width: 70,
            height: 70,
            color: Colors.purple[800],
            child: const Icon(Icons.image_not_supported, color: Colors.white),
          );
        },
      );
    } 
    // 尝试加载资源文件
    else if (imagePath.startsWith('assets/')) {
      print("OrderDetailPage: 尝试加载资源文件: $imagePath");
      return Image.asset(
        imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("OrderDetailPage: 加载资源文件失败: $error");
          return Container(
            width: 70,
            height: 70,
            color: Colors.purple[800],
            child: const Icon(Icons.broken_image, color: Colors.white),
          );
        },
      );
    }
    
    // 如果是默认的紫色图片，直接显示紫色背景
    print("OrderDetailPage: 未知图片格式，显示默认紫色背景: $imagePath");
    return Container(
      width: 70,
      height: 70,
      color: Colors.purple[800],
      child: Center(
        child: Text(
          imagePath.length > 10 ? imagePath.substring(0, 10) + '...' : imagePath,
          style: const TextStyle(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 