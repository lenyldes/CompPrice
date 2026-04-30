import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compprice/main.dart';

void main() {
  testWidgets('CompPrice app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CompPriceApp());

    expect(find.text('CompPrice'), findsOneWidget);
    expect(find.text('Цена'), findsOneWidget);
    expect(find.text('Количество'), findsOneWidget);
    expect(find.text('Добавить'), findsOneWidget);
    expect(find.text('Добавьте товар для сравнения'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Цена'), '90');
    await tester.enterText(
      find.widgetWithText(TextField, 'Количество'),
      '0.9',
    );
    await tester.pump();

    await tester.tap(find.text('Добавить'));
    await tester.pump();

    expect(find.text('Product 1'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(find.text('Product 1'), findsNothing);
  });
}
