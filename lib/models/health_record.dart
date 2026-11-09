
class HealthRecord {
  final int? id;
  final int? userId;
  final String date;
  final int steps;
  final int calories;
  final int waterMl;

  const HealthRecord({
    this.id,
    this.userId,
    required this.date,
    required this.steps,
    required this.calories,
    required this.waterMl,
  });

  // Create a health record using information retrieved from SQLite.
  factory HealthRecord.fromMap(Map<String, dynamic> data) {
    return HealthRecord(
      id: data['id'] as int?,
      userId: data['user_id'] as int?,
      date: data['date'] as String,
      steps: data['steps'] as int,
      calories: data['calories'] as int,
      waterMl: data['water_ml'] as int,
    );
  }

  // Prepare health record information for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water_ml': waterMl,
    };
  }
}
