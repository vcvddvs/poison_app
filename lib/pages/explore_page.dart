import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 添加顶部空间，避开摄像头
          SizedBox(height: 30),
          
          // 主要内容区域
          Expanded(
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
        ],
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