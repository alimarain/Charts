using Microsoft.EntityFrameworkCore;
using VibeFlow.Data;
using VibeFlow.Entities;
using VibeFlow.Repositories.Interfaces;

namespace VibeFlow.Repositories.Implementations;

public class ProductRepository(ApplicationDbContext context) : IProductRepository
{
    public async Task<List<Product>> GetAllAsync() =>
        await context.Products.AsNoTracking().ToListAsync();

    public async Task<Product?> GetByIdAsync(string id) =>
        await context.Products.AsNoTracking().FirstOrDefaultAsync(p => p.Id == id);
}