
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paywise_mobile/main.dart';

void main() {
  testWidgets('PayWise app displays its title', (tester) async {
    await tester.pumpWidget(const PayWiseApp());

    expect(find.text('PayWise'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
