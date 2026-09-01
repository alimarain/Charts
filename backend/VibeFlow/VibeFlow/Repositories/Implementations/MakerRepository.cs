    using Microsoft.EntityFrameworkCore;
    using VibeFlow.Data;
    using VibeFlow.Entities;
    using VibeFlow.Repositories.Interfaces;

    namespace VibeFlow.Repositories.Implementations;

    public class MakerRepository(ApplicationDbContext context) : IMakerRepository
    {
        public async Task<List<Product>> GetMakerProductsWithFormCountsAsync() =>
            await context.Products
                .Include(p => p.Forms)
                .AsNoTracking()
                .ToListAsync();

        public async Task<List<Form>> GetFormsByProductIdAsync(string productId) =>
            await context.Forms
                .Where(f => f.ProductId == productId)
                .Include(f => f.Fields)
                .AsNoTracking()
                .ToListAsync();

        public async Task<Form?> GetFormWithFieldsAsync(string formId) =>
            await context.Forms
                .Include(f => f.Fields)
                    .ThenInclude(ff => ff.Options)
                .FirstOrDefaultAsync(f => f.Id == formId);

        public async Task<string> SubmitApplicationTransactionAsync(
            ApplicationSubmission submission,
            List<ApplicationAnswer> answers)
        {
            await using var transaction = await context.Database.BeginTransactionAsync();
            try
            {
                await context.ApplicationSubmissions.AddAsync(submission);
                await context.SaveChangesAsync();

                foreach (var answer in answers)
                {
                    answer.ApplicationSubmissionId = submission.Id;
                }
                await context.ApplicationAnswers.AddRangeAsync(answers);
                await context.SaveChangesAsync();

                await transaction.CommitAsync();
                return submission.Id;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
    }