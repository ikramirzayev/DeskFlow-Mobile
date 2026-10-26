using System.Security.Claims;
using DeskFlow.Api.Dtos;
using DeskFlow.Api.Models;
using DeskFlow.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace DeskFlow.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<Kullanici> _userManager;
    private readonly TokenServisi _tokenServisi;

    public AuthController(UserManager<Kullanici> userManager, TokenServisi tokenServisi)
    {
        _userManager = userManager;
        _tokenServisi = tokenServisi;
    }

    // POST /api/auth/kayit
    [HttpPost("kayit")]
    public async Task<ActionResult<TokenDto>> Kayit(KayitDto dto)
    {
        var kullanici = new Kullanici
        {
            UserName = dto.Email,
            Email = dto.Email,
            Ad = dto.Ad,
            Soyad = dto.Soyad,
            OgrenciNo = dto.OgrenciNo
        };

        var sonuc = await _userManager.CreateAsync(kullanici, dto.Sifre);
        if (!sonuc.Succeeded)
        {
            foreach (var hata in sonuc.Errors)
            {
                ModelState.AddModelError(hata.Code, hata.Description);
            }
            return ValidationProblem(ModelState);
        }

        await _userManager.AddToRoleAsync(kullanici, Roller.Ogrenci);

        var roller = await _userManager.GetRolesAsync(kullanici);
        return Ok(_tokenServisi.Olustur(kullanici, roller));
    }

    // POST /api/auth/giris
    [HttpPost("giris")]
    public async Task<ActionResult<TokenDto>> Giris(GirisDto dto)
    {
        var kullanici = await _userManager.FindByEmailAsync(dto.Email);
        if (kullanici is null || !await _userManager.CheckPasswordAsync(kullanici, dto.Sifre))
        {
            return Unauthorized(new { mesaj = "E-posta veya şifre hatalı." });
        }

        var roller = await _userManager.GetRolesAsync(kullanici);
        return Ok(_tokenServisi.Olustur(kullanici, roller));
    }

    // GET /api/auth/ben  (Authorization: Bearer <token>)
    [Authorize]
    [HttpGet("ben")]
    public async Task<IActionResult> Ben()
    {
        var id = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var kullanici = id is null ? null : await _userManager.FindByIdAsync(id);
        if (kullanici is null)
        {
            return Unauthorized();
        }

        var roller = await _userManager.GetRolesAsync(kullanici);
        return Ok(new
        {
            kullanici.Id,
            kullanici.Email,
            kullanici.Ad,
            kullanici.Soyad,
            kullanici.OgrenciNo,
            Roller = roller
        });
    }
}
