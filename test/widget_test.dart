// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poison_app/main.dart' as app;

void main() {
  testWidgets('应用启动后UI测试', (WidgetTester tester) async {
    // 构建我们的应用并触发一个frame
    app.main();
    await tester.pumpAndSettle();

    // 验证应用已启动
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // 这个测试主要是验证应用能否正常启动，更复杂的UI测试需要根据实际UI结构调整
  });
}
