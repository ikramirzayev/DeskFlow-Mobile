import '../models/masa.dart';
import '../models/masa_kaydet.dart';
import 'api_service.dart';

/// Yönetici masa işlemleri. Token'ı ApiService'teki interceptor ekler;
/// API ekleme, güncelleme ve silmeyi sadece Yonetici rolüne açar.
class MasaService {
  final ApiService _api;

  MasaService(this._api);

  /// [salonId] verilirse sadece o salonun masaları gelir. Kapalı (pasif) masalar da döner.
  Future<List<Masa>> listele({int? salonId}) async {
    try {
      final cevap = await _api.dio.get(
        '/api/masalar',
        queryParameters: {if (salonId != null) 'salonId': salonId},
      );
      final liste = cevap.data as List<dynamic>;
      return liste
          .map((e) => Masa.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  /// Başarılıysa API 201 Created ve oluşan masayı döner.
  /// Aynı salonda aynı masa numarası varsa 400 gelir.
  Future<Masa> ekle(MasaKaydet masa) async {
    try {
      final cevap = await _api.dio.post('/api/masalar', data: masa.toJson());
      return Masa.fromJson(cevap.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  Future<Masa> guncelle(int id, MasaKaydet masa) async {
    try {
      final cevap = await _api.dio.put('/api/masalar/$id', data: masa.toJson());
      return Masa.fromJson(cevap.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  /// API 204 döner. Masanın rezervasyonu varsa 409 gelir; mesajı ApiHatasi taşır.
  Future<void> sil(int id) async {
    try {
      await _api.dio.delete('/api/masalar/$id');
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }
}
