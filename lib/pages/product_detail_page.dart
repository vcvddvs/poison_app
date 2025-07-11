import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../models/cart.dart';
import '../models/product.dart';
import '../utils/image_helper.dart';
import 'cart_page.dart';
import 'purchase_page.dart';
import 'shoe_model_viewer.dart';
import '../backend/product_provider.dart';
import '../backend/database_helper.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedImageIndex = 0;
  final List<String> _imageList = [
    'assets/pic/img_1.png',
    'assets/pic/img_2.png',
    'assets/pic/img_3.png',
    'assets/pic/img_4.png',
    'assets/pic/img_5.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeBrandInfo();
  }

  Future<void> _initializeBrandInfo() async {
    if (widget.product['id'] != null) {
      final dbHelper = DatabaseHelper();
      await dbHelper.addBrandSpecification(
        widget.product['id'],
        '李宁',
        '/data/data/com.example.poison_app/app_flutter/product_images/pic2/mgy_ln/img_5.png'
      );
    }
  }

  // 模拟最近购买数据
  final List<Map<String, dynamic>> _recentBuyers = [
    {'name': '熊*', '尺码': '白色 42.5', '价格': '¥1519', '时间': '2小时前'},
    {'name': '白夜', '尺码': '白色 42.5', '价格': '¥1539', '时间': '7小时前'},
  ];

  bool _isFavorite = false;
  String _selectedSize = '';
  String _selectedColor = '';

  // Add to Cart dialog
  void _showAddToCartDialog() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productId = widget.product['id'];
    
    if (productId == null || _selectedColor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择颜色')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final variants = productProvider.getVariantsForProduct(productId)
              .where((v) => v.color == _selectedColor)
              .toList();

          return Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品信息头部
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品图片
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: _selectedColor.isNotEmpty
                            ? Builder(
                                builder: (context) {
                                  final variant = productProvider.getVariant(
                                    productId,
                                    _selectedColor,
                                    _selectedSize,
                                  );
                                  return _buildProductImage(variant?.localImagePath ?? '');
                                },
                              )
                            : _buildProductImage(widget.product['localImagePath'] ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 价格和已选信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedSize.isNotEmpty)
                            Builder(
                              builder: (context) {
                                final variant = productProvider.getVariant(
                                  productId,
                                  _selectedColor,
                                  _selectedSize,
                                );
                                return Text(
                                  variant?.price ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '已选: $_selectedColor $_selectedSize',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // 关闭按钮
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 尺码选择
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '尺码',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '93%的人更喜欢这个尺码，可根据您的脚型适当调整。',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: variants.length,
                    itemBuilder: (context, index) {
                      final variant = variants[index];
                      bool isSelected = _selectedSize == variant.size;
                      bool hasStock = variant.stock > 0;
                      
                      return GestureDetector(
                        onTap: hasStock ? () {
                          setState(() {
                            _selectedSize = variant.size;
                          });
                        } : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black.withOpacity(0.05) : 
                                  !hasStock ? Colors.grey[100] : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                variant.size,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : 
                                        !hasStock ? Colors.grey : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              Text(
                                hasStock ? variant.price : '无货',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: !hasStock ? Colors.grey : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 底部按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedSize.isNotEmpty ? () {
                          // 处理立即购买逻辑
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => PurchasePage(
                              product: widget.product,
                              selectedSize: _selectedSize,
                              selectedColor: _selectedColor,
                            ),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '立即购买',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建商品图片
  Widget _buildProductImage(String imagePath) {
    print("ProductDetailPage: 尝试加载图片: $imagePath");
    
    if (imagePath.startsWith('/data/')) {
      // 处理Android设备上的本地文件路径
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("ProductDetailPage: 加载图片出错: $error");
          print("ProductDetailPage: 堆栈跟踪: $stackTrace");
          return _buildFallbackImage();
        },
      );
    } else if (imagePath.startsWith('C:\\') || imagePath.startsWith('C:/')) {
      // 处理Windows设备上的本地文件路径
      final normalizedPath = imagePath.replaceAll('\\', '/');
      return Image.file(
        File(normalizedPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("ProductDetailPage: 加载图片出错: $error");
          return _buildFallbackImage();
        },
      );
    } else if (imagePath.startsWith('assets/')) {
      // 处理资源文件路径
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("ProductDetailPage: 加载资源图片出错: $error");
          return _buildFallbackImage();
        },
      );
    } else if (imagePath.isEmpty) {
      return _buildFallbackImage();
    }
    
    // 如果路径格式不匹配任何已知类型，显示备用图片
    print("ProductDetailPage: 未知的图片路径格式: $imagePath");
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey, size: 40),
    );
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/pic/img.png',
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.qr_code_scanner, color: Colors.black),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.wechat, color: Colors.green),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主图区域
                  _buildMainImageSection(),
                  
                  // 价格区域
                  _buildPriceSection(),
                  
                  // 商品信息区域
                  _buildProductInfoSection(),
                  
                  // 信息选项卡区域
                  _buildInfoTabsSection(),
                  
                  // 最近购买区域
                  _buildRecentPurchasesSection(),
                  
                  const SizedBox(height: 80), // 底部留白，避免被底部按钮遮挡
                ],
              ),
            ),
          ),
          
          // 底部操作栏
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  // 构建主图区域
  Widget _buildMainImageSection() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productId = widget.product['id'];
    final variant = _selectedColor.isNotEmpty && productId != null
        ? productProvider.getVariant(productId, _selectedColor, _selectedSize)
        : null;
    
    return Column(
      children: [
        // 主图
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[100],
              child: variant?.localImagePath != null
                  ? _buildProductImage(variant!.localImagePath!)
                  : _buildProductImage(widget.product['localImagePath'] ?? ''),
            ),
          ],
        ),
        // 颜色选择栏
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: productId != null
                ? productProvider.getColorsForProduct(productId).map((color) {
                    final colorVariant = productProvider.getVariant(productId, color, '');
                    bool isSelected = _selectedColor == color;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                          _selectedSize = ''; // 重置尺码选择
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: colorVariant?.localImagePath != null
                              ? _buildProductImage(colorVariant!.localImagePath!)
                              : _buildFallbackImage(),
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        ),
      ],
    );
  }

  // 价格区域
  Widget _buildPriceSection() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productId = widget.product['id'];
    
    // 获取正确的价格
    String priceDisplay = widget.product['price'] ?? '¥1548';
    
    // 如果有选择颜色和尺码，获取对应变体的价格
    if (productId != null && _selectedColor.isNotEmpty && _selectedSize.isNotEmpty) {
      final variant = productProvider.getVariant(productId, _selectedColor, _selectedSize);
      if (variant != null && variant.price.isNotEmpty) {
        priceDisplay = variant.price;
        print("ProductDetailPage: 使用变体价格: ${variant.price}");
      }
    }
    
    // 确保价格格式一致
    if (!priceDisplay.contains('¥')) {
      priceDisplay = '¥$priceDisplay';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '潮品1/4',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '已售',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 发售日期
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                TextSpan(text: '抢先发售 '),
                TextSpan(
                  text: '2023年4月23日',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 价格
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  priceDisplay,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '参考价',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.red, size: 14),
                    SizedBox(width: 2),
                    Text(
                      '库存紧张',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 商品信息区域
  // 显示3D模型查看器
  void _show3DModelViewer() {
    print("准备打开3D模型查看器");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoeModelViewer(
          title: widget.product['title'] ?? '3D模型预览',
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品名称
          Text(
            widget.product['title'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 评分和查看详情按钮
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              const Text(
                '9.1',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '(774)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              // 3D模型查看按钮
              TextButton.icon(
                onPressed: _show3DModelViewer,
                icon: const Icon(Icons.view_in_ar, color: Colors.blue),
                label: const Text(
                  '3D查看',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showProductEncyclopedia();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    const Text(
                      '查看详情',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductEncyclopedia() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productId = widget.product['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // 顶部标题栏
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 24,
                                height: 24,
                                color: Colors.black,
                                child: const Center(
                                  child: Text(
                                    '得物',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '商品百科',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // 内容区域
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // 品牌信息
                        if (productId != null)
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: productProvider.getProductSpecifications(productId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              
                              final specs = snapshot.data!;
                              print("All Specs before brand info: $specs");
                              
                              // 查找品牌信息
                              final brandInfo = specs.firstWhere(
                                (spec) => spec['spec_type'] == '品牌信息',
                                orElse: () => {
                                  'spec_type': '品牌信息',
                                  'spec_value': '李宁',
                                  'brand_path': '/data/data/com.example.poison_app/app_flutter/product_images/pic2/mgy_ln/img_5.png'
                                },
                              );
                              
                              print("Brand Info found: $brandInfo");
                              print("All Specs: $specs"); // 添加调试信息查看所有规格数据
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '品牌信息',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      if (brandInfo['brand_path'] != null && brandInfo['brand_path'].toString().isNotEmpty)
                                        Builder(
                                          builder: (context) {
                                            final brandPath = brandInfo['brand_path'].toString();
                                            print("ProductDetailPage: 尝试加载品牌图片: $brandPath");
                                            
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: Image.file(
                                                File(brandPath),
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  print("ProductDetailPage: 加载品牌图片出错: $error");
                                                  print("ProductDetailPage: 品牌图片路径: $brandPath");
                                                  print("ProductDetailPage: 堆栈跟踪: $stackTrace");
                                                  return Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        brandInfo['spec_value']?.substring(0, 1) ?? '李',
                                                        style: const TextStyle(
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              brandInfo['spec_value']?.substring(0, 1) ?? '李',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  brandInfo['spec_value'] ?? '未知',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.verified, size: 12, color: Colors.blue),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        '官方认证',
                                                        style: TextStyle(fontSize: 10, color: Colors.blue),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              '10万+粉丝 · 481万人关注 · 专业运动品牌',
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          minimumSize: Size.zero,
                                        ),
                                        child: const Text('+ 关注'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                        // 细节科技
                        if (productId != null)
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: productProvider.getProductSpecifications(productId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              
                              final specs = snapshot.data!;
                              final techSpecs = specs.where((spec) => 
                                ['核心功能', '中底科技', '鞋面科技'].contains(spec['spec_type'])).toList();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '系列科技',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...techSpecs.map((spec) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            spec['spec_type'] ?? '',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(spec['spec_value'] ?? ''),
                                        ),
                                        if (spec['spec_type'] != '核心功能')
                                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                        // 更多参数
                        if (productId != null)
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: productProvider.getProductSpecifications(productId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              
                              final specs = snapshot.data!;
                              final moreSpecs = specs.where((spec) => 
                                ['鞋面材质', '鞋底材质', '功能性', '货号', '鞋帮高度'].contains(spec['spec_type'])).toList();
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '更多参数',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...moreSpecs.map((spec) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            spec['spec_type'] ?? '',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(spec['spec_value'] ?? ''),
                                        ),
                                        if (spec['spec_type'] != '货号' && spec['spec_type'] != '鞋帮高度')
                                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBrandAvatar(String? brandName) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[200],
      child: Text(
        brandName?.substring(0, 1) ?? '未知',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  // 信息选项卡区域
  Widget _buildInfoTabsSection() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productId = widget.product['id'];
    
    // 获取所有可用的颜色和尺码
    final List<String> availableColors = productId != null 
        ? productProvider.getColorsForProduct(productId)
        : [];
    final List<String> availableSizes = (productId != null && _selectedColor.isNotEmpty)
        ? productProvider.getSizesForProductAndColor(productId, _selectedColor)
        : [];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(Icons.verified_user, '正品鉴别', '7天无理由退货'),
              ),
              Container(
                height: 24,
                width: 1,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildInfoItem(Icons.local_shipping, '如约送达', '未按时送达 超时补退'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 选择区域
          GestureDetector(
            onTap: _showAddToCartDialog,
            child: Column(
              children: [
                _buildSelectionRow('颜色', availableColors.join('/')),
                _buildSelectionRow('尺码', availableSizes.join('/')),
                _buildSelectionRow('重量', '暂无'),
                _buildSelectionRow('系列', widget.product['brand'] ?? '系列'),
                _buildSelectionRow('颜色分类', availableColors.join('、')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 信息项
  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // 选择行
  Widget _buildSelectionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  // 最近购买区域
  Widget _buildRecentPurchasesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '最近购买(1000+)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    const Text(
                      '全部',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 购买记录列表
          Column(
            children: _recentBuyers.map((buyer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // 用户头像
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey, size: 20),
                    ),
                    const SizedBox(width: 12),
                    // 用户信息
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          buyer['尺码'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 价格和时间
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          buyer['价格'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          buyer['时间'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 喜欢按钮
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              const Text(
                '想要',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // 评论按钮
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined, color: Colors.grey),
                onPressed: () {},
              ),
              const Text(
                '评论',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // 推送按钮
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.grey),
                onPressed: () {},
              ),
              const Text(
                '提价',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // 还价按钮
          ElevatedButton(
            onPressed: () {
              _showCounterOfferDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const Text(
              '还价',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 立即购买按钮
          ElevatedButton(
            onPressed: () {
              if (_selectedSize.isEmpty) {
                _showAddToCartDialog();
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => PurchasePage(
                    product: widget.product,
                    selectedSize: _selectedSize,
                    selectedColor: _selectedColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              '立即购买',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 显示还价对话框
  void _showCounterOfferDialog() {
    final TextEditingController _offerController = TextEditingController();
    String originalPrice = widget.product['price'] ?? '';
    if (!originalPrice.contains('¥')) {
      originalPrice = '¥$originalPrice';
    }
    
    // 提取价格数字部分
    final numericPrice = originalPrice.replaceAll(RegExp(r'[^\d.]'), '');
    final originalPriceValue = double.tryParse(numericPrice) ?? 0.0;
    
    // 默认还价为原价的90%
    final suggestedOffer = (originalPriceValue * 0.9).round();
    _offerController.text = suggestedOffer.toString();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '向卖家出价',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '原价: $originalPrice',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _offerController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '输入您的出价',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 处理还价逻辑
                final offerPrice = _offerController.text;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已向卖家出价: ¥$offerPrice'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                '确认出价',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 