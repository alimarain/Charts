using VibeFlow.DTOs.Common;
using VibeFlow.DTOs.Maker;

namespace VibeFlow.Services.Interfaces;

public interface IMakerService
{
    Task<ApiResponse<List<MakerProductDto>>> GetProductsAsync();
    Task<ApiResponse<List<MakerFormDto>>> GetFormsByProductAsync(string productId);
    Task<ApiResponse<List<FormFieldDto>>> GetFieldsByFormAsync(string formId);
    Task<ApiResponse<SubmitApplicationResponseDto>> SubmitApplicationAsync(
        string formId,
        string userId,
        SubmitApplicationRequestDto request
    );
}