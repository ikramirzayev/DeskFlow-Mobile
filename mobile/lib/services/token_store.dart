import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/oturum.dart';

/// Oturumu (JWT dahil) cihazda şifreli olarak saklar.
class TokenStore {
  static const _anahtar = 'deskflow_oturum';

  final FlutterSecureStorage _depo;

  TokenStore([FlutterSecureStorage? depo])
      : _depo = depo ?? const FlutterSecureStorage();

  Future<void> kaydet(Oturum oturum) {
    return _depo.write(key: _anahtar, value: jsonEncode(oturum.toJson()));
  }

  Future<Oturum?> oku() async {
    final metin = await _depo.read(key: _anahtar);
    if (metin == null) return null;
    return Oturum.fromJson(jsonDecode(metin) as Map<String, dynamic>);
  }

  Future<void> sil() => _depo.delete(key: _anahtar);
}
