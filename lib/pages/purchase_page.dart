import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/address.dart';
import '../backend/address_provider.dart';
import '../backend/auth_service.dart';
import '../backend/order_provider.dart';
import '../backend/product_provider.dart';
import 'address_management_page.dart';
import 'delivery_service_page.dart';
import 'order_detail_page.dart';
import 'orders_page.dart';

class PurchasePage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String selectedSize;
  final String selectedColor;

  const PurchasePage({
    Key? key, 
    required this.product, 
    required this.selectedSize,
    this.selectedColor = '紫色',
  }) : super(key: key);

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  bool isProtectionSelected = true;
  bool isExpressDelivery = true;
  String deliveryMethod = '顺丰速运';
  String deliveryOption = '送货上门（可打电话）';
  late String selectedColor;

  @override
  void initState() {
    super.initState();
    // 初始化颜色
    selectedColor = widget.selectedColor;
    // 在下一帧加载地址
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("PurchasePage: 加载地址");
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.loadAddresses().then((_) {
        print("PurchasePage: 地址加载完成，共 ${addressProvider.addresses.length} 个地址");
        print("PurchasePage: 选中地址: ${addressProvider.selectedAddress?.fullAddress ?? '无'}");
      });
    });
  }

  void _showAddressSelector() {
    print("PurchasePage: 显示地址选择器");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddressManagementPage(
        isSelecting: true,
      ),
    ).then((_) {
      // 刷新地址数据
      print("PurchasePage: 地址选择完成，刷新地址");
      Provider.of<AddressProvider>(context, listen: false).loadAddresses();
    });
  }

  void _showDeliveryServiceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeliveryServicePage(
        onDeliverySelected: (delivery) {
          setState(() {
            deliveryMethod = delivery.title;
            if (delivery.subtitle != null) {
              deliveryOption = delivery.subtitle!;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final selectedAddress = addressProvider.selectedAddress;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 顶部标题栏和关闭按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('成为思明市第16位拥有者', style: TextStyle(color: Colors.black, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 收货地址信息
                  Consumer<AddressProvider>(
                    builder: (context, addressProvider, child) {
                      final selectedAddress = addressProvider.selectedAddress;
                      if (selectedAddress == null) {
                        return Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text('请选择收货地址', style: TextStyle(fontSize: 16)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _showAddressSelector,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: InkWell(
                          onTap: _showAddressSelector,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('收货', style: TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${selectedAddress.name} ${selectedAddress.phone}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedAddress.fullAddress,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              // 配送服务选择
                              Row(
                                children: [
                                  const Text('限时达运:', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '预计今日23:00前发货, 逾期必赔, 送货上门',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_shipping, color: Colors.blue, size: 16),
                                        const SizedBox(width: 4),
                                        const Text('送礼物', style: TextStyle(color: Colors.blue, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('支付成功分享好友, 检查即刻送达!', 
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const Spacer(),
                                  Radio<bool>(
                                    value: true,
                                    groupValue: isExpressDelivery,
                                    onChanged: (value) {
                                      setState(() {
                                        isExpressDelivery = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFF00C1B3),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 商品信息
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 商品图片
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: _buildProductImage(),
                        ),
                        const SizedBox(width: 12),
                        
                        // 商品详情
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.product['title'] ?? 'LiNing李宁 WOW 1 魔鬼鱼 高帮篮球鞋',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${selectedColor} ${widget.selectedSize} x1', 
                                style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Builder(
                                builder: (context) {
                                  // 获取变体价格
                                  final productProvider = Provider.of<ProductProvider>(context, listen: false);
                                  final productId = widget.product['id'];
                                  String price = widget.product['price'] ?? '¥ 1879';
                                  
                                  if (productId != null) {
                                    final variant = productProvider.getVariant(productId, selectedColor, widget.selectedSize);
                                    if (variant != null && variant.price.isNotEmpty) {
                                      price = variant.price;
                                      print("PurchasePage: 找到商品变体价格: ${variant.price}");
                                    }
                                  }
                                  
                                  return Text(price, 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 配送信息
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('平台保障', style: TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            const Text('正品保障 7天无理由退货 退货包装袋 支付保障', 
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 增值服务
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('增值服务', style: TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            const Text('共4种服务可选', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 服务选项
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        // 第一个服务选项
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('服务洗护 任洗', 
                                  style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 8),
                                const Text('¥ 49', 
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 第二个服务选项
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('除臭洗护 精洗', 
                                  style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 8),
                                const Text('¥ 69', 
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 加购商品
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('加购商品', style: TextStyle(fontSize: 14)),
                        Row(
                          children: [
                            const Text('5件可选择', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 8),
                            // 小图标列表
                            SizedBox(
                              height: 24,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: [
                                  _buildSmallIcon('assets/pic/img_3.png'),
                                  _buildSmallIcon('assets/pic/img_4.png'),
                                  _buildSmallIcon('assets/pic/img_5.png'),
                                  _buildSmallIcon('assets/pic/img_6.png'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 号码保护
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('号码保护', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Icon(Icons.info_outline, color: Colors.grey[400], size: 16),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('隐藏收件人真实手机号, 保护隐私', 
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isProtectionSelected = !isProtectionSelected;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isProtectionSelected ? Colors.cyan : Colors.transparent,
                                  border: Border.all(
                                    color: isProtectionSelected ? Colors.cyan : Colors.grey,
                                  ),
                                ),
                                child: isProtectionSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部支付栏
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('待付款到到卖家的', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Builder(
                      builder: (context) {
                        // 获取变体价格
                        final productProvider = Provider.of<ProductProvider>(context, listen: false);
                        final productId = widget.product['id'];
                        String priceStr = widget.product['price']?.toString().replaceAll('¥', '').trim() ?? '1659';
                        // 移除所有非数字和小数点字符
                        priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
                        double price = double.tryParse(priceStr) ?? 1659;
                        
                        if (productId != null) {
                          final variant = productProvider.getVariant(productId, selectedColor, widget.selectedSize);
                          if (variant != null && variant.price.isNotEmpty) {
                            priceStr = variant.price.replaceAll('¥', '').trim();
                            // 移除所有非数字和小数点字符
                            priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
                            price = double.tryParse(priceStr) ?? price;
                            print("PurchasePage: 底部支付栏使用变体价格: $price");
                          }
                        }
                        
                        // 计算总价（包含配送费）
                        final deliveryFee = isExpressDelivery ? 10.0 : 0.0;
                        final totalPrice = price + deliveryFee;
                        
                        return Row(
                          children: [
                            const Text('¥ ', style: TextStyle(fontSize: 14, color: Colors.red)),
                            Text(
                              totalPrice.toStringAsFixed(1), 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: 140,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // 检查是否可以pop，避免错误
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      
                      // 创建新订单
                      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final productProvider = Provider.of<ProductProvider>(context, listen: false);
                      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                      
                      // 获取正确的价格
                      String priceStr = widget.product['price']?.toString().replaceAll('¥', '').trim() ?? '1659';
                      // 移除所有非数字和小数点字符
                      priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
                      double price = double.tryParse(priceStr) ?? 1659;
                      String productImage = widget.product['localImagePath'] ?? 'assets/pic/jordan_1.png';
                      
                      // 如果有变体，使用变体的价格和图片
                      if (widget.product['id'] != null) {
                        final variant = productProvider.getVariant(
                          widget.product['id'],
                          selectedColor,
                          widget.selectedSize
                        );
                        
                        if (variant != null) {
                          if (variant.price.isNotEmpty) {
                            priceStr = variant.price.replaceAll('¥', '').trim();
                            // 移除所有非数字和小数点字符
                            priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
                            price = double.tryParse(priceStr) ?? price;
                            print("PurchasePage: 订单使用变体价格: $price");
                          }
                          
                          if (variant.localImagePath != null && variant.localImagePath!.isNotEmpty) {
                            productImage = variant.localImagePath!;
                            print("PurchasePage: 订单使用变体图片: $productImage");
                          }
                        }
                      }
                      
                      // 计算总价
                      final deliveryFee = isExpressDelivery ? 10.0 : 0.0;
                      final totalPrice = price + deliveryFee;
                      
                      print("PurchasePage: 商品价格: $price, 配送费: $deliveryFee, 总价: $totalPrice");
                      
                      // 获取当前选择的地址
                      final currentAddress = addressProvider.selectedAddress;
                      final addressText = currentAddress != null 
                          ? '${currentAddress.province}${currentAddress.city}${currentAddress.district} ${currentAddress.detailAddress} ${currentAddress.name} ${currentAddress.phone}'
                          : '未设置地址';
                      
                      // 生成订单号
                      final now = DateTime.now();
                      final orderNumber = 'ORDER${now.millisecondsSinceEpoch}';
                      
                      if (authService.isLoggedIn && authService.currentUser != null) {
                        // 创建订单
                        orderProvider.createOrder(
                          userId: authService.currentUser!.id!,
                          productName: widget.product['title'] ?? 'WOW 1 魔鬼鱼 高帮篮 硬核 减震轻便 高...',
                          productImage: productImage,
                          size: widget.selectedSize,
                          color: selectedColor,
                          quantity: 1,
                          price: price,
                          deliveryFee: deliveryFee,
                          address: addressText,
                          orderNumber: orderNumber,
                          merchantInfo: '毒APP自营',
                          purchaseChannel: '毒APP',
                          paymentMethod: '微信支付',
                        );
                      }
                      
                      // 跳转到订单详情页
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(
                            orderData: {
                              'productName': widget.product['title'] ?? 'WOW 1 魔鬼鱼 高帮篮 硬核 减震轻便 高...',
                              'price': priceStr,
                              'size': widget.selectedSize,
                              'color': selectedColor,
                              'quantity': '1',
                              'productImage': productImage,
                              'address': addressText,
                              'totalPrice': totalPrice,
                              'deliveryFee': deliveryFee,
                              'orderNumber': orderNumber,
                              'merchantInfo': '毒APP自营',
                              'purchaseChannel': '毒APP',
                              'createTime': now.toString(),
                              'paymentMethod': '微信支付',
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C1B3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('立即支付', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductImage() {
    final imagePath = widget.product['localImagePath'] ?? '';
    print("PurchasePage: 尝试加载商品图片: $imagePath, 颜色: $selectedColor, 尺码: ${widget.selectedSize}");
    
    // 尝试获取对应颜色和尺码的图片
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productId = widget.product['id'];
    
    if (productId != null) {
      final variant = productProvider.getVariant(productId, selectedColor, widget.selectedSize);
      if (variant != null && variant.localImagePath != null && variant.localImagePath!.isNotEmpty) {
        print("PurchasePage: 找到商品变体图片: ${variant.localImagePath}");
        
        if (variant.localImagePath!.startsWith('/data/')) {
          return Image.file(
            File(variant.localImagePath!),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("PurchasePage: 加载变体图片出错: $error");
              return _buildFallbackImage();
            },
          );
        } else if (variant.localImagePath!.startsWith('C:\\') || variant.localImagePath!.startsWith('C:/')) {
          final normalizedPath = variant.localImagePath!.replaceAll('\\', '/');
          return Image.file(
            File(normalizedPath),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("PurchasePage: 加载变体图片出错: $error");
              return _buildFallbackImage();
            },
          );
        } else if (variant.localImagePath!.startsWith('assets/')) {
          return Image.asset(
            variant.localImagePath!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("PurchasePage: 加载变体资源图片出错: $error");
              return _buildFallbackImage();
            },
          );
        }
      }
    }
    
    // 如果没有找到变体或变体没有图片，使用默认图片
    if (imagePath.startsWith('/data/')) {
      // 处理Android设备上的本地文件路径
      return Image.file(
        File(imagePath),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("PurchasePage: 加载图片出错: $error");
          return _buildFallbackImage();
        },
      );
    } else if (imagePath.startsWith('C:\\') || imagePath.startsWith('C:/')) {
      // 处理Windows设备上的本地文件路径
      final normalizedPath = imagePath.replaceAll('\\', '/');
      return Image.file(
        File(normalizedPath),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("PurchasePage: 加载图片出错: $error");
          return _buildFallbackImage();
        },
      );
    } else if (imagePath.startsWith('assets/')) {
      // 处理资源文件路径
      return Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("PurchasePage: 加载资源图片出错: $error");
          return _buildFallbackImage();
        },
      );
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }
  
  Widget _buildSmallIcon(String assetPath) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
} 