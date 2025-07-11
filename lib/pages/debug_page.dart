import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildDebugSection(
              'System Information',
              [
                'Platform: ${Theme.of(context).platform}',
                'Brightness: ${Theme.of(context).brightness}',
                'Text Scale: ${MediaQuery.of(context).textScaleFactor}',
              ],
            ),
            const SizedBox(height: 20),
            _buildDebugSection(
              'Device Information',
              [
                'Screen Size: ${MediaQuery.of(context).size}',
                'Pixel Ratio: ${MediaQuery.of(context).devicePixelRatio}',
                'Safe Area: ${MediaQuery.of(context).padding}',
              ],
            ),
            const SizedBox(height: 20),
            _buildDebugSection(
              'Theme Information',
              [
                'Primary Color: ${Theme.of(context).primaryColor}',
                'Scaffold Background: ${Theme.of(context).scaffoldBackgroundColor}',
                'Text Theme: ${Theme.of(context).textTheme.bodyLarge?.fontSize}',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item),
            )).toList(),
          ),
        ),
      ],
    );
  }
} 