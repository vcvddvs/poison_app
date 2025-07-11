import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../backend/auth_service.dart';
import '../models/cart.dart';
import 'phone_login_page.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back navigation from login screen
      onWillPop: () async => false,
      child: Scaffold(
        // Remove the appBar completely to prevent back navigation
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 80),
              // 用户头像
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/pic/img.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 用户名
              const Text(
                '登录得物APP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // 微信一键登录按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: () {
                    // 微信登录逻辑
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('微信登录功能暂未实现'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07C160),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wechat, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        '微信一键登录',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 手机号登录按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneLoginPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '手机号登录',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 没有账号，去注册
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  '新用户注册',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF26BEB9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              // 其他方式登录
              const Text(
                '其它方式登录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // 社交媒体图标
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.chat),
                  const SizedBox(width: 24),
                  _buildSocialIcon(Icons.wb_sunny),
                  const SizedBox(width: 24),
                  _buildSocialIcon(Icons.notifications),
                ],
              ),
              const SizedBox(height: 20),
              // 底部协议
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      const TextSpan(text: '已阅读并同意 '),
                      _buildPolicyLink('《用户协议》'),
                      const TextSpan(text: '、'),
                      _buildPolicyLink('《隐私政策》'),
                      const TextSpan(text: '、'),
                      _buildPolicyLink('《奖励派送》'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('该登录方式暂未实现'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  TextSpan _buildPolicyLink(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          // 处理协议点击
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$text 暂未实现'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
    );
  }
} 