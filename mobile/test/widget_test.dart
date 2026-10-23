import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/app.dart';

void main() {
  testWidgets('Açılış ekranı ana iskelete geçer', (tester) async {
    await tester.pumpWidget(const DeskFlowApp());
    expect(find.text('DeskFlow'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Ana Sayfa'), findsOneWidget);
  });
}