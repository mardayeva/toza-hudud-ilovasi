import 'package:flutter_test/flutter_test.dart';
import 'package:chiqindi_nav/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // App ni ishga tushiramiz
    await tester.pumpWidget(const ChiqindiNavApp());

    // Tekshiramiz — app yuklandi
    expect(find.byType(ChiqindiNavApp), findsOneWidget);
  });
}
