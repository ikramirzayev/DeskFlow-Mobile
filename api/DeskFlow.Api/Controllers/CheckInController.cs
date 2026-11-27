using System.Security.Claims;
using DeskFlow.Api.Data;
using DeskFlow.Api.Dtos;
using DeskFlow.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DeskFlow.Api.Controllers;

[ApiController]
[Route("api/checkin")]
[Authorize]
public class CheckInController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly CheckInServisi _servis;

    public CheckInController(AppDbContext db, CheckInServisi servis)
    {
        _db = db;
        _servis = servis;
    }

    // POST /api/checkin  { "qrKod": "DF-S1-M03" }
    // Tamam -> 200 (rezervasyon bilgisi), MasaBulunamadi / RezervasyonYok -> 404,
    // ErkenGeldi / GecKaldi -> 400. Hata cevapları { "mesaj": "..." } biçimindedir.
    [HttpPost]
    public async Task<IActionResult> CheckIn(CheckInIstekDto dto)
    {
        var kullaniciId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var sonuc = await _servis.CheckInYapAsync(kullaniciId, dto.QrKod);

        if (!sonuc.Basarili)
        {
            var hata = new { mesaj = sonuc.Mesaj };
            return sonuc.Durum switch
            {
                CheckInDurumu.MasaBulunamadi or CheckInDurumu.RezervasyonYok => NotFound(hata),
                _ => BadRequest(hata)
            };
        }

        var kayit = await _db.Rezervasyonlar
            .AsNoTracking()
            .Include(r => r.Masa).ThenInclude(m => m.Salon)
            .FirstAsync(r => r.Id == sonuc.Rezervasyon!.Id);

        return Ok(new RezervasyonDto
        {
            Id = kayit.Id,
            MasaId = kayit.MasaId,
            MasaNo = kayit.Masa.MasaNo,
            SalonId = kayit.Masa.SalonId,
            SalonAd = kayit.Masa.Salon.Ad,
            Kat = kayit.Masa.Salon.Kat,
            Baslangic = kayit.Baslangic.ToLocalTime(),
            Bitis = kayit.Bitis.ToLocalTime(),
            Durum = kayit.Durum.ToString(),
            IptalEdilebilir = RezervasyonServisi.IptalEdilebilirMi(kayit, DateTime.UtcNow)
        });
    }
}
