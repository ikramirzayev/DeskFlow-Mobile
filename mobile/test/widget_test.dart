import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deskflow_mobile/app.dart';
import 'package:deskflow_mobile/models/oturum.dart';
import 'package:deskflow_mobile/services/api_service.dart';
import 'package:deskflow_mobile/services/token_store.dart';

/// Testte telefonun şifreli deposu olmadığı için bellekte çalışan sahte depo.
class SahteTokenStore extends TokenStore {
  SahteTokenStore([this._oturum]);

  Oturum? _oturum;

  @override
  Future<void> kaydet(Oturum oturum) async => _oturum = oturum;

  @override
  Future<Oturum?> oku() async => _oturum;

  @override
  Future<void> sil() async => _oturum = null;
}

/// Gerçek sunucuya gitmeden her isteğe boş liste dönen sahte bağlantı.
class SahteAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '[]',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Oturum oturum(List<String> roller) => Oturum(
      token: 'test-token',
      bitisZamani: DateTime.utc(2099),
      email: 'test@deskflow.local',
      adSoyad: 'Test Kullanıcı',
      roller: roller,
    );

ApiService sahteApi() =>
    ApiService(dio: Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = SahteAdapter());

Future<void> acilisiBekle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Açılış ekranı giriş ekranına geçer', (tester) async {
    await tester.pumpWidget(DeskFlowApp(tokenStore: SahteTokenStore()));
    expect(find.text('DeskFlow'), findsWidgets);

    await acilisiBekle(tester);
    expect(find.text('Giriş Yap'), findsWidgets);
  });

  testWidgets('Boş formda butona basınca hata mesajları görünür', (
    tester,
  ) async {
    await tester.pumpWidget(DeskFlowApp(tokenStore: SahteTokenStore()));
    await acilisiBekle(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
    await tester.pump();

    expect(find.text('E-posta boş olamaz'), findsOneWidget);
    expect(find.text('Şifre en az 6 karakter olmalı'), findsOneWidget);
  });

  testWidgets('Öğrenci 3 sekme görür, Yönetim sekmesi yoktur', (tester) async {
    await tester.pumpWidget(DeskFlowApp(
      tokenStore: SahteTokenStore(oturum(['Ogrenci'])),
      apiService: sahteApi(),
    ));
    await acilisiBekle(tester);

    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Yönetim'), findsNothing);
  });

  testWidgets('Yönetici 4 sekme görür ve Yönetim sekmesine girebilir', (
    tester,
  ) async {
    await tester.pumpWidget(DeskFlowApp(
      tokenStore: SahteTokenStore(oturum(['Yonetici'])),
      apiService: sahteApi(),
    ));
    await acilisiBekle(tester);

    expect(find.byType(NavigationDestination), findsNWidgets(4));

    await tester.tap(find.text('Yönetim'));
    await tester.pumpAndSettle();

    expect(find.text('Salon Yönetimi'), findsOneWidget);
    expect(find.text('Masa Yönetimi'), findsOneWidget);
  });
}
