
import 'package:flutter/foundation.dart';

import '../models/health_record.dart';
import 'health_controller.dart';

class HealthProvider extends ChangeNotifier {
  int? _userId;
  HealthController? _healthController;

  // Health records
  List<HealthRecord> healthRecords = [];
  List<HealthRecord> searchResults = [];

  // Today's health information
  int steps = 0;
  int calories = 0;
  int waterMl = 0;

  // Daily goals
  int stepGoal = 10000;
  int waterGoal = 2000;

  // Weekly summary
  int weeklySteps = 0;
  int weeklyCalories = 0;
  int weeklyWater = 0;

  // Loading and error states
  bool isLoading = false;
  String? errorMessage;

  bool isInitialised = false;

  // Set the logged-in user's ID.
  Future<void> setUserId(int userId) async {
    _userId = userId;
    _healthController = HealthController(userId: userId);

    isInitialised = false;
    await loadInitialData();
  }

  // Check whether a user is logged in.
  bool get hasUser => _userId != null;

  // Load the initial application data.
  Future<void> loadInitialData() async {
    if (_healthController == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await loadDashboardData();
      await loadRecords();

      isInitialised = true;
    } catch (error) {
      errorMessage = 'Unable to load health information.';
      debugPrint('INITIAL DATA ERROR: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Load dashboard information.
  Future<void> loadDashboardData() async {
    if (_healthController == null) return;

    try {
      final records = await _healthController!.getTodayRecords();

      final savedStepGoal =
          await _healthController!.getStepGoal();

      final savedWaterGoal =
          await _healthController!.getWaterGoal();

      final weeklySummary =
          await _healthController!.getWeeklySummary();

      if (records.isNotEmpty) {
        steps = records.first.steps;
        calories = records.first.calories;
        waterMl = records.first.waterMl;
      } else {
        steps = 0;
        calories = 0;
        waterMl = 0;
      }

      stepGoal = savedStepGoal;
      waterGoal = savedWaterGoal;

      weeklySteps = weeklySummary['steps'] ?? 0;
      weeklyCalories = weeklySummary['calories'] ?? 0;
      weeklyWater = weeklySummary['waterMl'] ?? 0;

      errorMessage = null;
    } catch (error) {
      errorMessage = 'Unable to load dashboard information.';
      debugPrint('DASHBOARD DATA ERROR: $error');
      rethrow;
    }

    notifyListeners();
  }

  // Load all health records.
  Future<void> loadRecords({
    bool newestFirst = true,
  }) async {
    if (_healthController == null) return;

    try {
      healthRecords =
          await _healthController!.getAllRecords(
        newestFirst: newestFirst,
      );

      errorMessage = null;
    } catch (error) {
      errorMessage = 'Unable to load health records.';
      debugPrint('LOAD RECORDS ERROR: $error');
      rethrow;
    }

    notifyListeners();
  }

  // Search health records by date.
  Future<void> searchRecordsByDate(String date) async {
    if (_healthController == null) return;

    try {
      searchResults =
          await _healthController!.getRecordsByDate(date);

      errorMessage = null;
    } catch (error) {
      errorMessage = 'Unable to search health records.';
      debugPrint('SEARCH RECORDS ERROR: $error');
      rethrow;
    }

    notifyListeners();
  }

  // Clear search results.
  void clearSearchResults() {
    searchResults = [];
    notifyListeners();
  }

  // Add a health record.
  Future<void> addRecord(HealthRecord record) async {
    if (_healthController == null) return;

    try {
      await _healthController!.addRecord(record);

      await loadRecords();
      await loadDashboardData();
    } catch (error) {
      debugPrint('ADD RECORD ERROR: $error');
      rethrow;
    }
  }

  // Update an existing health record.
  Future<void> updateRecord(HealthRecord record) async {
    if (_healthController == null) return;

    try {
      await _healthController!.updateRecord(record);

      await loadRecords();
      await loadDashboardData();
    } catch (error) {
      debugPrint('UPDATE RECORD ERROR: $error');
      rethrow;
    }
  }

  // Delete a health record.
  Future<void> deleteRecord(int recordId) async {
    if (_healthController == null) return;

    try {
      await _healthController!.deleteRecord(recordId);

      await loadRecords();
      await loadDashboardData();
    } catch (error) {
      debugPrint('DELETE RECORD ERROR: $error');
      rethrow;
    }
  }

  // Save a new daily step goal.
  Future<void> saveStepGoal(int goal) async {
    if (_healthController == null) return;

    try {
      await _healthController!.saveStepGoal(goal);
      stepGoal = goal;
    } catch (error) {
      debugPrint('SAVE STEP GOAL ERROR: $error');
      rethrow;
    }

    notifyListeners();
  }

  // Save a new daily water goal.
  Future<void> saveWaterGoal(int goal) async {
    if (_healthController == null) return;

    try {
      await _healthController!.saveWaterGoal(goal);
      waterGoal = goal;
    } catch (error) {
      debugPrint('SAVE WATER GOAL ERROR: $error');
      rethrow;
    }

    notifyListeners();
  }

  // Clear data when the user logs out.
  void clearUserData() {
    _userId = null;
    _healthController = null;

    healthRecords = [];
    searchResults = [];

    steps = 0;
    calories = 0;
    waterMl = 0;

    stepGoal = 10000;
    waterGoal = 2000;

    weeklySteps = 0;
    weeklyCalories = 0;
    weeklyWater = 0;

    isLoading = false;
    errorMessage = null;
    isInitialised = false;

    notifyListeners();
  }
}
