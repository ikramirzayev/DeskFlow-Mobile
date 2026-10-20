import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/app.dart';

void main() {
  testWidgets('Ana ekran DeskFlow başlığını gösterir', (tester) async {
    await tester.pumpWidget(const DeskFlowApp());

    expect(find.text('DeskFlow'), findsWidgets);
  });
}
