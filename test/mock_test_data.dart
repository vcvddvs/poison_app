import 'package:poison_app/models/product.dart';
import 'package:poison_app/models/product_variant.dart';
import 'package:poison_app/models/user.dart';
import 'package:poison_app/models/address.dart';
import 'package:poison_app/models/cart_item.dart';
import 'package:poison_app/models/order.dart';

/// 模拟测试数据类
class MockTestData {
  /// 获取模拟用户数据
  static List<User> getMockUsers() {
    return [
      User(
        id: 1,
        username: 'test_user',
        email: 'test@example.com',
        phone: '13800138000',
        avatarUrl: 'https://example.com/avatar1.jpg',
      ),
      User(
        id: 2,
        username: 'john_doe',
        email: 'john@example.com',
        phone: '13900139000',
        avatarUrl: 'https://example.com/avatar2.jpg',
      ),
      User(
        id: 3,
        username: 'jane_smith',
        email: 'jane@example.com',
        phone: '13700137000',
        avatarUrl: 'https://example.com/avatar3.jpg',
      ),
    ];
  }

  /// 获取模拟商品数据
  static List<Product> getMockProducts() {
    return [
      Product(
        id: 1,
        name: 'Air Jordan 4',
        description: '经典复古篮球鞋，采用优质皮革材质，提供出色的支撑和舒适性。',
        brand: 'Nike',
        category: '篮球鞋',
        price: 1299.00,
        imageUrl: 'assets/pic2/aj4/img.png',
      ),
      Product(
        id: 2,
        name: 'Yeezy Boost 350',
        description: '舒适轻盈的跑步鞋，采用Boost中底技术，提供卓越的回弹性能。',
        brand: 'Adidas',
        category: '休闲鞋',
        price: 1899.00,
        imageUrl: 'assets/pic2/others/img.png',
      ),
      Product(
        id: 3,
        name: 'Dunk Low',
        description: '经典低帮滑板鞋，简约设计，适合日常穿着。',
        brand: 'Nike',
        category: '滑板鞋',
        price: 799.00,
        imageUrl: 'assets/pic2/others/img_1.png',
      ),
      Product(
        id: 4,
        name: 'New Balance 990',
        description: '复古跑步鞋，美国制造，提供卓越的舒适性和支撑性。',
        brand: 'New Balance',
        category: '跑步鞋',
        price: 1599.00,
        imageUrl: 'assets/pic2/others/img_2.png',
      ),
      Product(
        id: 5,
        name: 'Converse Chuck Taylor',
        description: '经典帆布鞋，百搭设计，适合各种场合。',
        brand: 'Converse',
        category: '帆布鞋',
        price: 599.00,
        imageUrl: 'assets/pic2/others/img_3.png',
      ),
    ];
  }

  /// 获取模拟商品变体数据
  static List<ProductVariant> getMockProductVariants() {
    return [
      ProductVariant(
        id: 1,
        productId: 1,
        size: '40',
        color: '黑红',
        stock: 10,
      ),
      ProductVariant(
        id: 2,
        productId: 1,
        size: '41',
        color: '黑红',
        stock: 5,
      ),
      ProductVariant(
        id: 3,
        productId: 1,
        size: '42',
        color: '黑红',
        stock: 8,
      ),
      ProductVariant(
        id: 4,
        productId: 2,
        size: '40',
        color: '灰色',
        stock: 15,
      ),
      ProductVariant(
        id: 5,
        productId: 2,
        size: '41',
        color: '灰色',
        stock: 12,
      ),
      ProductVariant(
        id: 6,
        productId: 3,
        size: '42',
        color: '黑白',
        stock: 20,
      ),
    ];
  }

  /// 获取模拟地址数据
  static List<Address> getMockAddresses() {
    return [
      Address(
        id: 1,
        userId: 1,
        name: '张三',
        phone: '13800138000',
        province: '广东省',
        city: '深圳市',
        district: '南山区',
        detail: '科技园南区10栋101室',
      ),
      Address(
        id: 2,
        userId: 1,
        name: '张三',
        phone: '13800138000',
        province: '广东省',
        city: '广州市',
        district: '天河区',
        detail: '天河路385号',
      ),
      Address(
        id: 3,
        userId: 2,
        name: '李四',
        phone: '13900139000',
        province: '北京市',
        city: '北京市',
        district: '朝阳区',
        detail: '朝阳路88号',
      ),
    ];
  }

  /// 获取模拟购物车项数据
  static List<CartItem> getMockCartItems() {
    return [
      CartItem(
        id: 1,
        userId: 1,
        productVariantId: 1,
        quantity: 1,
        productName: 'Air Jordan 4',
        productImage: 'assets/pic2/aj4/img.png',
        price: 1299.00,
        size: '40',
        color: '黑红',
      ),
      CartItem(
        id: 2,
        userId: 1,
        productVariantId: 4,
        quantity: 2,
        productName: 'Yeezy Boost 350',
        productImage: 'assets/pic2/others/img.png',
        price: 1899.00,
        size: '40',
        color: '灰色',
      ),
      CartItem(
        id: 3,
        userId: 2,
        productVariantId: 6,
        quantity: 1,
        productName: 'Dunk Low',
        productImage: 'assets/pic2/others/img_1.png',
        price: 799.00,
        size: '42',
        color: '黑白',
      ),
    ];
  }

  /// 获取模拟订单数据
  static List<Order> getMockOrders() {
    return [
      Order(
        id: 1,
        userId: 1,
        addressId: 1,
        totalAmount: 1299.00,
        status: '待支付',
        paymentMethod: '微信支付',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        items: [
          {
            'product_name': 'Air Jordan 4',
            'product_image': 'assets/pic2/aj4/img.png',
            'size': '40',
            'color': '黑红',
            'price': 1299.00,
            'quantity': 1
          }
        ],
      ),
      Order(
        id: 2,
        userId: 1,
        addressId: 1,
        totalAmount: 3798.00,
        status: '已支付',
        paymentMethod: '支付宝',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        items: [
          {
            'product_name': 'Yeezy Boost 350',
            'product_image': 'assets/pic2/others/img.png',
            'size': '40',
            'color': '灰色',
            'price': 1899.00,
            'quantity': 2
          }
        ],
      ),
      Order(
        id: 3,
        userId: 2,
        addressId: 3,
        totalAmount: 799.00,
        status: '已发货',
        paymentMethod: '微信支付',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        items: [
          {
            'product_name': 'Dunk Low',
            'product_image': 'assets/pic2/others/img_1.png',
            'size': '42',
            'color': '黑白',
            'price': 799.00,
            'quantity': 1
          }
        ],
      ),
    ];
  }
} 