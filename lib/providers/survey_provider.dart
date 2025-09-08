import 'package:flutter/foundation.dart';
import '../models/survey_response.dart';
import '../database/database_helper.dart';

class SurveyProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<SurveyResponse> _surveys = [];
  bool _isLoading = false;
  String? _error;

  List<SurveyResponse> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSurveys() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> surveys = 
          await _databaseHelper.getSurveys();
      _surveys = surveys.map((map) => SurveyResponse.fromMap(map)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load surveys: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSurvey(SurveyResponse survey) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (survey.id == null) {
        await _databaseHelper.insertSurvey(survey.toMap());
      } else {
        await _databaseHelper.updateSurvey(survey.toMap());
      }
      await loadSurveys();
      _error = null;
    } catch (e) {
      _error = 'Failed to save survey: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSurvey(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseHelper.deleteSurvey(id);
      await loadSurveys();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete survey: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
