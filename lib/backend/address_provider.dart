import 'package:flutter/foundation.dart';
import '../models/address.dart';
import 'database_helper.dart';
import 'auth_service.dart';

class AddressProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AuthService _authService;
  List<Address> _addresses = [];
  Address? _selectedAddress;

  // Constructor now requires AuthService
  AddressProvider(this._authService);

  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;

  // 初始化时加载地址
  Future<void> loadAddresses() async {
    print("AddressProvider: 开始加载地址");
    
    if (!_authService.isLoggedIn) {
      print("AddressProvider: 用户未登录，无法加载地址");
      return;
    }
    
    final currentUser = _authService.currentUser!;
    print("AddressProvider: 当前用户ID: ${currentUser.id}");
    
    try {
      // 直接从数据库查询地址
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'addresses',
        where: 'user_id = ?',
        whereArgs: [currentUser.id],
      );
      
      print("AddressProvider: 从数据库加载到 ${maps.length} 个地址");
      
      // 转换为Address对象
      _addresses = [];
      for (var map in maps) {
        try {
          print("AddressProvider: 处理地址 - ID: ${map['id']}, 姓名: ${map['name']}");
          final address = Address(
            id: map['id'] as int?,
            userId: map['user_id'] as int?,
            name: (map['name'] ?? '') as String,
            phone: (map['phone'] ?? '') as String,
            province: (map['province'] ?? '') as String,
            city: (map['city'] ?? '') as String,
            district: (map['district'] ?? '') as String,
            detailAddress: (map['detail_address'] ?? '') as String,
            isDefault: (map['is_default'] ?? 0) == 1,
          );
          _addresses.add(address);
        } catch (e) {
          print("AddressProvider: 处理单个地址时出错: $e");
        }
      }
      
      print("AddressProvider: 加载到 ${_addresses.length} 个地址");
      
      // 获取默认地址
      try {
        final defaultAddressMaps = await db.query(
          'addresses',
          where: 'is_default = ? AND user_id = ?',
          whereArgs: [1, currentUser.id],
          limit: 1,
        );
        
        if (defaultAddressMaps.isNotEmpty) {
          final map = defaultAddressMaps.first;
          _selectedAddress = Address(
            id: map['id'] as int?,
            userId: map['user_id'] as int?,
            name: (map['name'] ?? '') as String,
            phone: (map['phone'] ?? '') as String,
            province: (map['province'] ?? '') as String,
            city: (map['city'] ?? '') as String,
            district: (map['district'] ?? '') as String,
            detailAddress: (map['detail_address'] ?? '') as String,
            isDefault: true,
          );
          print("AddressProvider: 默认地址: ${_selectedAddress?.fullAddress ?? '无'}");
        } else if (_addresses.isNotEmpty) {
          // 如果没有默认地址但有地址，选择第一个
          _selectedAddress = _addresses.first;
          print("AddressProvider: 没有默认地址，选择第一个: ${_selectedAddress?.fullAddress}");
        }
      } catch (e) {
        print("AddressProvider: 获取默认地址时出错: $e");
      }
      
      notifyListeners();
    } catch (e) {
      print("AddressProvider: 加载地址时出错: $e");
    }
  }

  // 添加新地址
  Future<void> addAddress(Address address) async {
    print("AddressProvider: 开始添加新地址");
    try {
      // 获取当前用户ID
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        print('AddressProvider: 添加地址失败：用户未登录');
        return;
      }
      
      print("AddressProvider: 当前用户ID: ${currentUser.id}");

      // 创建包含用户ID的新地址
      final newAddress = Address(
        name: address.name,
        phone: address.phone,
        province: address.province,
        city: address.city,
        district: address.district,
        detailAddress: address.detailAddress,
        isDefault: address.isDefault,
        userId: currentUser.id,
      );
      
      print("AddressProvider: 准备插入地址: ${newAddress.toMap()}");
      
      try {
        // 直接使用数据库对象进行插入，以便更好地捕获错误
        final db = await _databaseHelper.database;
        final id = await db.insert('addresses', {
          'user_id': currentUser.id,
          'name': newAddress.name,
          'phone': newAddress.phone,
          'province': newAddress.province,
          'city': newAddress.city,
          'district': newAddress.district,
          'detail_address': newAddress.detailAddress,
          'is_default': newAddress.isDefault ? 1 : 0,
        });
        
        print("AddressProvider: 地址直接插入结果ID: $id");
        
        // 如果是默认地址，设置为默认（只针对当前用户）
        if (newAddress.isDefault && id > 0) {
          await _databaseHelper.setDefaultAddress(id, userId: currentUser.id);
          print("AddressProvider: 已设置为默认地址");
        }
      } catch (e) {
        print("AddressProvider: 直接插入地址时出错: $e");
      }
      
      // 重新加载地址列表
      await loadAddresses();
    } catch (e) {
      print('AddressProvider: 添加地址时出错: $e');
    }
  }

  // 更新地址
  Future<void> updateAddress(Address address) async {
    try {
      // 获取当前用户ID
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        print('更新地址失败：用户未登录');
        return;
      }

      // 确保地址属于当前用户
      final updatedAddress = Address(
        id: address.id,
        name: address.name,
        phone: address.phone,
        province: address.province,
        city: address.city,
        district: address.district,
        detailAddress: address.detailAddress,
        isDefault: address.isDefault,
        userId: currentUser.id,
      );
      
      // 更新地址
      await _databaseHelper.updateAddress(updatedAddress);
      
      // 如果是默认地址，设置为默认（只针对当前用户）
      if (updatedAddress.isDefault && updatedAddress.id != null) {
        await _databaseHelper.setDefaultAddress(updatedAddress.id!, userId: currentUser.id);
      }
      
      await loadAddresses();
    } catch (e) {
      print('更新地址时出错: $e');
    }
  }

  // 删除地址
  Future<void> deleteAddress(int id) async {
    try {
      // 获取当前用户ID
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        print('删除地址失败：用户未登录');
        return;
      }

      // 确保只删除当前用户的地址
      final db = await _databaseHelper.database;
      await db.delete(
        'addresses',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, currentUser.id],
      );
      
      await loadAddresses();
    } catch (e) {
      print('删除地址时出错: $e');
    }
  }

  // 设置默认地址
  Future<void> setDefaultAddress(int id) async {
    try {
      // 获取当前用户ID
      final currentUser = _authService.currentUser;
      if (currentUser == null || currentUser.id == null) {
        print('设置默认地址失败：用户未登录');
        return;
      }

      print("AddressProvider: 设置默认地址 ID: $id");
      
      // 只针对当前用户设置默认地址
      await _databaseHelper.setDefaultAddress(id, userId: currentUser.id);
      
      // 更新选中的地址
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'addresses',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        final address = Address.fromMap(maps.first);
        _selectedAddress = address;
        print("AddressProvider: 已选择默认地址: ${address.fullAddress}");
      }
      
      // 重新加载地址列表
      await loadAddresses();
      
      notifyListeners();
    } catch (e) {
      print('设置默认地址时出错: $e');
    }
  }

  // 选择地址
  void selectAddress(Address address) {
    print("AddressProvider: 选择地址 ID: ${address.id}");
    _selectedAddress = address;
    notifyListeners();
  }
} 