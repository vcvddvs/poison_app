import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthService with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  
  // 添加一个getter来获取数据库助手实例
  DatabaseHelper get databaseHelper => _databaseHelper;

  // 注册新用户
  Future<bool> register(String phone, String password, {String? username}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 处理手机号和密码，确保格式一致
      phone = phone.trim();
      password = password.trim();
      
      print("AuthService: 开始注册 - 手机号: $phone, 用户名: ${username ?? '未提供'}");
      
      // 创建新用户实例
      final newUser = User(
        phone: phone,
        password: password, // 注意：实际应用中应该对密码进行加密
        username: username ?? '用户${phone.substring(phone.length - 4)}',
        createdAt: DateTime.now().toString(),
      );
      
      // 检查用户是否已存在
      final existingUser = await _databaseHelper.getUserByPhone(phone);
      if (existingUser != null) {
        print("AuthService: 注册失败 - 用户已存在: ${existingUser.id}");
        _errorMessage = '该手机号已注册';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // 直接使用insert方法插入用户
      final db = await _databaseHelper.database;
      final result = await db.insert('users', newUser.toMap());
      
      print("AuthService: 用户注册结果 - ID: $result");
      
      if (result > 0) {
        // 注册成功，获取包含ID的完整用户信息
        _currentUser = await _databaseHelper.getUserByPhone(phone);
        
        if (_currentUser != null) {
          print("AuthService: 注册成功并获取到用户 - ID: ${_currentUser!.id}, 手机号: ${_currentUser!.phone}");
        } else {
          print("AuthService: 警告 - 注册成功但无法获取新创建的用户");
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print("AuthService: 注册失败 - 数据库插入返回非正值");
        _errorMessage = '注册失败，请稍后再试';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("AuthService: 注册过程中出错 - ${e.toString()}");
      _errorMessage = '注册出错: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 用户登录
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 对手机号和密码进行处理，去除两端空格
      phone = phone.trim();
      password = password.trim();
      
      print("AuthService: 尝试登录 - 手机号: $phone");
      
      // 先检查用户是否存在
      final user = await _databaseHelper.getUserByPhone(phone);
      if (user == null) {
        print("AuthService: 用户不存在 - 手机号: $phone");
        _errorMessage = '该账号不存在，请先注册';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      print("AuthService: 找到用户 - ID: ${user.id}, 用户名: ${user.username}");
      
      // 验证密码
      if (user.password != password) {
        print("AuthService: 密码错误 - 输入: $password, 数据库: ${user.password}");
        _errorMessage = '密码错误，请重新输入';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      print("AuthService: 登录成功 - ID: ${user.id}, 用户名: ${user.username}");
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("AuthService: 登录出错 - ${e.toString()}");
      _errorMessage = '登录出错: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 注销登录
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
  
  // 修改用户信息
  Future<bool> updateUserProfile({
    String? username,
    String? email,
    String? avatar,
    String? address,
  }) async {
    if (_currentUser == null) {
      _errorMessage = '用户未登录';
      return false;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = User(
        id: _currentUser!.id,
        phone: _currentUser!.phone,
        password: _currentUser!.password,
        username: username ?? _currentUser!.username,
        email: email ?? _currentUser!.email,
        avatar: avatar ?? _currentUser!.avatar,
        address: address ?? _currentUser!.address,
        createdAt: _currentUser!.createdAt,
      );
      
      final result = await _databaseHelper.updateUser(updatedUser);
      
      if (result > 0) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '更新用户信息失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '更新用户信息出错: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 修改密码
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) {
      _errorMessage = '用户未登录';
      return false;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      // 验证旧密码是否正确
      if (_currentUser!.password != oldPassword) {
        _errorMessage = '原密码输入错误';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // 更新密码
      final updatedUser = User(
        id: _currentUser!.id,
        phone: _currentUser!.phone,
        password: newPassword,
        username: _currentUser!.username,
        email: _currentUser!.email,
        avatar: _currentUser!.avatar,
        address: _currentUser!.address,
        createdAt: _currentUser!.createdAt,
      );
      
      final result = await _databaseHelper.updateUser(updatedUser);
      
      if (result > 0) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '修改密码失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '修改密码出错: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 