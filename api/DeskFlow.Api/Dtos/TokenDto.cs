namespace DeskFlow.Api.Dtos;

public class TokenDto
{
    public string Token { get; set; } = string.Empty;
    public DateTime BitisZamani { get; set; }
    public string Email { get; set; } = string.Empty;
    public string AdSoyad { get; set; } = string.Empty;
    public List<string> Roller { get; set; } = new();
}
