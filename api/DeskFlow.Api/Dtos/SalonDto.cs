namespace DeskFlow.Api.Dtos;

/// <summary>Salon listeleme / detay cevabı. Masa listesi yerine sadece masa sayısı döner.</summary>
public class SalonDto
{
    public int Id { get; set; }
    public string Ad { get; set; } = string.Empty;
    public int Kat { get; set; }
    public int Kapasite { get; set; }
    public TimeOnly AcilisSaati { get; set; }
    public TimeOnly KapanisSaati { get; set; }
    public bool AktifMi { get; set; }
    public int MasaSayisi { get; set; }
}
