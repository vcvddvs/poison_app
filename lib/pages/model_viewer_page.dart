import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class ModelViewerPage extends StatefulWidget {
  final String modelPath;
  final String title;

  const ModelViewerPage({
    Key? key,
    required this.modelPath,
    this.title = '3D模型预览',
  }) : super(key: key);

  @override
  State<ModelViewerPage> createState() => _ModelViewerPageState();
}

class _ModelViewerPageState extends State<ModelViewerPage> {
  Object? _model;
  bool _loading = true;
  String _errorMessage = '';
  Scene? _scene;
  bool _autoRotate = false;
  
  @override
  void initState() {
    super.initState();
    _loadModel();
  }
  
  @override
  void dispose() {
    _stopAutoRotate();
    super.dispose();
  }
  
  void _loadModel() {
    try {
      setState(() {
        _loading = true;
        _errorMessage = '';
      });
      
      print("尝试加载模型: ${widget.modelPath}");
      _model = Object(fileName: widget.modelPath, scale: Vector3(5.0, 5.0, 5.0));
      
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = '加载3D模型失败: $e';
        print('加载3D模型失败: $e');
      });
    }
  }
  
  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
      if (_autoRotate) {
        _startAutoRotate();
      } else {
        _stopAutoRotate();
      }
    });
  }
  
  void _startAutoRotate() {
    if (_scene != null && _model != null) {
      _scene!.update();
      _model!.rotation.y += 0.01;
      if (_autoRotate) {
        Future.delayed(const Duration(milliseconds: 16), _startAutoRotate);
      }
    }
  }
  
  void _stopAutoRotate() {
    setState(() {
      _autoRotate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoRotate,
            tooltip: _autoRotate ? '停止旋转' : '自动旋转',
          ),
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty 
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 24),
                    Text("尝试加载的文件: ${widget.modelPath}", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : Center(
              child: Cube(
                onSceneCreated: (Scene scene) {
                  _scene = scene;
                  if (_model != null) {
                    scene.world.add(_model!);
                    
                    // 调整相机位置以获得更好的视角
                    scene.camera.zoom = 10;
                    scene.camera.position.x = 15;
                    scene.camera.position.y = 15;
                    scene.camera.position.z = 15;
                    
                    // 设置光照位置
                    scene.light.position.setFrom(Vector3(0, 10, 10));
                  }
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadModel,
        child: const Icon(Icons.refresh),
        tooltip: '重新加载模型',
      ),
    );
  }
} 