using System.ComponentModel.DataAnnotations;

namespace DeskFlow.Api.Dtos;

/// <summary>Salon ekleme ve güncelleme isteği.</summary>
public class SalonKaydetDto : IValidatableObject
{
    [Required(ErrorMessage = "Salon adı zorunludur.")]
    [StringLength(100, ErrorMessage = "Salon adı en fazla 100 karakter olabilir.")]
    public string Ad { get; set; } = string.Empty;

    [Range(-2, 20, ErrorMessage = "Kat -2 ile 20 arasında olmalıdır.")]
    public int Kat { get; set; }

    [Range(1, 1000, ErrorMessage = "Kapasite 1 ile 1000 arasında olmalıdır.")]
    public int Kapasite { get; set; }

    public TimeOnly AcilisSaati { get; set; }

    public TimeOnly KapanisSaati { get; set; }

    public bool AktifMi { get; set; } = true;

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (KapanisSaati <= AcilisSaati)
        {
            yield return new ValidationResult(
                "Kapanış saati açılış saatinden sonra olmalıdır.",
                new[] { nameof(KapanisSaati) });
        }
    }
}
