using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using VibeFlow.Entities;

namespace VibeFlow.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

        // 1. Roles
        string[] roles = ["user", "maker"];
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole(role));
            }
        }

        // 2. Users
        if (await userManager.FindByEmailAsync("user@example.com") == null)
        {
            var normalUser = new ApplicationUser
            {
                UserName = "user@example.com",
                Email = "user@example.com",
                FirstName = "Normal",
                LastName = "User",
                EmailConfirmed = true
            };
            var result = await userManager.CreateAsync(normalUser, "User@123");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(normalUser, "user");
            }
        }

        if (await userManager.FindByEmailAsync("maker@example.com") == null)
        {
            var makerUser = new ApplicationUser
            {
                UserName = "maker@example.com",
                Email = "maker@example.com",
                FirstName = "Lead",
                LastName = "Maker",
                EmailConfirmed = true
            };
            var result = await userManager.CreateAsync(makerUser, "Maker@123");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(makerUser, "maker");
            }
        }

        // 3. Products, Forms & Dynamic Fields
        if (!await context.Products.AnyAsync())
        {
            var loanProduct = new Product
            {
                Id = "prod-finance-001",
                Name = "Personal Finance",
                Description = "Fast-track personal credit facility with flexible tenures.",
                Category = "Finance",
                ImageUrl = "[https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=500&auto=format&fit=crop&q=60](https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=500&auto=format&fit=crop&q=60)",
                Status = "active"
            };

            var autoLoanProduct = new Product
            {
                Id = "prod-auto-002",
                Name = "Auto Loan",
                Description = "Commercial and private vehicle asset financing.",
                Category = "Vehicle",
                ImageUrl = "[https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=500&auto=format&fit=crop&q=60](https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=500&auto=format&fit=crop&q=60)",
                Status = "active"
            };

            var homeFinProduct = new Product
            {
                Id = "prod-home-003",
                Name = "Home Mortgage",
                Description = "Residential property acquisition and construction.",
                Category = "Real Estate",
                ImageUrl = "[https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=500&auto=format&fit=crop&q=60](https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=500&auto=format&fit=crop&q=60)",
                Status = "active"
            };

            var personalInfoForm = new Form
            {
                Id = "form-personal-info-01",
                ProductId = loanProduct.Id,
                Name = "Personal & KYC Details",
                Description = "Applicant identity verification and personal demographics.",
                Order = 1
            };

            var employmentForm = new Form
            {
                Id = "form-employment-02",
                ProductId = loanProduct.Id,
                Name = "Income & Employment",
                Description = "Financial stability and employer verification.",
                Order = 2
            };

            personalInfoForm.Fields.Add(new FormField
            {
                Id = "field-kyc-01",
                FormId = personalInfoForm.Id,
                Label = "Full Legal Name",
                Key = "fullName",
                Type = "text",
                Required = true,
                Order = 1
            });

            personalInfoForm.Fields.Add(new FormField
            {
                Id = "field-kyc-02",
                FormId = personalInfoForm.Id,
                Label = "Official Email",
                Key = "email",
                Type = "email",
                Required = true,
                Order = 2
            });

            personalInfoForm.Fields.Add(new FormField
            {
                Id = "field-kyc-03",
                FormId = personalInfoForm.Id,
                Label = "Age (Years)",
                Key = "age",
                Type = "number",
                Required = true,
                Order = 3
            });

            var cityField = new FormField
            {
                Id = "field-kyc-04",
                FormId = personalInfoForm.Id,
                Label = "Residential City",
                Key = "city",
                Type = "dropdown",
                Required = true,
                Order = 4
            };
            cityField.Options.Add(new FormFieldOption { Value = "Karachi", Label = "Karachi", Order = 1 });
            cityField.Options.Add(new FormFieldOption { Value = "Lahore", Label = "Lahore", Order = 2 });
            cityField.Options.Add(new FormFieldOption { Value = "Islamabad", Label = "Islamabad", Order = 3 });
            personalInfoForm.Fields.Add(cityField);

            var empTypeField = new FormField
            {
                Id = "field-emp-01",
                FormId = employmentForm.Id,
                Label = "Employment Type",
                Key = "employmentType",
                Type = "dropdown",
                Required = true,
                Order = 1
            };
            empTypeField.Options.Add(new FormFieldOption { Value = "Salaried", Label = "Salaried", Order = 1 });
            empTypeField.Options.Add(new FormFieldOption { Value = "Self Employed", Label = "Self Employed", Order = 2 });
            empTypeField.Options.Add(new FormFieldOption { Value = "Business Owner", Label = "Business Owner", Order = 3 });
            employmentForm.Fields.Add(empTypeField);

            employmentForm.Fields.Add(new FormField
            {
                Id = "field-emp-02",
                FormId = employmentForm.Id,
                Label = "Monthly Net Income (PKR)",
                Key = "monthlyIncome",
                Type = "number",
                Required = true,
                Order = 2
            });

            loanProduct.Forms.Add(personalInfoForm);
            loanProduct.Forms.Add(employmentForm);

            await context.Products.AddRangeAsync(loanProduct, autoLoanProduct, homeFinProduct);
            await context.SaveChangesAsync();
        }

        // 4. Analytics Data
        if (!await context.SalesRecords.AnyAsync())
        {
            await context.SalesRecords.AddRangeAsync(
                new SalesRecord { Label = "Mon", Value = 145000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow.AddDays(-6) },
                new SalesRecord { Label = "Tue", Value = 182000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow.AddDays(-5) },
                new SalesRecord { Label = "Wed", Value = 165000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow.AddDays(-4) },
                new SalesRecord { Label = "Thu", Value = 210000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow.AddDays(-3) },
                new SalesRecord { Label = "Fri", Value = 245000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow.AddDays(-2) },
                new SalesRecord { Label = "Sat", Value = 290000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow.AddDays(-1) },
                new SalesRecord { Label = "Sun", Value = 315000, PeriodOffsetDays = 0, RecordedDate = DateTime.UtcNow }
            );

            await context.CategorySalesRecords.AddRangeAsync(
                new CategorySalesRecord { Category = "Personal Finance", Sales = 620000 },
                new CategorySalesRecord { Category = "Auto Loan", Sales = 480000 },
                new CategorySalesRecord { Category = "Home Mortgage", Sales = 350000 },
                new CategorySalesRecord { Category = "SME Credit", Sales = 190000 }
            );

            await context.ProductInventoryRecords.AddRangeAsync(
                new ProductInventoryRecord { Category = "Active", UnitCount = 148 },
                new ProductInventoryRecord { Category = "In Review", UnitCount = 52 },
                new ProductInventoryRecord { Category = "Approved", UnitCount = 89 },
                new ProductInventoryRecord { Category = "Disbursed", UnitCount = 112 }
            );

            await context.SaveChangesAsync();
        }
    }
}