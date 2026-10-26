using System.Text;
using DeskFlow.Api.Data;
using DeskFlow.Api.Models;
using DeskFlow.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddDbContext<AppDbContext>(o =>
    o.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services
    .AddIdentityCore<Kullanici>(o =>
    {
        o.Password.RequiredLength = 6;
        o.Password.RequireDigit = true;
        o.Password.RequireLowercase = true;
        o.Password.RequireUppercase = false;
        o.Password.RequireNonAlphanumeric = false;
        o.User.RequireUniqueEmail = true;
    })
    .AddRoles<IdentityRole>()
    .AddEntityFrameworkStores<AppDbContext>()
    .AddErrorDescriber<TurkceIdentityHatalari>();

var jwtAnahtari = builder.Configuration["Jwt:Key"];
if (string.IsNullOrWhiteSpace(jwtAnahtari) || jwtAnahtari.Length < 32)
{
    throw new InvalidOperationException(
        "Jwt:Key ayarlanmamış ya da 32 karakterden kısa. README'deki user-secrets adımına bakın.");
}

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o =>
    {
        o.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtAnahtari)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddScoped<TokenServisi>();

var app = builder.Build();

try
{
    await RolSeed.CalistirAsync(app.Services);
}
catch (Exception ex)
{
    app.Logger.LogWarning(ex, "Roller oluşturulamadı. Veritabanı hazır mı? (dotnet ef database update)");
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
