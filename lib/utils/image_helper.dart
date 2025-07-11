import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../backend/database_helper.dart';
import '../backend/product_provider.dart';

class ImageHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // 获取应用文档目录
  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  // 获取图片存储目录
  static Future<Directory> getImageDirectory() async {
    final appDir = await getAppDirectory();
    final imageDir = Directory('${appDir.path}/pic2');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }
  
  // 从资源复制图片到本地并保存路径到数据库
  static Future<bool> copyAssetToLocalAndSaveToDatabase(int productId, String assetPath) async {
    try {
      // 获取图片存储目录
      final imageDir = await getImageDirectory();
      print("ImageHelper: 图片存储目录: ${imageDir.path}");
      
      // 验证目录是否存在且可写
      if (!await imageDir.exists()) {
        print("ImageHelper: 警告 - 目录不存在，尝试创建: ${imageDir.path}");
        await imageDir.create(recursive: true);
      }
      
      // 检查目录权限
      try {
        final testFile = File('${imageDir.path}/test_write.tmp');
        await testFile.writeAsString('test');
        await testFile.delete();
        print("ImageHelper: 目录权限检查通过，可以写入文件");
      } catch (e) {
        print("ImageHelper: 目录权限检查失败，可能无法写入文件: $e");
        return false;
      }
      
      // 生成唯一文件名
      final fileName = 'product_${productId}_${path.basename(assetPath)}';
      final localFilePath = '${imageDir.path}/$fileName';
      print("ImageHelper: 生成的本地文件路径: $localFilePath");
      
      // 从资源加载图片
      try {
        final ByteData data = await rootBundle.load(assetPath);
        final Uint8List bytes = data.buffer.asUint8List();
        print("ImageHelper: 从资源加载图片成功: $assetPath, 大小: ${bytes.length} 字节");
        
        // 保存到本地文件
        final File localFile = File(localFilePath);
        await localFile.writeAsBytes(bytes);
        print("ImageHelper: 保存图片到本地文件成功: $localFilePath");
        
        // 验证文件是否存在
        if (await localFile.exists()) {
          final fileSize = await localFile.length();
          print("ImageHelper: 确认文件存在: $localFilePath, 大小: $fileSize 字节");
          
          if (fileSize == 0) {
            print("ImageHelper: 警告 - 文件大小为0，可能未正确写入");
            return false;
          }
        } else {
          print("ImageHelper: 错误 - 文件应该已创建但无法确认其存在: $localFilePath");
          return false;
        }
      } catch (e, stackTrace) {
        print("ImageHelper: 加载或保存资源图片时出错: $e");
        print("ImageHelper: 堆栈跟踪: $stackTrace");
        return false;
      }
      
      // 保存绝对路径到数据库
      final absolutePath = File(localFilePath).absolute.path;
      print("ImageHelper: 使用绝对路径保存到数据库: $absolutePath");
      final result = await _databaseHelper.updateProductImagePath(productId, absolutePath);
      print("ImageHelper: 更新商品 $productId 图片路径结果: $result");
      
      return result > 0;
    } catch (e, stackTrace) {
      print("ImageHelper: 复制资源图片到本地时出错: $e");
      print("ImageHelper: 堆栈跟踪: $stackTrace");
      return false;
    }
  }
  
  // 从文件复制图片到本地并保存路径到数据库
  static Future<bool> copyFileToLocalAndSaveToDatabase(int productId, File file) async {
    try {
      // 获取图片存储目录
      final imageDir = await getImageDirectory();
      
      // 生成唯一文件名
      final fileName = 'product_${productId}_${DateTime.now().millisecondsSinceEpoch}.${path.extension(file.path)}';
      final localFilePath = '${imageDir.path}/$fileName';
      
      // 复制文件
      final File localFile = await file.copy(localFilePath);
      
      print("复制图片到本地: ${file.path} -> $localFilePath");
      
      // 保存路径到数据库
      final result = await _databaseHelper.updateProductImagePath(productId, localFilePath);
      print("更新商品 $productId 图片路径结果: $result");
      
      return result > 0;
    } catch (e) {
      print("复制图片到本地时出错: $e");
      return false;
    }
  }
  
  // 从图片选择器选择图片并保存到数据库
  static Future<bool> pickImageAndSaveToDatabase(BuildContext context, int productId) async {
    try {
      // 初始化图片选择器
      final ImagePicker picker = ImagePicker();
      
      // 选择图片
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        print("未选择图片");
        return false;
      }
      
      // 复制文件到本地
      final File file = File(image.path);
      final success = await copyFileToLocalAndSaveToDatabase(productId, file);
      
      // 更新ProductProvider
      if (success && context.mounted) {
        await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        return true;
      }
      
      return success;
    } catch (e) {
      print("选择并保存图片时出错: $e");
      return false;
    }
  }
  
  // 显示图片选择对话框
  static void showImagePickerDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片'),
        content: const Text('请选择一张图片保存到数据库'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await pickImageAndSaveToDatabase(context, productId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '图片保存成功' : '图片保存失败'),
                  ),
                );
              }
            },
            child: const Text('选择图片'),
          ),
        ],
      ),
    );
  }
} 