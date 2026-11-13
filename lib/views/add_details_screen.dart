import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/health_provider.dart';
import '../models/health_record.dart';
import 'list_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';

class AddDetailsScreen extends StatefulWidget {
  final int userId;

  const AddDetailsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController waterController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  static const Color _darkGreen = Color(0xFF1E3A2B);
  static const Color _forestGreen = Color(0xFF245640);
  static const Color _mediumGreen = Color(0xFF3D795B);
  static const Color _mutedGreen = Color(0xFF52665B);
  static const Color _glassColor = Color(0xFFDDEBDD);

  @override
  void initState() {
    super.initState();

  }

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveRecord() async {
    final int? steps = int.tryParse(stepsController.text.trim());
    final int? calories = int.tryParse(caloriesController.text.trim());
    final int? water = int.tryParse(waterController.text.trim());

    if (steps == null ||
        calories == null ||
        water == null ||
        steps < 0 ||
        calories < 0 ||
        water < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid non-negative whole numbers in all fields.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final String formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    final HealthRecord record = HealthRecord(
      date: formattedDate,
      steps: steps,
      calories: calories,
      waterMl: water,
    );

    try {
      await context.read<HealthProvider>().addRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health record saved successfully!'),
        ),
      );

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (error, stackTrace) {
      debugPrint('SAVE RECORD ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
        ),
      );
    }
  }

  @override
  void dispose() {
    stepsController.dispose();
    caloriesController.dispose();
    waterController.dispose();
    super.dispose();
  }

  // Reusable green glassmorphism card.
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

  // Reusable section heading.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _darkGreen,
        letterSpacing: -0.4,
      ),
    );
  }

  // Health record page header.
  Widget _buildPageHeader() {
    return _buildGlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 19,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.note_add_rounded,
                color: _forestGreen,
                size: 30,
              ),
              const SizedBox(width: 4),
              _buildSectionTitle('Health Record'),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Track your daily steps, calories, and water intake.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedGreen,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Date selection section.
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Record Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: _forestGreen,
                  size: 23,
                ),
                const SizedBox(width: 14),
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _darkGreen,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down,
                  color: _mutedGreen,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Reusable health input field.
  Widget _buildInputField({
    required String title,
    required String hint,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF829187),
              fontSize: 13,
            ),
            suffixText: unit,
            suffixStyle: const TextStyle(
              color: _mutedGreen,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.65),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _forestGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Logout confirmation.
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

  // Bottom navigation actions.
  Future<void> _handleNavigation(int index) async {
    
    if (index == 0) {
          Navigator.popUntil(
      context,
      (route) => route.isFirst,
        );
    }
    
    else if (index == 1) {
      // Add is already the active page.
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListScreen(userId: widget.userId),
        ),
      );
    } else if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(userId: widget.userId),
        ),
      );
    } else if (index == 4) {
      _confirmLogout();
    }
  }

  // Dashboard-style navigation item.
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = index == 1;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      hoverColor: const Color(0xFFE6EEE5),
      splashColor: const Color(0xFFD5E5D7),
      onTap: () => _handleNavigation(index),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEE5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image.
          Image.asset(
            'assets/images/fitness_background.jpeg',
            fit: BoxFit.cover,
          ),

          // Soft green overlay.
          Container(
            color: const Color.fromRGBO(230, 238, 229, 0.48),
          ),

          // Main page content.
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  kToolbarHeight - 55,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double horizontalPadding =
                    constraints.maxWidth < 400 ? 12 : 18;

                final double availableHeight = constraints.maxHeight - 24;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    22,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight > 0 ? availableHeight : 0,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 550,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Health Record heading card.
                            _buildPageHeader(),

                            const SizedBox(height: 18),

                            // Record Details glass card.
                            _buildGlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Record Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _darkGreen,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    'Choose a date and enter your daily totals.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _mutedGreen,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  _buildDateSelector(),

                                  const SizedBox(height: 20),

                                  _buildInputField(
                                    title: 'Daily Steps',
                                    hint: 'Enter your step count',
                                    unit: 'steps',
                                    icon: Icons.directions_walk,
                                    iconColor: _mediumGreen,
                                    controller: stepsController,
                                  ),

                                  const SizedBox(height: 16),

                                  _buildInputField(
                                    title: 'Calories Burned',
                                    hint: 'Enter calories burned',
                                    unit: 'kcal',
                                    icon: Icons.local_fire_department,
                                    iconColor: const Color(0xFFE57373),
                                    controller: caloriesController,
                                  ),

                                  const SizedBox(height: 16),

                                  _buildInputField(
                                    title: 'Water Intake',
                                    hint: 'Enter water intake',
                                    unit: 'ml',
                                    icon: Icons.water_drop,
                                    iconColor: const Color(0xFF4A90C2),
                                    controller: waterController,
                                  ),

                                  const SizedBox(height: 22),

                                  // Save button.
                                  SizedBox(
                                    width: double.infinity,
                                    height: 46,
                                    child: ElevatedButton(
                                      onPressed: isSaving ? null : saveRecord,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _forestGreen,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: isSaving
                                          ? const SizedBox(
                                              height: 21,
                                              width: 21,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Save Record',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Cancel button.
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _forestGreen,
                                        side: BorderSide(
                                          color: _forestGreen.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Dashboard-style full-width glass navigation.
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
    );
  }
}