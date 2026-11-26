import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:deskflow_mobile/services/api_service.dart';

/// Gerçek sunucuya gitmeden: giden isteği kaydeder, verilen cevabı döner.
class KaydedenAdapter implements HttpClientAdapter {
  KaydedenAdapter(this.durumKodu, this.cevap);

  final int durumKodu;
  final Object cevap;
  RequestOptions? sonIstek;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sonIstek = options;
    return ResponseBody.fromString(
      jsonEncode(cevap),
      durumKodu,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiService apiIle(HttpClientAdapter adapter) =>
    ApiService(dio: Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter);
