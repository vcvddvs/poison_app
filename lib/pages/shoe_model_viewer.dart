import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ShoeModelViewer extends StatefulWidget {
  final String title;

  const ShoeModelViewer({
    Key? key,
    this.title = '3D模型预览',
  }) : super(key: key);

  @override
  State<ShoeModelViewer> createState() => _ShoeModelViewerState();
}

class _ShoeModelViewerState extends State<ShoeModelViewer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: Colors.white,
            child: const ModelViewer(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              src: 'assets/3dmodel/shoe_model.glb',
              alt: "A 3D model of a shoe",
              ar: true,
              autoRotate: true,
              cameraControls: true,
              shadowIntensity: 0.1,
            ),
          ),
    );
  }
} 