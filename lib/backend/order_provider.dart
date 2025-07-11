import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/order.dart';
import 'database_helper.dart';
import 'auth_service.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService;
  List<Order> _orders = [];
  List<Order> _pendingPaymentOrders = [];
  List<Order> _pendingShipmentOrders = [];
  List<Order> _pendingReceiptOrders = [];
  List<Order> _pendingEvaluationOrders = [];

  OrderProvider(this._authService);

  List<Order> get orders => _orders;
  List<Order> get pendingPaymentOrders => _pendingPaymentOrders;
  List<Order> get pendingShipmentOrders => _pendingShipmentOrders;
  List<Order> get pendingReceiptOrders => _pendingReceiptOrders;
  List<Order> get pendingEvaluationOrders => _pendingEvaluationOrders;

  // 加载所有订单
  Future<void> loadOrders() async {
    if (!_authService.isLoggedIn || _authService.currentUser == null) return;
    
    try {
      final userId = _authService.currentUser!.id!;
      
      // 检查数据库中是否存在orders表
      final db = await _databaseHelper.database;
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='orders'");
      
      if (tables.isEmpty) {
        // 如果表不存在，抛出异常
        throw Exception("订单表不存在，请重启应用");
      }
      
      _orders = await _databaseHelper.getOrders(userId);
      _pendingPaymentOrders = await _databaseHelper.getPendingPaymentOrders(userId);
      _pendingShipmentOrders = await _databaseHelper.getPendingShipmentOrders(userId);
      _pendingReceiptOrders = await _databaseHelper.getPendingReceiptOrders(userId);
      _pendingEvaluationOrders = await _databaseHelper.getPendingEvaluationOrders(userId);
      
      // 如果没有数据，初始化为空列表
      _orders = _orders.isNotEmpty ? _orders : [];
      _pendingPaymentOrders = _pendingPaymentOrders.isNotEmpty ? _pendingPaymentOrders : [];
      _pendingShipmentOrders = _pendingShipmentOrders.isNotEmpty ? _pendingShipmentOrders : [];
      _pendingReceiptOrders = _pendingReceiptOrders.isNotEmpty ? _pendingReceiptOrders : [];
      _pendingEvaluationOrders = _pendingEvaluationOrders.isNotEmpty ? _pendingEvaluationOrders : [];
      
      notifyListeners();
    } catch (e) {
      print('Error loading orders: $e');
      // 确保列表不为null
      _orders = [];
      _pendingPaymentOrders = [];
      _pendingShipmentOrders = [];
      _pendingReceiptOrders = [];
      _pendingEvaluationOrders = [];
      notifyListeners();
      // 重新抛出异常，让UI层处理
      rethrow;
    }
  }

  // 创建新订单
  Future<Order> createOrder({
    required int userId,
    required String productName,
    required String productImage,
    required String size,
    required String color,
    required int quantity,
    required double price,
    required double deliveryFee,
    required String address,
    String? orderNumber,
    required String merchantInfo,
    required String purchaseChannel,
    required String paymentMethod,
  }) async {
    // 生成订单号
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final random = Random().nextInt(1000).toString().padLeft(3, '0');
    final generatedOrderNumber = orderNumber ?? 'ORDER$formattedDate$random';
    
    // 计算总价
    final totalPrice = price + deliveryFee;
    
    // 创建订单对象
    final order = Order(
      userId: userId,
      productName: productName,
      productImage: productImage,
      size: size,
      color: color,
      quantity: quantity,
      price: price,
      deliveryFee: deliveryFee,
      totalPrice: totalPrice,
      address: address,
      orderNumber: generatedOrderNumber,
      merchantInfo: merchantInfo,
      purchaseChannel: purchaseChannel,
      createTime: now.toString(),
      paymentMethod: paymentMethod,
      transactionStatus: '支付成功',
      isDelivered: false,
      isEvaluated: false,
    );
    
    // 保存到数据库
    final id = await _databaseHelper.insertOrder(order);
    final newOrder = order.copyWith(id: id);
    
    // 更新订单列表
    _orders.add(newOrder);
    _pendingShipmentOrders.add(newOrder);
    
    notifyListeners();
    
    return newOrder;
  }

  // 更新订单状态
  Future<void> updateOrderStatus(int orderId, String status) async {
    // 查找订单
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return;
    
    // 更新订单状态
    final order = _orders[orderIndex];
    final updatedOrder = order.copyWith(transactionStatus: status);
    
    // 保存到数据库
    await _databaseHelper.updateOrder(updatedOrder);
    
    // 更新内存中的订单
    _orders[orderIndex] = updatedOrder;
    
    // 更新各状态订单列表
    _updateOrderLists();
    
    notifyListeners();
  }

  // 标记订单为已发货
  Future<void> markOrderAsDelivered(int orderId) async {
    // 查找订单
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return;
    
    // 更新订单状态
    final order = _orders[orderIndex];
    final updatedOrder = order.copyWith(isDelivered: true);
    
    // 保存到数据库
    await _databaseHelper.updateOrder(updatedOrder);
    
    // 更新内存中的订单
    _orders[orderIndex] = updatedOrder;
    
    // 更新各状态订单列表
    _updateOrderLists();
    
    notifyListeners();
  }

  // 标记订单为已评价
  Future<void> markOrderAsEvaluated(int orderId) async {
    // 查找订单
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex == -1) return;
    
    // 更新订单状态
    final order = _orders[orderIndex];
    final updatedOrder = order.copyWith(isEvaluated: true);
    
    // 保存到数据库
    await _databaseHelper.updateOrder(updatedOrder);
    
    // 更新内存中的订单
    _orders[orderIndex] = updatedOrder;
    
    // 更新各状态订单列表
    _updateOrderLists();
    
    notifyListeners();
  }

  // 删除订单
  Future<void> deleteOrder(int orderId) async {
    // 从数据库删除
    await _databaseHelper.deleteOrder(orderId);
    
    // 从内存中删除
    _orders.removeWhere((order) => order.id == orderId);
    
    // 更新各状态订单列表
    _updateOrderLists();
    
    notifyListeners();
  }

  // 更新各状态订单列表
  void _updateOrderLists() {
    if (!_authService.isLoggedIn || _authService.currentUser == null) return;
    
    final userId = _authService.currentUser!.id!;
    
    _pendingPaymentOrders = _orders.where((order) => 
      order.userId == userId && 
      order.transactionStatus == '待支付'
    ).toList();
    
    _pendingShipmentOrders = _orders.where((order) => 
      order.userId == userId && 
      order.transactionStatus == '支付成功' && 
      !order.isDelivered
    ).toList();
    
    _pendingReceiptOrders = _orders.where((order) => 
      order.userId == userId && 
      order.transactionStatus == '支付成功' && 
      order.isDelivered && 
      !order.isEvaluated
    ).toList();
    
    _pendingEvaluationOrders = _orders.where((order) => 
      order.userId == userId && 
      order.isDelivered && 
      !order.isEvaluated
    ).toList();
  }
} 