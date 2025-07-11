import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/product_provider.dart';
import '../models/product.dart';
import 'product_detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _searchResults = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _performSearch();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final results = await productProvider.searchProducts(widget.searchQuery);
    
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.searchQuery, style: TextStyle(color: Colors.black, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // 返回到搜索页面
              Navigator.pop(context);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: '综合'),
                  Tab(text: '销量'),
                  Tab(text: '价格'),
                ],
              ),
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? _buildEmptyResults()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductGrid(_searchResults),
                    _buildProductGrid(_searchResults), // 这里可以根据销量排序
                    _buildProductGrid(_searchResults), // 这里可以根据价格排序
                  ],
                ),
    );
  }
  
  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '没有找到相关商品',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
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
              child: _buildProductImage(product),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.tag != null && product.tag!.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          product.tag!,
                          style: const TextStyle(fontSize: 12, color: Colors.cyan, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        if (product.tag!.contains('NEW'))
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
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  if (product.subInfo != null && product.subInfo!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        product.subInfo!,
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