import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/order_provider.dart';
import '../models/order.dart';
import 'order_detail_page.dart';
import 'dart:io';

class OrdersPage extends StatefulWidget {
  final int initialTab;
  
  const OrdersPage({super.key, this.initialTab = 0});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5, 
      vsync: this,
      initialIndex: widget.initialTab,
    );
    
    // 加载订单数据
    _loadOrders();
  }
  
  Future<void> _loadOrders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      await Provider.of<OrderProvider>(context, listen: false).loadOrders();
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              Text(
                '品牌名/商品名/订单号',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.headset_mic, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab栏
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              indicatorColor: Colors.black,
              indicatorWeight: 3,
              tabs: [
                Tab(text: '全部'),
                Tab(text: '待付款'),
                Tab(text: '待发货'),
                Tab(text: '待收货'),
                Tab(text: '评价'),
              ],
            ),
          ),
          
          // Tab内容
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? _buildErrorView()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(context, Provider.of<OrderProvider>(context).orders),
                          _buildOrderList(context, Provider.of<OrderProvider>(context).pendingPaymentOrders),
                          _buildOrderList(context, Provider.of<OrderProvider>(context).pendingShipmentOrders),
                          _buildOrderList(context, Provider.of<OrderProvider>(context).pendingReceiptOrders),
                          _buildOrderList(context, Provider.of<OrderProvider>(context).pendingEvaluationOrders),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '加载订单失败',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C1B3),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('重试', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderList(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyOrderView();
    }
    
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderItem(context, order);
        },
      ),
    );
  }
  
  Widget _buildOrderItem(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderData: {
                'productName': order.productName,
                'price': order.price.toString(),
                'size': order.size,
                'color': order.color,
                'quantity': order.quantity.toString(),
                'productImage': order.productImage,
                'address': order.address,
                'totalPrice': order.totalPrice.toString(),
                'deliveryFee': order.deliveryFee.toString(),
                'orderNumber': order.orderNumber,
                'createTime': order.createTime,
                'paymentMethod': order.paymentMethod,
                'purchaseChannel': order.purchaseChannel,
                'merchantInfo': order.merchantInfo,
              },
            ),
          ),
        ).then((_) => _loadOrders());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单状态栏
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '交易${order.transactionStatus}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.isDelivered && !order.isEvaluated)
                    Text(
                      '已在 ${_extractDate(order.createTime)} 签收',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  const Spacer(),
                  Icon(Icons.more_horiz, color: Colors.grey),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 商品信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _buildProductImage(order.productImage),
                  ),
                  const SizedBox(width: 12),
                  
                  // 商品详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.color} ${order.size}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '¥${order.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'x${order.quantity}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
            
            // 订单操作栏
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '实付款 ¥${order.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        order.transactionStatus == '待支付' ? '立即付款' : '查看详情',
                        order.transactionStatus == '待支付',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String text, bool isPrimary) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF00C1B3) : Colors.white,
          side: BorderSide(color: isPrimary ? const Color(0xFF00C1B3) : Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.black,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyOrderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 绿色线条
          Container(
            height: 100,
            width: 2,
            color: Colors.cyan[100],
          ),
          
          // 卡通人物
          Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆点
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.cyan[100],
                  shape: BoxShape.circle,
                ),
              ),
              
              // 卡通人物图片
              Image.asset(
                'assets/pic/img_6.png',
                width: 120,
                height: 120,
              ),
            ],
          ),
          
          // 绿色线条
          Container(
            height: 100,
            width: 2,
            color: Colors.cyan[100],
          ),
          
          const SizedBox(height: 16),
          
          // 暂无订单文本
          Text(
            '暂无相关订单',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductImage(String imagePath) {
    print("OrdersPage: 尝试加载商品图片: $imagePath");
    
    if (imagePath.isEmpty) {
      print("OrdersPage: 图片路径为空，显示默认紫色背景");
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
      print("OrdersPage: 尝试加载本地文件: $normalizedPath");
      
      return Image.file(
        File(normalizedPath),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("OrdersPage: 加载本地文件失败: $error");
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
      print("OrdersPage: 尝试加载资源文件: $imagePath");
      return Image.asset(
        imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("OrdersPage: 加载资源文件失败: $error");
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
    print("OrdersPage: 未知图片格式，显示默认紫色背景: $imagePath");
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
  
  String _extractDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return '';
    }
  }
} 