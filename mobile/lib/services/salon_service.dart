import '../models/salon.dart';
import '../models/salon_kaydet.dart';
import 'api_service.dart';

/// Yönetici salon işlemleri. Token'ı ApiService'teki interceptor ekler;
/// API ekleme, güncelleme ve silmeyi sadece Yonetici rolüne açar.
class SalonService {
  final ApiService _api;

  SalonService(this._api);

  Future<List<Salon>> listele() async {
    try {
      final cevap = await _api.dio.get('/api/salonlar');
      final liste = cevap.data as List<dynamic>;
      return liste
          .map((e) => Salon.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  Future<Salon> getir(int id) async {
    try {
      final cevap = await _api.dio.get('/api/salonlar/$id');
      return Salon.fromJson(cevap.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  /// Başarılıysa API 201 Created ve oluşan salonu döner.
  Future<Salon> ekle(SalonKaydet salon) async {
    try {
      final cevap = await _api.dio.post('/api/salonlar', data: salon.toJson());
      return Salon.fromJson(cevap.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  Future<Salon> guncelle(int id, SalonKaydet salon) async {
    try {
      final cevap =
          await _api.dio.put('/api/salonlar/$id', data: salon.toJson());
      return Salon.fromJson(cevap.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }

  /// API 204 döner. Salonun rezervasyonu varsa 409 gelir; mesajı ApiHatasi taşır.
  Future<void> sil(int id) async {
    try {
      await _api.dio.delete('/api/salonlar/$id');
    } catch (e) {
      throw ApiService.hataCevir(e);
    }
  }
}
