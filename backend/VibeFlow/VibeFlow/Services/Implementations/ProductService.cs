using VibeFlow.DTOs.Common;
using VibeFlow.DTOs.Products;
using VibeFlow.Repositories.Interfaces;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Services.Implementations;

public class ProductService(IProductRepository repository) : IProductService
{
    public async Task<ApiResponse<List<ProductResponseDto>>> GetAllProductsAsync()
    {
        var products = await repository.GetAllAsync();
        var dtos = products.Select(p => new ProductResponseDto(
            p.Id,
            p.Name,
            p.Description,
            p.ImageUrl,
            p.Category,
            p.Status
        )).ToList();

        return ApiResponse<List<ProductResponseDto>>.SuccessResult(dtos);
    }

    public async Task<ApiResponse<ProductResponseDto>> GetProductByIdAsync(string id)
    {
        var product = await repository.GetByIdAsync(id);
        if (product == null)
        {
            return ApiResponse<ProductResponseDto>.FailureResult($"Product '{id}' not found.");
        }

        var dto = new ProductResponseDto(
            product.Id,
            product.Name,
            product.Description,
            product.ImageUrl,
            product.Category,
            product.Status
        );

        return ApiResponse<ProductResponseDto>.SuccessResult(dto);
    }
}