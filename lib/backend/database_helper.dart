import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'poison_app.db');
    print("DatabaseHelper: 数据库路径: $path");
    
    // 检查数据库文件是否存在
    bool dbExists = await databaseExists(path);
    print("DatabaseHelper: 数据库文件${dbExists ? '已存在' : '不存在'}");
    
    // 打开数据库
    Database db = await openDatabase(
      path,
      version: 6, // 版本号
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
    
    // 验证数据库是否正确打开
    print("DatabaseHelper: 数据库已打开，版本: ${await db.getVersion()}");
    
    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    // 创建产品表
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        price TEXT,
        imageUrl TEXT,
        tag TEXT,
        brand TEXT,
        subInfo TEXT,
        localImagePath TEXT,
        payment_count INTEGER
      )
    ''');

    // 创建用户表
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        username TEXT,
        avatar TEXT,
        email TEXT,
        address TEXT,
        created_at TEXT
      )
    ''');

    // 创建地址表
    await db.execute('''
      CREATE TABLE addresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT,
        phone TEXT,
        province TEXT,
        city TEXT,
        district TEXT,
        detail_address TEXT,
        is_default INTEGER
      )
    ''');

    // 创建订单表
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        product_name TEXT,
        product_image TEXT,
        size TEXT,
        color TEXT,
        quantity INTEGER,
        price REAL,
        delivery_fee REAL,
        total_price REAL,
        address TEXT,
        order_number TEXT,
        merchant_info TEXT,
        purchase_channel TEXT,
        create_time TEXT,
        payment_method TEXT,
        transaction_status TEXT,
        is_delivered INTEGER DEFAULT 0,
        is_evaluated INTEGER DEFAULT 0
      )
    ''');

    // 创建商品规格表
    await db.execute('''
      CREATE TABLE product_variants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        color TEXT,
        size TEXT,
        price TEXT,
        stock INTEGER,
        local_image_path TEXT
      )
    ''');

    // 创建商品规格选项表
    await db.execute('''
      CREATE TABLE product_specifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        spec_type TEXT,
        spec_value TEXT,
        brand_path TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加地址表
      await db.execute('''
        CREATE TABLE addresses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          name TEXT,
          phone TEXT,
          province TEXT,
          city TEXT,
          district TEXT,
          detail_address TEXT,
          is_default INTEGER
        )
      ''');
    }

    if (oldVersion < 3) {
      // 添加订单表
      await db.execute('''
        CREATE TABLE orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          product_name TEXT,
          product_image TEXT,
          size TEXT,
          color TEXT,
          quantity INTEGER,
          price REAL,
          delivery_fee REAL,
          total_price REAL,
          address TEXT,
          order_number TEXT,
          merchant_info TEXT,
          purchase_channel TEXT,
          create_time TEXT,
          payment_method TEXT,
          transaction_status TEXT,
          is_delivered INTEGER DEFAULT 0,
          is_evaluated INTEGER DEFAULT 0
        )
      ''');
    }
    
    // 版本4的更新
    if (oldVersion < 4) {
      // 如果用户表不存在，创建它
      var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='users'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            username TEXT,
            avatar TEXT,
            email TEXT,
            address TEXT,
            created_at TEXT
          )
        ''');
      }
      
      // 如果订单表不存在，创建它
      tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='orders'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE orders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            product_name TEXT,
            product_image TEXT,
            size TEXT,
            color TEXT,
            quantity INTEGER,
            price REAL,
            delivery_fee REAL,
            total_price REAL,
            address TEXT,
            order_number TEXT,
            merchant_info TEXT,
            purchase_channel TEXT,
            create_time TEXT,
            payment_method TEXT,
            transaction_status TEXT,
            is_delivered INTEGER DEFAULT 0,
            is_evaluated INTEGER DEFAULT 0
          )
        ''');
      }
      
      // 如果商品规格表不存在，创建它
      tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='product_variants'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE product_variants(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            color TEXT,
            size TEXT,
            price TEXT,
            stock INTEGER,
            local_image_path TEXT
          )
        ''');
      }
      
      // 如果商品规格选项表不存在，创建它
      tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='product_specifications'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE product_specifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            spec_type TEXT,
            spec_value TEXT,
            brand_path TEXT
          )
        ''');
      }
    }
    
    // 版本5的更新 - 确保订单表存在
    if (oldVersion < 5) {
      try {
        // 检查订单表是否存在
        var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='orders'");
        if (tables.isEmpty) {
          print("Creating orders table as it doesn't exist");
          await db.execute('''
            CREATE TABLE orders(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              product_name TEXT,
              product_image TEXT,
              size TEXT,
              color TEXT,
              quantity INTEGER,
              price REAL,
              delivery_fee REAL,
              total_price REAL,
              address TEXT,
              order_number TEXT,
              merchant_info TEXT,
              purchase_channel TEXT,
              create_time TEXT,
              payment_method TEXT,
              transaction_status TEXT,
              is_delivered INTEGER DEFAULT 0,
              is_evaluated INTEGER DEFAULT 0
            )
          ''');
        } else {
          print("Orders table already exists");
        }
      } catch (e) {
        print("Error checking/creating orders table: $e");
      }
    }
    
    // 版本6的更新 - 添加付款人数字段
    if (oldVersion < 6) {
      try {
        // 检查products表中是否有payment_count列
        var columns = await db.rawQuery("PRAGMA table_info(products)");
        bool hasPaymentCount = columns.any((col) => col['name'] == 'payment_count');
        
        if (!hasPaymentCount) {
          print("Adding payment_count column to products table");
          await db.execute("ALTER TABLE products ADD COLUMN payment_count INTEGER");
          
          // 更新现有产品的付款人数
          // 这里可以设置一些默认值
          await db.update('products', {'payment_count': 0}, where: 'payment_count IS NULL');
          
          // 为示例产品添加付款人数
          await db.update('products', {'payment_count': 19000}, where: "title LIKE '%Jordan Air Jordan 3%'");
          await db.update('products', {'payment_count': 1500}, where: "title LIKE '%WOW1%'");
          await db.update('products', {'payment_count': 60000}, where: "title LIKE '%iPhone%'");
        } else {
          print("payment_count column already exists");
        }
      } catch (e) {
        print("Error adding payment_count column: $e");
      }
    }
  }

  // 产品相关操作
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    
    print("DatabaseHelper: 从数据库加载了 ${maps.length} 个产品");
    
    if (maps.isEmpty) {
      // 如果数据库中没有产品，则插入样例数据
      await insertSampleProducts();
      return Product.getSampleProducts();
    }
    
    return List.generate(maps.length, (i) {
      print("DatabaseHelper: 加载产品 ${maps[i]['id']} - ${maps[i]['title']}");
      return Product(
        id: maps[i]['id'],
        imageUrl: maps[i]['imageUrl'] ?? '',
        title: maps[i]['title'] ?? '',
        price: maps[i]['price'] ?? '',
        brand: maps[i]['brand'],
        tag: maps[i]['tag'],
        subInfo: maps[i]['subInfo'],
        paymentCount: maps[i]['payment_count'],
        localImagePath: maps[i]['localImagePath'],
      );
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 插入样例产品数据
  Future<void> insertSampleProducts() async {
    final db = await database;
    print("DatabaseHelper: 插入样例产品数据");
    
    // 样例产品列表
    final sampleProducts = [
      {
        'title': 'LiNing李宁 WOW1 魔鬼鱼 高回弹碳板减震',
        'price': '¥1399',
        'imageUrl': 'assets/pic/img_1.png',
        'tag': '全网低价',
        'brand': '李宁',
        'payment_count': 1500
      },
      {
        'title': 'Jordan Air Jordan 4 时尚百搭碳板防滑耐磨',
        'price': '¥1519',
        'imageUrl': 'assets/pic/img_2.png',
        'tag': '抢先发售',
        'brand': 'Air Jordan',
        'payment_count': 3200
      },
      {
        'title': 'Anta安踏 狂潮7 A-SHOCK',
        'price': '¥599',
        'imageUrl': 'assets/pic/img_3.png',
        'tag': 'NEW 新品发售',
        'brand': '安踏',
        'payment_count': 800
      },
      {
        'title': 'Jordan Air Jordan 3 retro',
        'price': '¥1299',
        'imageUrl': 'assets/pic/img_4.png',
        'tag': '礼物节 | 领券再省45元',
        'brand': 'Air Jordan',
        'payment_count': 19000
      },
      {
        'title': 'New Balance nb998',
        'price': '¥999',
        'imageUrl': 'assets/pic/img_5.png',
        'brand': 'New Balance',
        'payment_count': 5600
      }
    ];
    
    // 插入样例产品
    for (var product in sampleProducts) {
      try {
        final id = await db.insert('products', product);
        print("DatabaseHelper: 插入样例产品成功，ID: $id, 标题: ${product['title']}");
      } catch (e) {
        print("DatabaseHelper: 插入样例产品失败: $e");
      }
    }
  }

  // 地址相关操作
  Future<int> insertAddress(Address address) async {
    final db = await database;
    print("DatabaseHelper: 插入地址: ${address.toMap()}");
    
    // 如果这是默认地址，先将所有地址设为非默认
    if (address.isDefault) {
      print("DatabaseHelper: 这是默认地址，将重置其他地址");
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [address.userId],
      );
    }
    
    try {
      final id = await db.insert('addresses', address.toMap());
      print("DatabaseHelper: 地址插入成功，ID: $id");
      return id;
    } catch (e) {
      print("DatabaseHelper: 地址插入失败: $e");
      return -1;
    }
  }

  Future<List<Address>> getAddresses(int userId) async {
    final db = await database;
    print("DatabaseHelper: 获取用户ID为 $userId 的地址");
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'addresses',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      print("DatabaseHelper: 找到 ${maps.length} 个地址");
      
      // 打印所有地址信息用于调试
      for (var map in maps) {
        print("DatabaseHelper: 地址ID: ${map['id']}, 用户ID: ${map['user_id']}, 姓名: ${map['name']}, 电话: ${map['phone']}");
      }
      
      return List.generate(maps.length, (i) {
        // 确保所有字段都有正确的类型
        return Address.fromMap({
          'id': maps[i]['id'],
          'user_id': maps[i]['user_id'],
          'name': maps[i]['name'] ?? '',
          'phone': maps[i]['phone'] ?? '',
          'province': maps[i]['province'] ?? '',
          'city': maps[i]['city'] ?? '',
          'district': maps[i]['district'] ?? '',
          'detail_address': maps[i]['detail_address'] ?? '',
          'is_default': maps[i]['is_default'] ?? 0,
        });
      });
    } catch (e) {
      print("DatabaseHelper: 获取地址失败: $e");
      return [];
    }
  }

  Future<int> updateAddress(Address address) async {
    final db = await database;
    print("DatabaseHelper: 更新地址ID: ${address.id}");
    
    // 如果这是默认地址，先将所有地址设为非默认
    if (address.isDefault) {
      print("DatabaseHelper: 这是默认地址，将重置其他地址");
      await db.update(
        'addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [address.userId],
      );
    }
    
    try {
      final result = await db.update(
        'addresses',
        address.toMap(),
        where: 'id = ?',
        whereArgs: [address.id],
      );
      print("DatabaseHelper: 地址更新结果: $result");
      return result;
    } catch (e) {
      print("DatabaseHelper: 地址更新失败: $e");
      return 0;
    }
  }

  Future<int> deleteAddress(int id) async {
    final db = await database;
    print("DatabaseHelper: 删除地址ID: $id");
    
    try {
      final result = await db.delete(
        'addresses',
        where: 'id = ?',
        whereArgs: [id],
      );
      print("DatabaseHelper: 地址删除结果: $result");
      return result;
    } catch (e) {
      print("DatabaseHelper: 地址删除失败: $e");
      return 0;
    }
  }

  // 订单相关操作
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<Order>> getOrders(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<List<Order>> getPendingPaymentOrders(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'user_id = ? AND transaction_status = ?',
      whereArgs: [userId, '待支付'],
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<List<Order>> getPendingShipmentOrders(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'user_id = ? AND transaction_status = ? AND is_delivered = 0',
      whereArgs: [userId, '支付成功'],
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<List<Order>> getPendingReceiptOrders(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'user_id = ? AND transaction_status = ? AND is_delivered = 1 AND is_evaluated = 0',
      whereArgs: [userId, '支付成功'],
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<List<Order>> getPendingEvaluationOrders(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'user_id = ? AND is_delivered = 1 AND is_evaluated = 0',
      whereArgs: [userId],
      orderBy: 'create_time DESC',
    );
    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 以下是为了兼容现有代码添加的方法
  
  // 获取特定用户的默认地址
  Future<Address?> getDefaultAddress({int? userId}) async {
    final db = await database;
    print("DatabaseHelper: 获取默认地址，用户ID: $userId");
    
    try {
      List<Map<String, dynamic>> maps;
      
      if (userId != null) {
        // 如果提供了用户ID，只获取该用户的默认地址
        maps = await db.query(
          'addresses',
          where: 'is_default = ? AND user_id = ?',
          whereArgs: [1, userId],
          limit: 1,
        );
      } else {
        // 否则获取任意默认地址
        maps = await db.query(
          'addresses',
          where: 'is_default = ?',
          whereArgs: [1],
          limit: 1,
        );
      }
      
      print("DatabaseHelper: 找到默认地址: ${maps.isNotEmpty}");
      
      if (maps.isEmpty) return null;
      return Address.fromMap(maps.first);
    } catch (e) {
      print("DatabaseHelper: 获取默认地址失败: $e");
      return null;
    }
  }
  
  // 设置默认地址
  Future<void> setDefaultAddress(int id, {int? userId}) async {
    final db = await database;
    print("DatabaseHelper: 设置默认地址，ID: $id，用户ID: $userId");
    
    try {
      await db.transaction((txn) async {
        if (userId != null) {
          // 只将特定用户的地址设为非默认
          await txn.update(
            'addresses', 
            {'is_default': 0},
            where: 'user_id = ?',
            whereArgs: [userId]
          );
        } else {
          // 将所有地址设为非默认
          await txn.update('addresses', {'is_default': 0});
        }
        
        // 将指定地址设为默认
        final result = await txn.update(
          'addresses',
          {'is_default': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
        print("DatabaseHelper: 设置默认地址结果: $result");
      });
    } catch (e) {
      print("DatabaseHelper: 设置默认地址失败: $e");
    }
  }
  
  // 用户相关操作
  Future<User?> loginUser(String phone, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  
  // 产品相关操作
  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps[0]);
    }
    return null;
  }
  
  Future<int> updateProductImagePath(int productId, String localImagePath) async {
    final db = await database;
    return await db.update(
      'products',
      {'local_image_path': localImagePath},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
  
  // 商品规格相关操作
  Future<int> addProductVariant(Map<String, dynamic> variant) async {
    final db = await database;
    try {
      return await db.insert('product_variants', variant);
    } catch (e) {
      print("添加商品变体失败: $e");
      return -1;
    }
  }
  
  Future<List<Map<String, dynamic>>> getProductVariants(int productId) async {
    final db = await database;
    try {
      return await db.query(
        'product_variants',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print("获取商品变体失败: $e");
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getProductSpecifications(int productId) async {
    final db = await database;
    try {
      return await db.query(
        'product_specifications',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      print("获取商品规格失败: $e");
      return [];
    }
  }
  
  Future<void> addBrandSpecification(int productId, String brandName, String brandPath) async {
    final db = await database;
    try {
      // 先检查是否已存在品牌信息
      final existing = await db.query(
        'product_specifications',
        where: 'product_id = ? AND spec_type = ?',
        whereArgs: [productId, '品牌信息'],
      );

      if (existing.isEmpty) {
        // 如果不存在，则插入新的品牌信息
        await db.insert('product_specifications', {
          'product_id': productId,
          'spec_type': '品牌信息',
          'spec_value': brandName,
          'brand_path': brandPath,
        });
        print("DatabaseHelper: 已添加品牌信息 - 产品ID: $productId, 品牌: $brandName, 路径: $brandPath");
      } else {
        // 如果存在，则更新
        await db.update(
          'product_specifications',
          {
            'spec_value': brandName,
            'brand_path': brandPath,
          },
          where: 'product_id = ? AND spec_type = ?',
          whereArgs: [productId, '品牌信息'],
        );
        print("DatabaseHelper: 已更新品牌信息 - 产品ID: $productId, 品牌: $brandName, 路径: $brandPath");
      }
    } catch (e) {
      print("DatabaseHelper: 添加/更新品牌信息时出错: $e");
    }
  }
  
  // 重置数据库
  Future<void> resetDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'poison_app.db');
      print("正在删除数据库: $path");
      await deleteDatabase(path);
      print("数据库已删除");
      
      // 重新初始化数据库
      _database = null;
      await database;
      print("数据库已重新创建");
    } catch (e) {
      print("重置数据库时出错: $e");
    }
  }

  // 更新品牌路径
  Future<void> updateBrandPath(int productId, String newPath) async {
    final db = await database;
    try {
      await db.update(
        'product_specifications',
        {'brand_path': newPath},
        where: 'product_id = ? AND spec_type = ?',
        whereArgs: [productId, '品牌信息'],
      );
      print('Updated brand path for product $productId to: $newPath');
    } catch (e) {
      print('Error updating brand path: $e');
    }
  }
  
  // 根据手机号获取用户
  Future<User?> getUserByPhone(String phone) async {
    final db = await database;
    print("DatabaseHelper: 正在根据手机号查找用户: '$phone'");
    
    try {
      // 查询数据库中的所有用户，用于调试
      final allUsers = await db.query('users');
      print("DatabaseHelper: 数据库中总共有 ${allUsers.length} 个用户:");
      for (var user in allUsers) {
        print("  - ID: ${user['id']}, 手机号: '${user['phone']}', 用户名: ${user['username']}");
      }
      
      // 正常查询指定手机号的用户
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'phone = ?',
        whereArgs: [phone],
      );
      
      print("DatabaseHelper: 根据手机号 '$phone' 找到 ${maps.length} 个用户");
      
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print("DatabaseHelper: 查询用户时出错: $e");
      return null;
    }
  }
} 