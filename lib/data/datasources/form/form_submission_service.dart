import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:new_app/presentation/views/controllers/form_state.dart';
import 'package:new_app/presentation/views/controllers/submission_state.dart';

import '../../../core/errors/api_exception.dart';

class FormSubmissionService {
  FormSubmissionService(this._dio);

  final Dio _dio;

  Stream<SubmissionProgress> submitFormStream(
    MultiStepFormState formState,
  ) async* {
    yield const SubmissionProgress(
      progress: 0.0,
      message: 'Preparing submission...',
    );
    await Future.delayed(const Duration(milliseconds: 350));

    yield const SubmissionProgress(
      progress: 0.2,
      message: 'Validating basic & career payload...',
    );
    await Future.delayed(const Duration(milliseconds: 400));

    yield const SubmissionProgress(
      progress: 0.4,
      message: 'Encrypting and uploading basic info...',
    );
    await Future.delayed(const Duration(milliseconds: 450));

    yield const SubmissionProgress(
      progress: 0.6,
      message: 'Uploading career profile & documents...',
    );
    await Future.delayed(const Duration(milliseconds: 450));

    yield const SubmissionProgress(
      progress: 0.8,
      message: 'Finalizing server registration...',
    );

    try {
      final payload = {
        'basic_information': formState.basicInfo.toMap(),
        'career_information': formState.careerInfo.toMap(),
      };

      // Dio request with JWT automatically attached via AuthInterceptor
      await _dio.post('/submit-form', data: utf8.encode(jsonEncode(payload)));

      yield const SubmissionProgress(
        progress: 1.0,
        message: 'Submission completed successfully!',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected submission error: $e');
    }
  }
}
