import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/app.dart';
import 'package:deskflow_mobile/models/oturum.dart';
import 'package:deskflow_mobile/services/token_store.dart';

/// Testte telefonun şifreli deposu olmadığı için bellekte çalışan sahte depo.
class SahteTokenStore extends TokenStore {
  Oturum? _oturum;

  @override
  Future<void> kaydet(Oturum oturum) async => _oturum = oturum;

  @override
  Future<Oturum?> oku() async => _oturum;

  @override
  Future<void> sil() async => _oturum = null;
}

void main() {
  testWidgets('Açılış ekranı giriş ekranına geçer', (tester) async {
    await tester.pumpWidget(DeskFlowApp(tokenStore: SahteTokenStore()));
    expect(find.text('DeskFlow'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Giriş Yap'), findsWidgets);
  });

  testWidgets('Boş formda butona basınca hata mesajları görünür', (
    tester,
  ) async {
    await tester.pumpWidget(DeskFlowApp(tokenStore: SahteTokenStore()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
    await tester.pump();

    expect(find.text('E-posta boş olamaz'), findsOneWidget);
    expect(find.text('Şifre en az 6 karakter olmalı'), findsOneWidget);
  });
}