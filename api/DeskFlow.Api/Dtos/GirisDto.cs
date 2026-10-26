using System.ComponentModel.DataAnnotations;

namespace DeskFlow.Api.Dtos;

public class GirisDto
{
    [Required(ErrorMessage = "E-posta zorunludur.")]
    [EmailAddress(ErrorMessage = "Geçerli bir e-posta adresi girin.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Şifre zorunludur.")]
    public string Sifre { get; set; } = string.Empty;
}
