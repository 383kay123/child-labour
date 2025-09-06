import 'package:dio/dio.dart';
import '../db/db.dart';
import '../models/community-assessment-model.dart';
import '../utils/urls.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: URLS.baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            sendTimeout: const Duration(seconds: 5),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          ),
        );

  Future<bool> submitCommunityAssessment(CommunityAssessmentModel model,
      {bool isEdit = false}) async {
    final String endpoint = URLS.communityAssessment;

    try {
      final response = await _dio.post(
        endpoint,
        data: model.toMap(),
      );

      if (response.statusCode == 200) {
        if (isEdit) {
          await LocalDBHelper.instance
              .updateResponse(model.copyWith(status: 1));
        } else {
          // if submission is successful, save offline
          await LocalDBHelper.instance
              .insertResponse(model.copyWith(status: 1));
        }
        return true;
      } else {
        throw Exception(_mapError(response.statusCode, response.data));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Connection timed out, please try again");
      } else if (e.response != null) {
        throw Exception(
          _mapError(e.response?.statusCode, e.response?.data),
        );
      } else {
        throw Exception("Network error, please check your connection");
      }
    } catch (_) {
      await LocalDBHelper.instance.insertResponse(model.copyWith(status: 0));
      throw Exception("Unexpected error occurred, please try again later");
    }
  }

  String _mapError(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return data?['message'] ?? "Invalid request";
      case 401:
        return "Unauthorized request";
      case 403:
        return "Access forbidden";
      case 404:
        return "Resource not found";
      case 500:
        return "Internal server error";
      default:
        return "An unknown error occurred ($statusCode)";
    }
  }
}
