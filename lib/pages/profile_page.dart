import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/auth_service.dart';
import 'login_page.dart';
import 'orders_page.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部用户信息部分（蓝色背景）
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
              child: Column(
                children: [
                  // 顶部安全区域留白
                  SizedBox(height: 10),
                  
                  // 顶部工具栏
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 客服按钮
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          margin: EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(Icons.headset_mic, color: Colors.white, size: 20),
                            onPressed: () {
                              // 联系客服功能
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('联系客服')),
                              );
                            },
                            constraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        // 设置按钮
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.menu, color: Colors.white, size: 20),
                            onPressed: () {
                              // 设置功能
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('设置')),
                              );
                            },
                            constraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 用户信息部分
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              // 用户名和性别图标
                              Row(
                                children: [
                                  Text(
                                    user?.username ?? 'vcvddv',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.male, color: Colors.cyan, size: 20),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // 用户等级和信誉
                              Row(
                                children: [
                                  // 等级标签
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                    style: TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              Text(
                                '未设置签名',
                                style: TextStyle(color: Colors.black87, fontSize: 14),
                              ),
                              
                              const SizedBox(height: 16),
                              // 数据统计
                              Row(
                                children: [
                                  Text(
                                    '获赞与收藏 147',
                                    style: TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '关注 11',
                                    style: TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '粉丝 2',
                                    style: TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // 箭头
                        Icon(Icons.chevron_right, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 主内容部分（白色背景，可滚动）
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                                      builder: (context) => OrdersPage(initialTab: 0),
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
                              _buildOrderIconWithText(context, Icons.payment, '待付款', 0),
                              _buildOrderIconWithText(context, Icons.inventory, '待发货', 1),
                              _buildOrderIconWithText(context, Icons.local_shipping, '待收货', 2),
                              _buildOrderIconWithText(context, Icons.chat, '评价', 3),
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
                    
                    // 退出登录按钮
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // 退出登录
                            authService.logout();
                            // 返回登录页
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            '退出登录',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
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
  
  Widget _buildIconWithText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget _buildOrderIconWithText(BuildContext context, IconData icon, String text, int tabIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersPage(initialTab: tabIndex),
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
} 