using System.ComponentModel.DataAnnotations;

namespace DeskFlow.Api.Dtos;

public class KayitDto
{
    [Required(ErrorMessage = "Ad zorunludur.")]
    [StringLength(50)]
    public string Ad { get; set; } = string.Empty;

    [Required(ErrorMessage = "Soyad zorunludur.")]
    [StringLength(50)]
    public string Soyad { get; set; } = string.Empty;

    [Required(ErrorMessage = "Öğrenci numarası zorunludur.")]
    [RegularExpression(@"^\d{8,11}$", ErrorMessage = "Öğrenci numarası 8–11 haneli bir sayı olmalıdır.")]
    public string OgrenciNo { get; set; } = string.Empty;

    [Required(ErrorMessage = "E-posta zorunludur.")]
    [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi girin.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Şifre zorunludur.")]
    [StringLength(100, MinimumLength = 6, ErrorMessage = "Şifre en az 6 karakter olmalıdır.")]
    public string Sifre { get; set; } = string.Empty;
}
