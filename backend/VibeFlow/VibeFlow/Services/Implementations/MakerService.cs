using VibeFlow.DTOs.Common;
using VibeFlow.DTOs.Maker;
using VibeFlow.Entities;
using VibeFlow.Repositories.Interfaces;
using VibeFlow.Services.Interfaces;

namespace VibeFlow.Services.Implementations;

public class MakerService(IMakerRepository repository) : IMakerService
{
    public async Task<ApiResponse<List<MakerProductDto>>> GetProductsAsync()
    {
        var products = await repository.GetMakerProductsWithFormCountsAsync();
        var dtos = products.Select(p => new MakerProductDto(
            p.Id,
            p.Name,
            p.Description,
            p.ImageUrl,
            p.Category,
            p.Status,
            p.Forms.Count
        )).ToList();

        return ApiResponse<List<MakerProductDto>>.SuccessResult(dtos, "Maker products retrieved successfully.");
    }

    public async Task<ApiResponse<List<MakerFormDto>>> GetFormsByProductAsync(string productId)
    {
        var forms = await repository.GetFormsByProductIdAsync(productId);
        var dtos = forms.Select(f => new MakerFormDto(
            f.Id,
            f.Name,
            f.Description,
            f.Fields.Count
        )).ToList();

        return ApiResponse<List<MakerFormDto>>.SuccessResult(dtos, "Forms retrieved successfully.");
    }

    public async Task<ApiResponse<List<FormFieldDto>>> GetFieldsByFormAsync(string formId)
    {
        var form = await repository.GetFormWithFieldsAsync(formId);
        if (form == null)
        {
            return ApiResponse<List<FormFieldDto>>.FailureResult($"Form '{formId}' not found.");
        }

        var dtos = form.Fields
            .OrderBy(f => f.Order)
            .Select(f => new FormFieldDto(
                f.Id,
                f.Label,
                f.Key,
                f.Type,
                f.Required,
                f.Options.OrderBy(o => o.Order).Select(o => o.Value).ToList()
            )).ToList();

        return ApiResponse<List<FormFieldDto>>.SuccessResult(dtos, "Fields retrieved successfully.");
    }

    public async Task<ApiResponse<SubmitApplicationResponseDto>> SubmitApplicationAsync(
        string formId,
        string userId,
        SubmitApplicationRequestDto request)
    {
        var form = await repository.GetFormWithFieldsAsync(formId);
        if (form == null)
        {
            return ApiResponse<SubmitApplicationResponseDto>.FailureResult($"Form with ID '{formId}' not found.");
        }

        var answersToPersist = new List<ApplicationAnswer>();

        foreach (var field in form.Fields)
        {
            request.Answers.TryGetValue(field.Key, out var submittedValueObj);
            var submittedValStr = submittedValueObj?.ToString()?.Trim() ?? string.Empty;

            if (field.Required && string.IsNullOrEmpty(submittedValStr))
            {
                return ApiResponse<SubmitApplicationResponseDto>.FailureResult(
                    $"Field '{field.Label}' ({field.Key}) is required."
                );
            }

            if (!string.IsNullOrEmpty(submittedValStr) &&
                (field.Type.Equals("dropdown", StringComparison.OrdinalIgnoreCase) ||
                 field.Type.Equals("radio", StringComparison.OrdinalIgnoreCase)))
            {
                var allowedOptions = field.Options.Select(o => o.Value).ToHashSet(StringComparer.OrdinalIgnoreCase);
                if (!allowedOptions.Contains(submittedValStr))
                {
                    return ApiResponse<SubmitApplicationResponseDto>.FailureResult(
                        $"Value '{submittedValStr}' is invalid for field '{field.Label}'. Allowed: {string.Join(", ", allowedOptions)}"
                    );
                }
            }

            if (!string.IsNullOrEmpty(submittedValStr) && field.Type.Equals("number", StringComparison.OrdinalIgnoreCase))
            {
                if (!double.TryParse(submittedValStr, out _))
                {
                    return ApiResponse<SubmitApplicationResponseDto>.FailureResult(
                        $"Field '{field.Label}' must be a valid number."
                    );
                }
            }

            if (!string.IsNullOrEmpty(submittedValStr))
            {
                answersToPersist.Add(new ApplicationAnswer
                {
                    FieldKey = field.Key,
                    Value = submittedValStr
                });
            }
        }

        var submission = new ApplicationSubmission
        {
            FormId = formId,
            SubmittedByUserId = userId,
            SubmittedAt = DateTime.UtcNow,
            Status = "Submitted"
        };

        var applicationId = await repository.SubmitApplicationTransactionAsync(submission, answersToPersist);

        return ApiResponse<SubmitApplicationResponseDto>.SuccessResult(
            new SubmitApplicationResponseDto(applicationId),
            "Application submitted successfully."
        );
    }
}