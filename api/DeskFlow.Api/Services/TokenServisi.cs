using System.Security.Claims;
using System.Text;
using DeskFlow.Api.Dtos;
using DeskFlow.Api.Models;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace DeskFlow.Api.Services;

public class TokenServisi
{
    private readonly IConfiguration _ayarlar;

    public TokenServisi(IConfiguration ayarlar)
    {
        _ayarlar = ayarlar;
    }

    public TokenDto Olustur(Kullanici kullanici, IList<string> roller)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, kullanici.Id),
            new(ClaimTypes.Email, kullanici.Email ?? string.Empty),
            new(ClaimTypes.Name, $"{kullanici.Ad} {kullanici.Soyad}")
        };
        claims.AddRange(roller.Select(rol => new Claim(ClaimTypes.Role, rol)));

        var anahtar = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_ayarlar["Jwt:Key"]!));
        var bitis = DateTime.UtcNow.AddMinutes(_ayarlar.GetValue("Jwt:SureDakika", 120));

        var tanim = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Issuer = _ayarlar["Jwt:Issuer"],
            Audience = _ayarlar["Jwt:Audience"],
            Expires = bitis,
            SigningCredentials = new SigningCredentials(anahtar, SecurityAlgorithms.HmacSha256)
        };

        return new TokenDto
        {
            Token = new JsonWebTokenHandler().CreateToken(tanim),
            BitisZamani = bitis,
            Email = kullanici.Email ?? string.Empty,
            AdSoyad = $"{kullanici.Ad} {kullanici.Soyad}",
            Roller = roller.ToList()
        };
    }
}
