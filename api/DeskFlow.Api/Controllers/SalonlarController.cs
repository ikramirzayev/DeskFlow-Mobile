using DeskFlow.Api.Data;
using DeskFlow.Api.Dtos;
using DeskFlow.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DeskFlow.Api.Controllers;

[ApiController]
[Route("api/salonlar")]
public class SalonlarController : ControllerBase
{
    private readonly AppDbContext _db;

    public SalonlarController(AppDbContext db)
    {
        _db = db;
    }

    // GET /api/salonlar  (giriş yapmış herkes)
    [Authorize]
    [HttpGet]
    public async Task<ActionResult<List<SalonDto>>> Listele()
    {
        var salonlar = await _db.Salonlar
            .AsNoTracking()
            .OrderBy(s => s.Kat)
            .ThenBy(s => s.Ad)
            .Select(s => new SalonDto
            {
                Id = s.Id,
                Ad = s.Ad,
                Kat = s.Kat,
                Kapasite = s.Kapasite,
                AcilisSaati = s.AcilisSaati,
                KapanisSaati = s.KapanisSaati,
                AktifMi = s.AktifMi,
                MasaSayisi = s.Masalar.Count
            })
            .ToListAsync();

        return Ok(salonlar);
    }

    // GET /api/salonlar/5  (giriş yapmış herkes)
    [Authorize]
    [HttpGet("{id:int}")]
    public async Task<ActionResult<SalonDto>> Getir(int id)
    {
        var salon = await _db.Salonlar
            .AsNoTracking()
            .Where(s => s.Id == id)
            .Select(s => new SalonDto
            {
                Id = s.Id,
                Ad = s.Ad,
                Kat = s.Kat,
                Kapasite = s.Kapasite,
                AcilisSaati = s.AcilisSaati,
                KapanisSaati = s.KapanisSaati,
                AktifMi = s.AktifMi,
                MasaSayisi = s.Masalar.Count
            })
            .FirstOrDefaultAsync();

        if (salon is null)
        {
            return NotFound(new { mesaj = "Salon bulunamadı." });
        }

        return Ok(salon);
    }

    // POST /api/salonlar  (sadece yönetici) -> 201 Created
    [Authorize(Roles = Roller.Yonetici)]
    [HttpPost]
    public async Task<ActionResult<SalonDto>> Ekle(SalonKaydetDto dto)
    {
        var salon = new Salon
        {
            Ad = dto.Ad.Trim(),
            Kat = dto.Kat,
            Kapasite = dto.Kapasite,
            AcilisSaati = dto.AcilisSaati,
            KapanisSaati = dto.KapanisSaati,
            AktifMi = dto.AktifMi
        };

        _db.Salonlar.Add(salon);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(Getir), new { id = salon.Id }, DtoyaCevir(salon, 0));
    }

    // PUT /api/salonlar/5  (sadece yönetici)
    [Authorize(Roles = Roller.Yonetici)]
    [HttpPut("{id:int}")]
    public async Task<ActionResult<SalonDto>> Guncelle(int id, SalonKaydetDto dto)
    {
        var salon = await _db.Salonlar.FirstOrDefaultAsync(s => s.Id == id);
        if (salon is null)
        {
            return NotFound(new { mesaj = "Salon bulunamadı." });
        }

        salon.Ad = dto.Ad.Trim();
        salon.Kat = dto.Kat;
        salon.Kapasite = dto.Kapasite;
        salon.AcilisSaati = dto.AcilisSaati;
        salon.KapanisSaati = dto.KapanisSaati;
        salon.AktifMi = dto.AktifMi;

        await _db.SaveChangesAsync();

        var masaSayisi = await _db.Masalar.CountAsync(m => m.SalonId == id);
        return Ok(DtoyaCevir(salon, masaSayisi));
    }

    // DELETE /api/salonlar/5  (sadece yönetici) -> 204 No Content
    [Authorize(Roles = Roller.Yonetici)]
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Sil(int id)
    {
        var salon = await _db.Salonlar.FirstOrDefaultAsync(s => s.Id == id);
        if (salon is null)
        {
            return NotFound(new { mesaj = "Salon bulunamadı." });
        }

        // Rezervasyon kayıtları korunur: rezervasyonu olan masaların salonu silinemez.
        var rezervasyonVar = await _db.Rezervasyonlar.AnyAsync(r => r.Masa.SalonId == id);
        if (rezervasyonVar)
        {
            return Conflict(new { mesaj = "Bu salonun masalarına ait rezervasyonlar olduğu için salon silinemez." });
        }

        _db.Salonlar.Remove(salon); // salona bağlı masalar da silinir (cascade)
        await _db.SaveChangesAsync();

        return NoContent();
    }

    private static SalonDto DtoyaCevir(Salon s, int masaSayisi) => new()
    {
        Id = s.Id,
        Ad = s.Ad,
        Kat = s.Kat,
        Kapasite = s.Kapasite,
        AcilisSaati = s.AcilisSaati,
        KapanisSaati = s.KapanisSaati,
        AktifMi = s.AktifMi,
        MasaSayisi = masaSayisi
    };
}
