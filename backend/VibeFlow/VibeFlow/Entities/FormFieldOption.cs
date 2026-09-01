namespace VibeFlow.Entities;

public class FormFieldOption
{
    public int Id { get; set; }
    public string FormFieldId { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public int Order { get; set; }

    public FormField FormField { get; set; } = null!;
}