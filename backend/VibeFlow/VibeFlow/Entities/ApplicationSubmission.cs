namespace VibeFlow.Entities;

public class ApplicationSubmission
{
    public string Id { get; set; } = Guid.NewGuid().ToString();
    public string FormId { get; set; } = string.Empty;
    public string SubmittedByUserId { get; set; } = string.Empty;
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
    public string Status { get; set; } = "Submitted";

    public Form Form { get; set; } = null!;
    public ApplicationUser SubmittedByUser { get; set; } = null!;
    public ICollection<ApplicationAnswer> Answers { get; set; } = new List<ApplicationAnswer>();
}