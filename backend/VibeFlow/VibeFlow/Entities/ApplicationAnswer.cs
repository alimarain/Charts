namespace VibeFlow.Entities;

public class ApplicationAnswer
{
    public int Id { get; set; }
    public string ApplicationSubmissionId { get; set; } = string.Empty;
    public string FieldKey { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;

    public ApplicationSubmission ApplicationSubmission { get; set; } = null!;
}