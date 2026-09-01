namespace VibeFlow.Entities;

public class SalesRecord
{
    public int Id { get; set; }
    public string Label { get; set; } = string.Empty;
    public double Value { get; set; }
    public int PeriodOffsetDays { get; set; }
    public DateTime RecordedDate { get; set; }
}