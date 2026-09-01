namespace VibeFlow.Entities;

public class Form
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string ProductId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Order { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Product Product { get; set; } = null!;
    public ICollection<FormField> Fields { get; set; } = new List<FormField>();
    public ICollection<ApplicationSubmission> Submissions { get; set; } = new List<ApplicationSubmission>();
}