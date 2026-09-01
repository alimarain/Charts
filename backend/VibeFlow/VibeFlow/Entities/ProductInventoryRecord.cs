namespace VibeFlow.Entities;

public class ProductInventoryRecord
{
    public int Id { get; set; }
    public string Category { get; set; } = string.Empty;
    public int UnitCount { get; set; }
}