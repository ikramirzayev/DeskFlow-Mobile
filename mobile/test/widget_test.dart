import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/app.dart';

void main() {
  testWidgets('Açılış ekranı giriş ekranına geçer', (tester) async {
    await tester.pumpWidget(const DeskFlowApp());
    expect(find.text('DeskFlow'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Giriş Yap'), findsWidgets);
  });

  testWidgets('Boş formda butona basınca hata mesajları görünür', (
    tester,
  ) async {
    await tester.pumpWidget(const DeskFlowApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
    await tester.pump();

    expect(find.text('E-posta boş olamaz'), findsOneWidget);
    expect(find.text('Şifre en az 6 karakter olmalı'), findsOneWidget);
  });
}
