class Order {
  final int? id;
  final int userId;
  final String productName;
  final String productImage;
  final String size;
  final String color;
  final int quantity;
  final double price;
  final double deliveryFee;
  final double totalPrice;
  final String address;
  final String orderNumber;
  final String merchantInfo;
  final String purchaseChannel;
  final String createTime;
  final String paymentMethod;
  final String transactionStatus;
  final bool isDelivered;
  final bool isEvaluated;

  Order({
    this.id,
    required this.userId,
    required this.productName,
    required this.productImage,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    required this.deliveryFee,
    required this.totalPrice,
    required this.address,
    required this.orderNumber,
    required this.merchantInfo,
    required this.purchaseChannel,
    required this.createTime,
    required this.paymentMethod,
    required this.transactionStatus,
    this.isDelivered = false,
    this.isEvaluated = false,
  });

  // 从Map创建Order对象
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['user_id'],
      productName: map['product_name'],
      productImage: map['product_image'],
      size: map['size'],
      color: map['color'],
      quantity: map['quantity'],
      price: double.parse(map['price'].toString()),
      deliveryFee: double.parse(map['delivery_fee'].toString()),
      totalPrice: double.parse(map['total_price'].toString()),
      address: map['address'],
      orderNumber: map['order_number'],
      merchantInfo: map['merchant_info'],
      purchaseChannel: map['purchase_channel'],
      createTime: map['create_time'],
      paymentMethod: map['payment_method'],
      transactionStatus: map['transaction_status'],
      isDelivered: map['is_delivered'] == 1,
      isEvaluated: map['is_evaluated'] == 1,
    );
  }

  // 将Order对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_name': productName,
      'product_image': productImage,
      'size': size,
      'color': color,
      'quantity': quantity,
      'price': price,
      'delivery_fee': deliveryFee,
      'total_price': totalPrice,
      'address': address,
      'order_number': orderNumber,
      'merchant_info': merchantInfo,
      'purchase_channel': purchaseChannel,
      'create_time': createTime,
      'payment_method': paymentMethod,
      'transaction_status': transactionStatus,
      'is_delivered': isDelivered ? 1 : 0,
      'is_evaluated': isEvaluated ? 1 : 0,
    };
  }

  // 复制对象并修改部分属性
  Order copyWith({
    int? id,
    int? userId,
    String? productName,
    String? productImage,
    String? size,
    String? color,
    int? quantity,
    double? price,
    double? deliveryFee,
    double? totalPrice,
    String? address,
    String? orderNumber,
    String? merchantInfo,
    String? purchaseChannel,
    String? createTime,
    String? paymentMethod,
    String? transactionStatus,
    bool? isDelivered,
    bool? isEvaluated,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalPrice: totalPrice ?? this.totalPrice,
      address: address ?? this.address,
      orderNumber: orderNumber ?? this.orderNumber,
      merchantInfo: merchantInfo ?? this.merchantInfo,
      purchaseChannel: purchaseChannel ?? this.purchaseChannel,
      createTime: createTime ?? this.createTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      isDelivered: isDelivered ?? this.isDelivered,
      isEvaluated: isEvaluated ?? this.isEvaluated,
    );
  }
} 