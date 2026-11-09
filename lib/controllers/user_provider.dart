import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class UserProvider extends ChangeNotifier {
  String userName = '';
  bool isLoading = true;

  // Load the registered username using the logged-in user's ID.
  Future<void> loadUserName(int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      userName =
          await DatabaseHelper.instance.getUserName(userId);
    } catch (error) {
      debugPrint('USER NAME ERROR: $error');
      userName = '';
    }

    isLoading = false;
    notifyListeners();
  }

  // Register a new user account.
  Future<void> registerUser({
      required String username,
      required String email,
      required String password,
    }) async {
      await DatabaseHelper.instance.registerUser(
        username: username,
        email: email,
        password: password,
      );
    }
}