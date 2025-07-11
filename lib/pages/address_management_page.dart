import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../backend/address_provider.dart';
import '../backend/auth_service.dart';
import 'add_address_page.dart';
import 'login_page.dart';
import 'delivery_service_page.dart';

class AddressManagementPage extends StatefulWidget {
  final bool isSelecting;
  final Function(Address)? onAddressSelected;

  const AddressManagementPage({
    Key? key,
    this.isSelecting = true,
    this.onAddressSelected,
  }) : super(key: key);

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 加载地址数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("AddressManagementPage: 正在加载地址数据");
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.loadAddresses().then((_) {
        print("AddressManagementPage: 地址数据加载完成，共 ${addressProvider.addresses.length} 个地址");
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    
    // 如果用户未登录，显示登录提示
    if (currentUser == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '请先登录',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('请先登录后再管理地址'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C1B3),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text('去登录'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 顶部标题和关闭按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: '收货地址'),
                      Tab(text: '配送服务'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddressTab(),
                DeliveryServicePage(onDeliverySelected: (delivery) {
                  // 处理配送选择
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          
          // 底部添加地址按钮 (仅在地址Tab显示)
          Builder(
            builder: (context) {
              if (_tabController.index == 0) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddAddressPage()),
                      ).then((_) {
                        // 返回后刷新地址列表
                        Provider.of<AddressProvider>(context, listen: false).loadAddresses();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C1B3),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('添加新地址', style: TextStyle(fontSize: 16)),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        final addresses = addressProvider.addresses;
        print("AddressManagementPage: 渲染地址列表，共 ${addresses.length} 个地址");
        
        if (addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '暂无地址',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // 送货提示
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.blue[300]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('送礼物，支付成功分享好友，检查即刻送达！', 
                      style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // 地址列表
            Expanded(
              child: ListView.separated(
                itemCount: addresses.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isSelected = addressProvider.selectedAddress?.id == address.id;
                  
                  print("AddressManagementPage: 渲染地址 $index - ID: ${address.id}, 姓名: ${address.name}");
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? const Color(0xFF00C1B3) : Colors.grey,
                        size: 24,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          address.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          address.phone,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (address.isDefault)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C1B3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                '默认',
                                style: TextStyle(fontSize: 10, color: Color(0xFF00C1B3)),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              address.fullAddress,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 删除按钮
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('删除地址'),
                                content: const Text('确定要删除这个地址吗？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      await addressProvider.deleteAddress(address.id!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('地址已删除')),
                                      );
                                    },
                                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      print("AddressManagementPage: 选择地址 - ID: ${address.id}, 姓名: ${address.name}");
                      
                      // 如果不是默认地址，设为默认
                      if (!address.isDefault) {
                        await addressProvider.setDefaultAddress(address.id!);
                      }
                      
                      // 选择地址
                      addressProvider.selectAddress(address);
                      
                      // 刷新地址列表
                      await addressProvider.loadAddresses();
                      
                      if (widget.onAddressSelected != null) {
                        widget.onAddressSelected!(address);
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 