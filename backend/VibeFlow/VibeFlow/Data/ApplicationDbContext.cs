using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using VibeFlow.Entities;

namespace VibeFlow.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<Product> Products => Set<Product>();
    public DbSet<Form> Forms => Set<Form>();
    public DbSet<FormField> FormFields => Set<FormField>();
    public DbSet<FormFieldOption> FormFieldOptions => Set<FormFieldOption>();
    public DbSet<ApplicationSubmission> ApplicationSubmissions => Set<ApplicationSubmission>();
    public DbSet<ApplicationAnswer> ApplicationAnswers => Set<ApplicationAnswer>();
    public DbSet<SalesRecord> SalesRecords => Set<SalesRecord>();
    public DbSet<CategorySalesRecord> CategorySalesRecords => Set<CategorySalesRecord>();
    public DbSet<ProductInventoryRecord> ProductInventoryRecords => Set<ProductInventoryRecord>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<Product>(b =>
        {
            b.HasKey(p => p.Id);
            b.Property(p => p.Name).HasMaxLength(150).IsRequired();
            b.Property(p => p.Category).HasMaxLength(80).IsRequired();
            b.HasMany(p => p.Forms)
             .WithOne(f => f.Product)
             .HasForeignKey(f => f.ProductId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<Form>(b =>
        {
            b.HasKey(f => f.Id);
            b.Property(f => f.Name).HasMaxLength(150).IsRequired();
            b.HasMany(f => f.Fields)
             .WithOne(ff => ff.Form)
             .HasForeignKey(ff => ff.FormId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<FormField>(b =>
        {
            b.HasKey(ff => ff.Id);
            b.Property(ff => ff.Key).HasMaxLength(80).IsRequired();
            b.Property(ff => ff.Type).HasMaxLength(50).IsRequired();
            b.HasMany(ff => ff.Options)
             .WithOne(o => o.FormField)
             .HasForeignKey(o => o.FormFieldId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<ApplicationSubmission>(b =>
        {
            b.HasKey(s => s.Id);
            b.HasOne(s => s.Form)
             .WithMany(f => f.Submissions)
             .HasForeignKey(s => s.FormId)
             .OnDelete(DeleteBehavior.Restrict);

            b.HasOne(s => s.SubmittedByUser)
             .WithMany()
             .HasForeignKey(s => s.SubmittedByUserId)
             .OnDelete(DeleteBehavior.Restrict);

            b.HasMany(s => s.Answers)
             .WithOne(a => a.ApplicationSubmission)
             .HasForeignKey(a => a.ApplicationSubmissionId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<ApplicationAnswer>(b =>
        {
            b.HasKey(a => a.Id);
            b.Property(a => a.FieldKey).HasMaxLength(80).IsRequired();
            b.Property(a => a.Value).HasMaxLength(4000).IsRequired();
        });
    }
}