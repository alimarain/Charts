using VibeFlow.DTOs.Common;
using VibeFlow.DTOs.Products;

namespace VibeFlow.Services.Interfaces;

public interface IProductService
{
    Task<ApiResponse<List<ProductResponseDto>>> GetAllProductsAsync();
    Task<ApiResponse<ProductResponseDto>> GetProductByIdAsync(string id);
}