import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  // Return the database or create it if it is not available.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _createDatabase();
    return _database!;
  }

  // Initialise the HealthMate database.
  Future<Database> _createDatabase() async {
    final directory = await getDatabasesPath();
    final databasePath = join(directory, 'healthmate.db');

    return await openDatabase(
      databasePath,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL COLLATE NOCASE UNIQUE,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE health_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL,
            calories INTEGER NOT NULL,
            water_ml INTEGER NOT NULL,
            UNIQUE(user_id, date),
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE app_settings (
            user_id INTEGER,
            setting_name TEXT NOT NULL,
            setting_value INTEGER NOT NULL,
            PRIMARY KEY (user_id, setting_name),
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            DELETE FROM health_records
            WHERE id NOT IN (
              SELECT MAX(id)
              FROM health_records
              GROUP BY date
            )
          ''');

          await db.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS unique_record_date
            ON health_records(date)
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE app_settings (
              setting_name TEXT PRIMARY KEY,
              setting_value INTEGER NOT NULL
            )
          ''');
        }

        if (oldVersion < 4) {
          // Create the users table.
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          // Create a new health records table.
          // Preserve existing records with a NULL user_id.
          await db.execute('''
            CREATE TABLE health_records_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              date TEXT NOT NULL,
              steps INTEGER NOT NULL,
              calories INTEGER NOT NULL,
              water_ml INTEGER NOT NULL,
              UNIQUE(user_id, date),
              FOREIGN KEY (user_id) REFERENCES users(id)
            )
          ''');

          await db.execute('''
            INSERT INTO health_records_new
              (id, user_id, date, steps, calories, water_ml)
            SELECT id, NULL, date, steps, calories, water_ml
            FROM health_records
          ''');

          await db.execute('DROP TABLE health_records');

          await db.execute('''
            ALTER TABLE health_records_new
            RENAME TO health_records
          ''');

          // Create a new settings table.
          await db.execute('''
            CREATE TABLE app_settings_new (
              user_id INTEGER,
              setting_name TEXT NOT NULL,
              setting_value INTEGER NOT NULL,
              PRIMARY KEY (user_id, setting_name),
              FOREIGN KEY (user_id) REFERENCES users(id)
            )
          ''');

          await db.execute('''
            INSERT INTO app_settings_new
              (user_id, setting_name, setting_value)
            SELECT NULL, setting_name, setting_value
            FROM app_settings
          ''');

          await db.execute('DROP TABLE app_settings');

          await db.execute('''
            ALTER TABLE app_settings_new
            RENAME TO app_settings
          ''');
        }

        if (oldVersion < 5) {
          // Remove the old global date constraint.
          // Each user can now have a record for the same date.
          await db.execute('''
            DROP INDEX IF EXISTS unique_record_date
          ''');

          // Make usernames and emails case-insensitively unique.
          await db.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS unique_username
            ON users(username COLLATE NOCASE)
          ''');

          await db.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS unique_email
            ON users(email COLLATE NOCASE)
          ''');
        }
      },
    );
  }

  // Register a new user and return the new user's ID.
  Future<int> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await database;

    final cleanUsername = username.trim();
    final cleanEmail = email.trim().toLowerCase();

    // Hash the password before storing it.
    final passwordHash = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    return await db.transaction((transaction) async {
      final userId = await transaction.insert(
        'users',
        {
          'username': cleanUsername,
          'email': cleanEmail,
          'password_hash': passwordHash,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Assign existing health records to the first account.
      await transaction.update(
        'health_records',
        {'user_id': userId},
        where: 'user_id IS NULL',
      );

      // Assign existing settings to the first account.
      await transaction.update(
        'app_settings',
        {'user_id': userId},
        where: 'user_id IS NULL',
      );

      return userId;
    });
  }

  // Verify the user's email and password during login.
  // Return user details if successful; otherwise return null.
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final cleanEmail = email.trim().toLowerCase();

    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final user = results.first;
    final storedPasswordHash = user['password_hash'] as String;

    try {
      final passwordIsCorrect = BCrypt.checkpw(
        password,
        storedPasswordHash,
      );

      if (!passwordIsCorrect) {
        return null;
      }

      // Do not return the password hash to the screen.
      final userDetails = Map<String, dynamic>.from(user);
      userDetails.remove('password_hash');

      return userDetails;
    } catch (e) {
      return null;
    }
  }

  // Save a new record or update an existing record for that user and date.
  Future<int> saveOrUpdateHealthRecord(
    Map<String, dynamic> record,
  ) async {
    final db = await database;

    return await db.transaction((transaction) async {
      final recordData = Map<String, dynamic>.from(record);
      recordData.remove('id');

      final existingRecords = await transaction.query(
        'health_records',
        columns: ['id'],
        where: 'user_id = ? AND date = ?',
        whereArgs: [recordData['user_id'], recordData['date']],
      );

      if (existingRecords.isNotEmpty) {
        final existingId = existingRecords.first['id'] as int;

        await transaction.update(
          'health_records',
          recordData,
          where: 'id = ?',
          whereArgs: [existingId],
        );

        return existingId;
      }

      return await transaction.insert(
        'health_records',
        recordData,
      );
    });
  }

  // Retrieve health records in the selected sorting order.
  Future<List<Map<String, dynamic>>> fetchHealthRecords(
    int userId, {
    bool newestFirst = true,
  }) async {
    final db = await database;

    return await db.query(
      'health_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: newestFirst ? 'date DESC, id DESC' : 'date ASC, id ASC',
    );
  }

  // Retrieve health records from the selected seven-day period.
  Future<List<Map<String, dynamic>>> fetchWeeklyRecords(
    int userId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;

    return await db.query(
      'health_records',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'date DESC',
    );
  }

  // Update an existing health record.
  Future<int> editHealthRecord(
    int id,
    int userId,
    Map<String, dynamic> record,
  ) async {
    final db = await database;

    final recordData = Map<String, dynamic>.from(record);
    recordData.remove('id');

    return await db.update(
      'health_records',
      recordData,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Delete a health record.
  Future<int> removeHealthRecord(int id, int userId) async {
    final db = await database;

    return await db.delete(
      'health_records',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Retrieve records for a selected date.
  Future<List<Map<String, dynamic>>> fetchRecordsByDate(
    int userId,
    String selectedDate,
  ) async {
    final db = await database;

    return await db.query(
      'health_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, selectedDate],
      orderBy: 'id DESC',
    );
  }

  // Retrieve the saved water goal for a user.
  Future<int> getWaterGoal(int userId) async {
    final db = await database;

    final result = await db.query(
      'app_settings',
      columns: ['setting_value'],
      where: 'user_id = ? AND setting_name = ?',
      whereArgs: [userId, 'water_goal'],
    );

    if (result.isEmpty) {
      return 2000;
    }

    return result.first['setting_value'] as int;
  }

  // Save or update the water goal for a user.
  Future<void> saveWaterGoal(int userId, int goal) async {
    final db = await database;

    await db.insert(
      'app_settings',
      {
        'user_id': userId,
        'setting_name': 'water_goal',
        'setting_value': goal,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve the saved daily step goal for a user.
  Future<int> getStepGoal(int userId) async {
    final db = await database;

    final result = await db.query(
      'app_settings',
      columns: ['setting_value'],
      where: 'user_id = ? AND setting_name = ?',
      whereArgs: [userId, 'step_goal'],
    );

    if (result.isEmpty) {
      return 10000;
    }

    return result.first['setting_value'] as int;
  }

  // Retrieve the registered username for a specific user.
  Future<String> getUserName(int userId) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['username'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return '';
    }

    return result.first['username'] as String;
  }

  // Save or update the daily step goal for a user.
  Future<void> saveStepGoal(int userId, int goal) async {
    final db = await database;

    await db.insert(
      'app_settings',
      {
        'user_id': userId,
        'setting_name': 'step_goal',
        'setting_value': goal,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}