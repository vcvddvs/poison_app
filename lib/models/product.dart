import 'dart:typed_data';

class Product {
  final int? id;
  final String imageUrl;
  final String title;
  final String price;
  final String? brand;
  final String? tag;
  final String? subInfo;
  final int? paymentCount;
  final bool isLowestPrice;
  final String? localImagePath;

  Product({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.brand,
    this.tag,
    this.subInfo,
    this.paymentCount,
    this.isLowestPrice = false,
    this.localImagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    imageUrl: json['imageUrl'] ?? '',
    title: json['title'] ?? '',
    price: json['price'] ?? '',
    brand: json['brand'],
    tag: json['tag'],
    subInfo: json['subInfo'],
    paymentCount: json['paymentCount'],
    isLowestPrice: json['isLowestPrice'] ?? false,
    localImagePath: json['localImagePath'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'title': title,
    'price': price,
    'brand': brand,
    'tag': tag,
    'subInfo': subInfo,
    'paymentCount': paymentCount,
    'isLowestPrice': isLowestPrice,
    'localImagePath': localImagePath,
  };

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      brand: map['brand'],
      tag: map['tag'],
      subInfo: map['subInfo'],
      paymentCount: map['payment_count'],
      localImagePath: map['localImagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'price': price,
      'brand': brand,
      'tag': tag,
      'subInfo': subInfo,
      'payment_count': paymentCount,
      'localImagePath': localImagePath,
    };
  }

  // 格式化价格，确保价格格式一致
  String getFormattedPrice() {
    if (price.isEmpty) {
      return '¥0';
    }
    
    // 如果价格不包含¥符号，添加它
    if (!price.contains('¥')) {
      return '¥$price';
    }
    
    return price;
  }
  
  // 获取价格的数值部分
  double getPriceValue() {
    if (price.isEmpty) {
      return 0.0;
    }
    
    // 移除所有非数字和小数点字符
    String numericString = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  static List<Product> getSampleProducts() {
    return [
      Product(
        id: 1,
        imageUrl: 'https://img.poizon.com/prod1.png',
        title: 'Anta安踏 狂潮7 A-SHOCK',
        price: '¥1299',
        tag: 'NEW 新品发售 今日+7款高热',
      ),
      Product(
        id: 2,
        imageUrl: 'https://img.poizon.com/iphone16.png',
        title: 'iPhone 16 Pro 支持移动',
        price: '¥6109',
        brand: 'Apple',
        subInfo: '6万+人付款',
        paymentCount: 60000,
      ),
      Product(
        id: 3,
        imageUrl: 'https://img.poizon.com/prod2.png',
        title: 'Jordan Air Jordan 3 retr',
        price: '¥1299',
        tag: '礼物节 | 领券再省45元',
        subInfo: '1.9万+人付款',
        paymentCount: 19000,
      ),
      Product(
        id: 4,
        imageUrl: 'https://img.poizon.com/prod3.png',
        title: 'New Balance',
        brand: 'New Balance',
        price: '', 
        subInfo: '167万+人关注',
      ),
      Product(
        id: 5,
        imageUrl: 'https://img.poizon.com/prod5.png',
        title: 'Jordan Air Jordan 3 舒适',
        price: '¥509',
        tag: '全网低价',
        subInfo: '62人付款',
        paymentCount: 62,
        isLowestPrice: true,
      ),
    ];
  }
} 