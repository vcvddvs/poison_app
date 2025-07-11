import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'models/cart.dart';
import 'models/product.dart';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/cart_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/search_results_page.dart';
import 'backend/product_provider.dart';
import 'backend/auth_service.dart';
import 'backend/address_provider.dart';
import 'backend/order_provider.dart';
import 'dart:io';
import 'backend/database_helper.dart';
import 'pages/add_address_page.dart';
import 'pages/orders_page.dart';
import 'pages/debug_page.dart';
import 'dart:async';

 void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 隐藏系统状态栏
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, AddressProvider>(
          create: (context) => AddressProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, authService, previous) => 
            previous ?? AddressProvider(authService),
        ),
        ChangeNotifierProxyProvider<AuthService, OrderProvider>(
          create: (context) => OrderProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, authService, previous) => 
            previous ?? OrderProvider(authService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保应用全屏显示
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    return MaterialApp(
      title: '得物',
      debugShowCheckedModeBanner: false, // 移除调试标记
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          return Consumer<AuthService>(
            builder: (ctx, authService, _) {
              return authService.isLoggedIn ? const MainApp() : const LoginPage();
            },
          );
        },
        '/add_address': (context) => const AddAddressPage(),
        '/debug': (context) => const DebugPage(),
      },
    );
  }
}
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 启动时加载商品数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      // 确保应用全屏显示
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('购买页面')),
    const ExplorePage(),
    const MyProfilePage(),
  ];

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 移除AppBar以实现全屏显示
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        height: 35, // 极小的高度
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        notchMargin: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, '得物'),
            _buildNavItem(1, Icons.card_giftcard, '购买'),
            _buildNavItem(2, Icons.public, '探索'),
            _buildNavItem(3, Icons.person, '我'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.black : Colors.black54,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<String> categories = ['推荐', '礼物节', '鞋类', '潮服', '饰品', '少年', '分类'];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchSuggestions = false;
  final List<String> _hotSearchKeywords = [
    'Air Jordan 4',
    'Nike Dunk',
    '李宁篮球鞋',
    'New Balance',
    'Yeezy',
    'AJ1',
    '椰子',
    '匡威',
    '篮球鞋',
    '运动裤'
  ];
  
  // 搜索框提示词轮播
  final List<String> _hintTexts = [
    '篮球鞋 李宁',
    'Nike Dunk 低帮',
    'AJ1 黑红',
    'New Balance 530',
    'Yeezy 350',
    '匡威 帆布鞋'
  ];
  int _currentHintIndex = 0;
  Timer? _hintTextTimer;
  OverlayEntry? _overlayEntry;
  
  @override
  void initState() {
    super.initState();
    // 初始化时从数据库加载商品数据
    Future.microtask(() => 
      Provider.of<ProductProvider>(context, listen: false).fetchProducts()
    );
    
    // 监听焦点变化
    _searchFocusNode.addListener(_onFocusChange);
    
    // 添加文本变化监听器
    _searchController.addListener(_onSearchTextChanged);
    
    // 启动提示词轮播
    _startHintTextRotation();
  }
  
  void _startHintTextRotation() {
    _hintTextTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // 使用淡出淡入动画切换到下一个提示词
          _currentHintIndex = (_currentHintIndex + 1) % _hintTexts.length;
        });
      }
    });
  }
  
  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _showSearchOverlay(context);
    } else {
      _removeSearchOverlay();
    }
  }
  
  // 监听搜索框文本变化
  void _onSearchTextChanged() {
    // 当文本变化时，强制刷新UI以更新提示词显示状态
    setState(() {});
  }
  
  void _showSearchOverlay(BuildContext context) {
    _removeSearchOverlay(); // 先移除已有的overlay
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 透明的全屏层，用于捕获点击事件并关闭悬浮框
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeSearchOverlay();
                _searchFocusNode.unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // 实际的搜索建议悬浮框
          Positioned(
            top: MediaQuery.of(context).padding.top + 90, // 搜索框下方位置
            left: 0,
            right: 0,
            child: GestureDetector(
              // 阻止点击悬浮框内部时关闭悬浮框
              onTap: () {},
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
                        child: Text(
                          '热门搜索',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _hotSearchKeywords.map((keyword) {
                            return InkWell(
                              onTap: () {
                                _searchController.text = keyword;
                                _removeSearchOverlay();
                                _searchFocusNode.unfocus();
                                
                                // 延迟一下再跳转，避免UI更新冲突
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchResultsPage(searchQuery: keyword),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  keyword,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  void _removeSearchOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _removeSearchOverlay();
    _hintTextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 搜索栏 - 使用和图二一样的渐变色背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5DEAEA), // 顶部浅青色
                  Color(0xFFA5F8F8), // 底部更浅的青色
                ],
              ),
            ),
            padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        // 搜索框和提示词
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // 仅当搜索框为空时显示提示词
                              if (_searchController.text.isEmpty)
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 0.1),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                          )),
                                          child: child,
                                        ),
                                      );
                                    },
                                    layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                                      return Stack(
                                        alignment: Alignment.centerLeft,
                                        children: <Widget>[
                                          ...previousChildren,
                                          if (currentChild != null) currentChild,
                                        ],
                                      );
                                    },
                                    child: Text(
                                      _hintTexts[_currentHintIndex],
                                      key: ValueKey<int>(_currentHintIndex),
                                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              
                              // 输入框 - 使用透明背景
                              TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  hintText: "",
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: TextStyle(fontSize: 14),
                                onTap: () {
                                  if (!_searchFocusNode.hasFocus) {
                                    _searchFocusNode.requestFocus();
                                  }
                                },
                                onChanged: (value) {
                                  // 文本变化时强制更新UI
                                  setState(() {});
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _removeSearchOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchResultsPage(searchQuery: value),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.photo_camera_outlined, color: Colors.grey, size: 20),
                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text('搜索', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // 分类标签栏 - 与图二完全一致
          Container(
            color: Colors.white,
            height: 40,
            child: Row(
              children: [
                // 可滑动TabBar
                Expanded(
                  child: DefaultTabController(
                    length: categories.length,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                      indicatorColor: Colors.black,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      padding: EdgeInsets.zero,
                      tabs: categories.map((category) => Tab(text: category)).toList(),
                    ),
                  ),
                ),
                // 固定的"三 分类"按钮
                Container(
                  width: 60,
                  height: double.infinity,
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 三横线图标
                        Icon(Icons.menu, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text('分类', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 横向功能区
                  Container(
                    height: 90,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem('assets/pic/img.png', '品牌专区', true),
                        _buildFeatureItem('assets/pic/img_1.png', '疯狂折扣', false),
                        _buildFeatureItem('assets/pic/img_2.png', '每日签到', false),
                        _buildFeatureItem('assets/pic/img_3.png', '天天领券', false),
                        _buildFeatureItem('assets/pic/img_4.png', '免费领好礼', false),
                      ],
                    ),
                  ),
                  
                  // 礼物节活动卡片
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/pic/img_5.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 空占位
                          SizedBox(height: 12),
                          // 礼物卡片行
                          Row(
                            children: [
                              // 空占位
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 先鉴别后发货的开创者横幅
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '先鉴别后发货的开创者',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                          ),
                        ),
                        const Icon(Icons.verified_user, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text('保障正品，得物攻克国家级鉴别难题', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  
                  // 商品流区域 - 使用ProductProvider加载数据
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        if (productProvider.isLoading) {
                          return Container(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final products = productProvider.products;
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.85, // 调整比例以匹配参考图片
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _buildProductCard(product);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String iconUrl, String label, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              iconUrl,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image: $iconUrl, Error: $error");
                return Icon(Icons.image, color: Colors.grey);
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.black : Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (selected)
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: {
                'id': product.id,
                'img': product.imageUrl,
                'title': product.title,
                'price': product.price,
                'brand': product.brand ?? '',
                'desc': product.tag ?? '',
                'sub': product.subInfo ?? '',
                'localImagePath': product.localImagePath,
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: _buildProductImage(product),
              ),
            ),
            // 商品信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品标签 (如 "礼物节")
                    if (product.tag != null && product.tag!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                border: Border.all(color: Colors.red[100]!),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                product.tag!.contains('|') 
                                    ? product.tag!.split('|')[0].trim()
                                    : product.tag!,
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            if (product.tag!.contains('|'))
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    product.tag!.split('|')[1].trim(),
                                    style: TextStyle(
                                      fontSize: 10, 
                                      color: Colors.red,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    // 商品标题 - 限制为一行
                    Text(
                      product.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 价格和付款人数
                    Row(
                      children: [
                        Text(
                          product.getFormattedPrice(),
                          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (product.paymentCount != null && product.paymentCount! > 0)
                          Text(
                            _formatPaymentCount(product.paymentCount!),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 格式化付款人数
  String _formatPaymentCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万+人付款';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}千+人付款';
    } else {
      return '$count人付款';
    }
  }

  Widget _buildProductImage(Product product) {
    final imagePath = product.localImagePath ?? product.imageUrl;
    
    // 检查路径是否为空
    if (imagePath == null || imagePath.isEmpty) {
      return _buildFallbackImage();
    }
    
    try {
      if (imagePath.startsWith('/data/')) {
        // 处理Android设备上的本地文件路径
        final file = File(imagePath);
        
        return Image.file(
          file,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      } else if (imagePath.startsWith('assets/')) {
        // 处理资源文件路径
        return Image.asset(
          imagePath,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      } else if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // 处理网络图片
        return Image.network(
          imagePath,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        );
      }
      
      // 如果路径格式不匹配任何已知类型，显示备用图片
      return _buildFallbackImage();
    } catch (e) {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }
}

// SliverPersistentHeader委托类
class _SliverBoxDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _SliverBoxDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 探索标题
                const Text(
                  '探索',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 消息中心
                _buildExploreCard(
                  title: '消息中心',
                  subtitle: '有人向你求助: 显腿长吗',
                  icon: null,
                ),
                
                const SizedBox(height: 12),
                
                // 鉴别服务
                _buildExploreCard(
                  title: '鉴别服务',
                  subtitle: '专业鉴别 | 帮你辨真假 购物有保障',
                  icon: Icons.verified_user,
                ),
                
                const SizedBox(height: 12),
                
                // 玩一玩
                _buildExploreCard(
                  title: '玩一玩',
                  subtitle: '免费好礼 | 免费领好礼',
                  icon: Icons.card_giftcard,
                  iconColor: Colors.red,
                ),
                
                const SizedBox(height: 12),
                
                // 买卖闲置
                _buildExploreCard(
                  title: '买卖闲置',
                  subtitle: '逐件查询 | MCM手提包低至1640元',
                  icon: Icons.shopping_bag,
                  iconColor: Colors.brown,
                ),
                
                const SizedBox(height: 12),
                
                // 得有钱·借钱
                _buildExploreCard(
                  title: '得有钱·借钱',
                  subtitle: '最高20万 | 最快30秒到账',
                  icon: Icons.monetization_on,
                  iconColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildExploreCard({
    required String title, 
    required String subtitle, 
    IconData? icon,
    Color iconColor = Colors.teal,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 深蓝色背景
          Container(
            height: 240,
            color: const Color(0xFF0A3544),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部用户信息
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // 用户头像
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            image: DecorationImage(
                              image: AssetImage('assets/pic/img.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // 用户信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'vcvddv',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.male, color: Colors.cyan, size: 20),
                                  
                                  // 等级标签
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.diamond, color: Colors.cyan, size: 14),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Lv3',
                                          style: TextStyle(color: Colors.cyan, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 8),
                                  Text(
                                    '信誉**',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                               Text(
                                '未设置签名',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '获赞与收藏 147',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '关注 11',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '粉丝 2',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // 箭头
                        Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 创作中心
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '创作中心',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right),
                        Spacer(),
                        
                        _buildIconWithText(Icons.insert_chart, '数据'),
                        const SizedBox(width: 24),
                        _buildIconWithText(Icons.monetization_on, '收益'),
                        const SizedBox(width: 24),
                        _buildIconWithText(Icons.flag, '活动'),
                        const SizedBox(width: 24),
                        _buildIconWithText(Icons.card_giftcard, '免单'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 订单
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '订单',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderPage(initialTab: 0),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '全部',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOrderIconWithText(context, Icons.payment, '待付款', 1),
                            _buildOrderIconWithText(context, Icons.inventory, '待发货', 2),
                            _buildOrderIconWithText(context, Icons.local_shipping, '待收货', 3),
                            _buildOrderIconWithText(context, Icons.chat, '评价', 4),
                            _buildIconWithText(Icons.monetization_on, '退款/售后'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 想要/我有
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('想要', '16', Icons.favorite_border),
                      ),
                      Expanded(
                        child: _buildStatCard('我有', '10', Icons.check_circle_outline),
                      ),
                    ],
                  ),
                  
                  // 足迹/关注品牌
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('足迹', '1483', Icons.history),
                      ),
                      Expanded(
                        child: _buildStatCard('关注品牌', '2', Icons.add_box_outlined),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 钱包
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '钱包',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '随心省·127元券包',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildValueWithLabel('0', '优惠券'),
                            _buildValueWithLabel('¥28', '余额'),
                            _buildValueWithLabel('¥20万', '借钱'),
                            _buildValueWithLabel('¥5万', '分期'),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.cyan,
                                child: Icon(Icons.money, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '随心省',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '|',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '领 127 元通用券',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '立即领取',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 出售
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '出售',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '切换商家版',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Text(
                                  '1个限时奖励任务进行中',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '非最低价',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '订单待发货',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '申请闪电直发',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '寄到平台卖，收益高成交快',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 右上角按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.2),
                  child: Icon(Icons.headset_mic, color: Colors.white),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.2),
                  child: Icon(Icons.menu, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderIconWithText(BuildContext context, IconData icon, String text, int tabIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderPage(initialTab: tabIndex),
          ),
        );
      },
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildIconWithText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16)),
            ],
          ),
          Spacer(),
            Text(
            count,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
  
  Widget _buildValueWithLabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class OrderPage extends StatefulWidget {
  final int initialTab;
  
  const OrderPage({super.key, required this.initialTab});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5, 
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return OrdersPage(initialTab: widget.initialTab);
  }
}



