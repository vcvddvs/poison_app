import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../backend/auth_service.dart';
import '../models/cart.dart';
import 'home_page.dart';
import 'register_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // 去除手机号中的空格
    String phone = _phoneController.text.replaceAll(' ', '');
    String password = _passwordController.text;

    print("尝试登录: 手机号=$phone, 密码长度=${password.length}");

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号和密码'))
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    
    // 调用登录方法
    final success = await authService.login(phone, password);
    
    print("登录结果: $success, 错误信息: ${authService.errorMessage}");
    
    if (success && mounted) {
      // 登录成功，跳转到首页
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (ctx) => Cart(),
            child: const HomePage(),
          ),
        ),
        (route) => false,
      );
    } else if (mounted) {
      // 登录失败，显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authService.errorMessage ?? '登录失败，请稍后再试'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '密码登录',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // 手机号输入区域
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    '+86',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('·', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '请输入手机号',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 密码输入区域
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '请输入密码',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 登录按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authService.isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26BEB9),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: authService.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            // 验证码登录和忘记密码选项
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: 实现验证码登录
                  },
                  child: const Text(
                    '验证码登录',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF26BEB9),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 实现忘记密码
                  },
                  child: const Text(
                    '忘记密码？',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            // 没有账号，去注册
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(text: '没有账号？'),
                    TextSpan(
                      text: ' 立即注册',
                      style: const TextStyle(color: Color(0xFF26BEB9)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // 底部协议
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  children: [
                    const TextSpan(text: '登录即代表您已同意 '),
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
    );
  }

  TextSpan _buildPolicyLink(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          // 处理协议点击
        },
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.black,
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
} 