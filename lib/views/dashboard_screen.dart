import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/health_provider.dart';
import '../controllers/user_provider.dart';


import 'add_details_screen.dart';
import 'list_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  late final UserProvider _userProvider;

  int stepGoal = 10000;

  int steps = 0;
  int calories = 0;
  int waterMl = 0;
  int waterGoal = 2000;

  int weeklySteps = 0;
  int weeklyWater = 0;
  int weeklyCalories = 0;

  int currentIndex = 0;
  bool isLoading = true;
  bool isSavingGoal = false;
  String? errorMessage;

  final NumberFormat _numberFormat = NumberFormat('#,##0');

  static const Color _darkGreen = Color(0xFF1E3A2B);
  static const Color _forestGreen = Color(0xFF245640);
  static const Color _mediumGreen = Color(0xFF3D795B);
  static const Color _mutedGreen = Color(0xFF52665B);
  static const Color _glassColor = Color(0xFFDDEBDD);

  @override
  void initState() {
    super.initState();


    _userProvider = UserProvider();
    _userProvider.loadUserName(widget.userId);

    loadDashboardData();
  }

  @override
  void dispose() {
    _userProvider.dispose();
    super.dispose();
  }

  // Load today's record, saved goals and weekly summary.
Future<void> loadDashboardData() async {
  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  try {
    final healthProvider = context.read<HealthProvider>();

    await healthProvider.loadDashboardData();

    if (!mounted) return;

    setState(() {
      steps = healthProvider.steps;
      calories = healthProvider.calories;
      waterMl = healthProvider.waterMl;

      stepGoal = healthProvider.stepGoal;
      waterGoal = healthProvider.waterGoal;

      weeklySteps = healthProvider.weeklySteps;
      weeklyWater = healthProvider.weeklyWater;
      weeklyCalories = healthProvider.weeklyCalories;

      isLoading = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      errorMessage = 'Unable to load dashboard information.';
      isLoading = false;
    });
  }
}



  // Allow the user to change the daily step goal.
  Future<void> showStepGoalDialog() async {
    String enteredGoal = stepGoal.toString();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5FAF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Set Daily Step Goal',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your daily step tracking goal.',
                style: TextStyle(
                  color: Color(0xFF66756A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: enteredGoal,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  enteredGoal = value;
                },
                decoration: InputDecoration(
                  labelText: 'Daily step goal',
                  hintText: 'Example: 10000',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _forestGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: _mutedGreen),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? newGoal =
                    int.tryParse(enteredGoal.trim());

                if (newGoal == null || newGoal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid step goal.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                if (!mounted) return;

                setState(() {
                  isSavingGoal = true;
                });

                try {
                  await context.read<HealthProvider>().saveStepGoal(newGoal);

                  if (!mounted) return;

                  setState(() {
                    stepGoal = newGoal;
                    isSavingGoal = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Step goal updated successfully.',
                      ),
                    ),
                  );
                } catch (error) {
                  debugPrint('STEP GOAL ERROR: $error');

                  if (!mounted) return;

                  setState(() {
                    isSavingGoal = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to save the step goal.',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Goal'),
            ),
          ],
        );
      },
    );
  }
    // Allow the user to change the daily water goal.
  Future<void> showWaterGoalDialog() async {
    String enteredGoal = waterGoal.toString();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5FAF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Set Water Goal',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your daily water tracking goal in millilitres.',
                style: TextStyle(
                  color: Color(0xFF66756A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: enteredGoal,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  enteredGoal = value;
                },
                decoration: InputDecoration(
                  labelText: 'Water goal (ml)',
                  hintText: 'Example: 2000',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _forestGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This is a personal tracking goal, not medical advice.',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: _mutedGreen),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? newGoal =
                    int.tryParse(enteredGoal.trim());

                if (newGoal == null || newGoal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid water goal.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                if (!mounted) return;

                setState(() {
                  isSavingGoal = true;
                });

                try {
                  await context.read<HealthProvider>().saveWaterGoal(newGoal);

                  if (!mounted) return;

                  setState(() {
                    waterGoal = newGoal;
                    isSavingGoal = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Water goal updated successfully.',
                      ),
                    ),
                  );
                } catch (error) {
                  debugPrint('WATER GOAL ERROR: $error');

                  if (!mounted) return;

                  setState(() {
                    isSavingGoal = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to save the water goal.',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Goal'),
            ),
          ],
        );
      },
    );
  }

  // Logout Confirmation.
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5FAF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Color(0xFF66756A),
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: _forestGreen),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Reusable premium glass card.
  Widget _buildGlassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: _glassColor.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF203C2B)
                    .withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Consistent small metric card.
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142B20),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF52665B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Weekly summary metric card.
  Widget _buildWeeklyCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return _buildGlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: _darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF142B20),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: _mutedGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable section heading.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _darkGreen,
        letterSpacing: -0.4,
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    final double stepProgress =
        (steps / stepGoal).clamp(0.0, 1.0);

    final double waterProgress =
        (waterMl / waterGoal).clamp(0.0, 1.0);

    final DateTime today = DateTime.now();

    const List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final String todayLabel =
        '${today.day} ${monthNames[today.month - 1]} ${today.year}';

    return ChangeNotifierProvider<UserProvider>.value(
      value: _userProvider,
      child: Scaffold(
        backgroundColor: const Color(0xFFE6EEE5),
        body: Stack(
          children: [
            // Fitness background image.
            Positioned.fill(
              child: Image.asset(
                'assets/images/fitness_background.jpeg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Soft green overlay.
            Positioned.fill(
              child: Container(
                color: const Color.fromRGBO(230, 238, 229, 0.48),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personalised Dashboard Header using Provider.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 25,
                        ),
                        child: Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final hour = DateTime.now().hour;

                            final greeting = hour < 12
                                ? 'Good morning 👋'
                                : hour < 17
                                    ? 'Good afternoon 👋'
                                    : 'Good evening 👋';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  todayLabel.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _mutedGreen,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  greeting,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _mutedGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  userProvider.isLoading ||
                                          userProvider.userName.isEmpty
                                      ? 'Welcome!'
                                      : 'Welcome, ${userProvider.userName}!',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: _darkGreen,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your daily wellness at a glance.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF52665B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Loading and error states.
                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(35),
                                child: CircularProgressIndicator(
                                  color: _forestGreen,
                                ),
                              ),
                            )
                          else if (errorMessage != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: loadDashboardData,
                                      child: const Text(
                                        'Try Again',
                                        style: TextStyle(
                                          color: _forestGreen,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            // Today's Activity.
                            _buildGlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Today's Activity"),
                                  const SizedBox(height: 19),

                                  // Daily Steps heading.
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.58,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.directions_walk,
                                          color: _forestGreen,
                                          size: 27,
                                        ),
                                      ),
                                      const SizedBox(width: 11),
                                      const Expanded(
                                        child: Text(
                                          'Daily Steps',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _darkGreen,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isSavingGoal
                                            ? null
                                            : showStepGoalDialog,
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: _forestGreen,
                                          size: 21,
                                        ),
                                        tooltip: 'Edit step goal',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _numberFormat.format(steps),
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF142B20),
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'steps',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _mutedGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    'Steps Progress',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _mutedGreen,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: stepProgress,
                                      minHeight: 13,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        _mediumGreen,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),


                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(stepProgress * 100).toStringAsFixed(0)}% completed',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _mutedGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Goal: ${_numberFormat.format(stepGoal)} steps',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _mutedGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 21),

                                  Divider(
                                    color: _darkGreen.withValues(alpha: 0.13),
                                    height: 1,
                                  ),

                                  const SizedBox(height: 17),

                                  // Calories and Water.
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _buildMetricCard(
                                            title: 'Calories',
                                            value:
                                                _numberFormat.format(calories),
                                            unit: 'kcal',
                                            icon:
                                                Icons.local_fire_department,
                                            iconColor:
                                                const Color(0xFFE89B69),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildMetricCard(
                                            title: 'Water',
                                            value:
                                                _numberFormat.format(waterMl),
                                            unit: 'ml',
                                            icon: Icons.water_drop,
                                            iconColor:
                                                const Color(0xFF69A9C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 22),
                                  // Daily Water Goal.
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.58,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.water_drop,
                                          color: Color(0xFF69A9C7),
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 11),
                                      const Expanded(
                                        child: Text(
                                          'Daily Water Goal',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _darkGreen,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isSavingGoal
                                            ? null
                                            : showWaterGoalDialog,
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: _forestGreen,
                                          size: 21,
                                        ),
                                        tooltip: 'Edit water goal',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _numberFormat.format(waterMl),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF142B20),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          'ml consumed',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _mutedGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    'Water Progress',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _mutedGreen,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: waterProgress,
                                      minHeight: 13,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF69A9C7),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 11),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(waterProgress * 100).toStringAsFixed(0)}% completed',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _mutedGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Goal: ${_numberFormat.format(waterGoal)} ml',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _mutedGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Weekly Summary.
                            _buildGlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Weekly Summary'),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Your totals for the last 7 days, including today.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _mutedGreen,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildWeeklyCard(
                                          title: 'Steps',
                                          value: _numberFormat
                                              .format(weeklySteps),
                                          unit: 'steps',
                                          icon: Icons.directions_walk,
                                          iconColor: _mediumGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: _buildWeeklyCard(
                                          title: 'Water',
                                          value: _numberFormat
                                              .format(weeklyWater),
                                          unit: 'ml',
                                          icon: Icons.water_drop,
                                          iconColor:
                                              const Color(0xFF69A9C7),
                                        ),
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: _buildWeeklyCard(
                                          title: 'Calories',
                                          value: _numberFormat
                                              .format(weeklyCalories),
                                          unit: 'kcal',
                                          icon: Icons.local_fire_department,
                                          iconColor:
                                              const Color(0xFFE89B69),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Motivational Message.
                            _buildGlassCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 19,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.spa,
                                    color: _forestGreen,
                                    size: 29,
                                  ),
                                  SizedBox(width: 13),
                                  Expanded(
                                    child: Text(
                                      'Small steps every day lead to big changes. Keep going!',
                                      style: TextStyle(
                                        color: _darkGreen,
                                        fontSize: 14,
                                        height: 1.45,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                         ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),


        // Full-width premium glass bottom navigation.
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 18,
              sigmaY: 18,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _glassColor.withValues(alpha: 0.88),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.65),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _darkGreen.withValues(alpha: 0.07),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          index: 0,
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.add_circle_outline,
                          label: 'Add',
                          index: 1,
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.history,
                          label: 'History',
                          index: 2,
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.search,
                          label: 'Search',
                          index: 3,
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          icon: Icons.logout,
                          label: 'Logout',
                          index: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Navigation Item.
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      hoverColor: const Color(0xFFE6EEE5),
      splashColor: const Color(0xFFD5E5D7),
      onTap: () async {
        if (index == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddDetailsScreen(userId: widget.userId),
            ),
          );

          if (mounted) {
            await loadDashboardData();
          }
        } else if (index == 0) {
          setState(() {
            currentIndex = 0;
          });

          await loadDashboardData();
        } else if (index == 2) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListScreen(userId: widget.userId),
            ),
          );

          if (mounted) {
            await loadDashboardData();
          }
        } else if (index == 3) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(userId: widget.userId),
            ),
          );

          if (mounted) {
            await loadDashboardData();
          }
        } else if (index == 4) {
          _confirmLogout();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _forestGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : _mutedGreen,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : _mutedGreen,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}