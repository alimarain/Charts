namespace VibeFlow.Entities;

public class FormField
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string FormId { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public string Key { get; set; } = string.Empty;
    public string Type { get; set; } = "text";
    public bool Required { get; set; }
    public int Order { get; set; }

    public Form Form { get; set; } = null!;
    public ICollection<FormFieldOption> Options { get; set; } = new List<FormFieldOption>();
}