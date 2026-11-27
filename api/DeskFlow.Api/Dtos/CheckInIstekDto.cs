using System.ComponentModel.DataAnnotations;

namespace DeskFlow.Api.Dtos;

public class CheckInIstekDto
{
    [Required(ErrorMessage = "QR kod zorunludur.")]
    [StringLength(200)]
    public string QrKod { get; set; } = string.Empty;
}
