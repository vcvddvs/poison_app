import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../backend/address_provider.dart';
import '../backend/auth_service.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _detailAddressController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    
    // 如果用户未登录，显示提示
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('添加新地址', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('请先登录后再添加地址'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('添加新地址', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 收货人
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '收货人',
                hintText: '请输入收货人姓名',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              enableSuggestions: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入收货人姓名';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 手机号
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '手机号',
                hintText: '请输入收货人手机号',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入收货人手机号';
                }
                // 简单的手机号验证
                if (value.length < 11) {
                  return '请输入有效的手机号';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 省份
            TextFormField(
              controller: _provinceController,
              decoration: const InputDecoration(
                labelText: '省份',
                hintText: '请输入省份',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入省份';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 城市
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: '城市',
                hintText: '请输入城市',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入城市';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 区/县
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: '区/县',
                hintText: '请输入区/县',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入区/县';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 详细地址
            TextFormField(
              controller: _detailAddressController,
              decoration: const InputDecoration(
                labelText: '详细地址',
                hintText: '请输入详细地址',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: 3,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              enableSuggestions: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入详细地址';
                }
                if (value.length < 5) {
                  return '地址太短，请输入更详细的地址';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 设为默认地址
            CheckboxListTile(
              title: const Text('设为默认地址'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF00C1B3),
            ),
            
            const SizedBox(height: 32),
            
            // 保存按钮
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    print("AddAddressPage: 准备添加地址，用户ID: ${currentUser.id}");
                    final address = Address(
                      userId: currentUser.id,  // 设置用户ID
                      name: _nameController.text,
                      phone: _phoneController.text,
                      province: _provinceController.text,
                      city: _cityController.text,
                      district: _districtController.text,
                      detailAddress: _detailAddressController.text,
                      isDefault: _isDefault,
                    );
                    
                    print("AddAddressPage: 地址数据: ${address.toMap()}");

                    await Provider.of<AddressProvider>(context, listen: false)
                      .addAddress(address);
                      
                    print("AddAddressPage: 地址添加完成，返回上一页");
                    Navigator.pop(context);
                  } catch (e) {
                    print("AddAddressPage: 添加地址时出错: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('添加地址失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C1B3),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
} 