import '../database/database_helper.dart';
import '../models/health_record.dart';

class HealthController {
  final DatabaseHelper _database = DatabaseHelper.instance;

  // The ID of the currently logged-in user.
  final int userId;

  HealthController({required this.userId});

  // Save a new record or update the record for the same date.
  Future<int> addRecord(HealthRecord record) async {
    final recordData = record.toMap();
    recordData['user_id'] = userId;

    return await _database.saveOrUpdateHealthRecord(recordData);
  }

  // Retrieve all records in the selected sorting order.
  Future<List<HealthRecord>> getAllRecords({
    bool newestFirst = true,
  }) async {
    final records = await _database.fetchHealthRecords(
      userId,
      newestFirst: newestFirst,
    );

    return records.map((data) => HealthRecord.fromMap(data)).toList();
  }

  // Update an existing health record.
  Future<int> updateRecord(HealthRecord record) async {
    if (record.id == null) {
      throw ArgumentError('Record ID is required to update a record.');
    }

    final recordData = record.toMap();
    recordData['user_id'] = userId;

    return await _database.editHealthRecord(
      record.id!,
      userId,
      recordData,
    );
  }

  // Delete a health record using its ID.
  Future<int> deleteRecord(int id) async {
    return await _database.removeHealthRecord(id, userId);
  }

  // Retrieve records for a selected date.
  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    final records = await _database.fetchRecordsByDate(
      userId,
      date,
    );

    return records.map((data) => HealthRecord.fromMap(data)).toList();
  }

  // Retrieve today's health record.
  Future<List<HealthRecord>> getTodayRecords() async {
    final today = DateTime.now();

    final formattedDate =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    return await getRecordsByDate(formattedDate);
  }

  // Retrieve totals for the last seven days, including today.
  Future<Map<String, int>> getWeeklySummary() async {
    final today = DateTime.now();
    final firstDay = today.subtract(const Duration(days: 6));

    String formatDate(DateTime date) {
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    }

    final records = await _database.fetchWeeklyRecords(
      userId,
      formatDate(firstDay),
      formatDate(today),
    );

    int totalSteps = 0;
    int totalWater = 0;
    int totalCalories = 0;

    for (final record in records) {
      totalSteps += record['steps'] as int;
      totalWater += record['water_ml'] as int;
      totalCalories += record['calories'] as int;
    }

    return {
      'steps': totalSteps,
      'waterMl': totalWater,
      'calories': totalCalories,
    };
  }

  // Retrieve the user's saved water goal.
  Future<int> getWaterGoal() async {
    return await _database.getWaterGoal(userId);
  }

  // Save the user's water goal.
  Future<void> saveWaterGoal(int goal) async {
    await _database.saveWaterGoal(userId, goal);
  }

  // Retrieve the user's saved daily step goal.
  Future<int> getStepGoal() async {
    return await _database.getStepGoal(userId);
  }

  // Save the user's daily step goal.
  Future<void> saveStepGoal(int goal) async {
    await _database.saveStepGoal(userId, goal);
  }
}