
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/health_controller.dart';
import '../models/health_record.dart';

class EditScreen extends StatefulWidget {
  final HealthRecord record;
  final int userId;

  const EditScreen({
    super.key,
    required this.record,
    required this.userId,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final HealthController _healthController;

  late final TextEditingController stepsController;
  late final TextEditingController caloriesController;
  late final TextEditingController waterController;

  late DateTime selectedDate;

  bool isUpdating = false;

  static const Color _darkGreen = Color(0xFF1E3A2B);
  static const Color _forestGreen = Color(0xFF245640);
  static const Color _glassColor = Color(0xFFDDEBDD);

  @override
  void initState() {
    super.initState();

    // Allow the background to extend behind the system navigation area.
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    _healthController = HealthController(userId: widget.userId);

    stepsController = TextEditingController(
      text: widget.record.steps.toString(),
    );

    caloriesController = TextEditingController(
      text: widget.record.calories.toString(),
    );

    waterController = TextEditingController(
      text: widget.record.waterMl.toString(),
    );

    selectedDate = DateTime.parse(widget.record.date);
  }

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> updateRecord() async {
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
            'Please enter valid numbers. Values cannot be negative.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final String formattedDate =
          '${selectedDate.year.toString().padLeft(4, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}';

      // Check whether another record exists for this date.
      final existingRecords =
          await _healthController.getRecordsByDate(formattedDate);

      final bool dateAlreadyExists = existingRecords.any(
        (record) => record.id != widget.record.id,
      );

      if (dateAlreadyExists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A health record already exists for this date. '
              'Please select another date.',
            ),
          ),
        );

        return;
      }

      final updatedRecord = HealthRecord(
        id: widget.record.id,
        date: formattedDate,
        steps: steps,
        calories: calories,
        waterMl: water,
      );

      await _healthController.updateRecord(updatedRecord);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health record updated successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      debugPrint('UPDATE RECORD ERROR: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update the record. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    stepsController.dispose();
    caloriesController.dispose();
    waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Fitness background image extending fully to bottom edge.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/fitness_background.jpeg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),

            // Soft green overlay.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(230, 238, 229, 0.48),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool compact = constraints.maxHeight < 700;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      compact ? 2 : 8,
                      16,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 550,
                          minHeight: constraints.maxHeight - (compact ? 10 : 20),
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Heading glass card.
                              _buildGlassCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 23,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F0E9),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.edit_note_rounded,
                                            color: _forestGreen,
                                            size: 25,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Flexible(
                                          child: Text(
                                            'Edit Health Record',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: _darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Make changes to your daily health record.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF718078),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: compact ? 12 : 16),

                              // Main editing glass card.
                              _buildGlassCard(
                                padding: EdgeInsets.all(compact ? 16 : 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Record Date',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF234B3A),
                                      ),
                                    ),

                                    const SizedBox(height: 7),

                                    InkWell(
                                      onTap: isUpdating ? null : selectDate,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: compact ? 12 : 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAF8),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFE0E6E2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_month,
                                              color: Color(0xFF234B3A),
                                              size: 21,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '${selectedDate.day}/'
                                              '${selectedDate.month}/'
                                              '${selectedDate.year}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF34483D),
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Color(0xFF718078),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: compact ? 13 : 18),

                                    _buildInputField(
                                      title: 'Daily Steps',
                                      hint: 'Enter your step count',
                                      unit: 'steps',
                                      icon: Icons.directions_walk,
                                      iconColor: const Color(0xFF568568),
                                      controller: stepsController,
                                      compact: compact,
                                    ),

                                    SizedBox(height: compact ? 12 : 16),

                                    _buildInputField(
                                      title: 'Calories Burned',
                                      hint: 'Enter calories burned',
                                      unit: 'kcal',
                                      icon: Icons.local_fire_department,
                                      iconColor: const Color(0xFFE57373),
                                      controller: caloriesController,
                                      compact: compact,
                                    ),

                                    SizedBox(height: compact ? 12 : 16),

                                    _buildInputField(
                                      title: 'Water Intake',
                                      hint: 'Enter water intake',
                                      unit: 'ml',
                                      icon: Icons.water_drop,
                                      iconColor: const Color(0xFF4A90C2),
                                      controller: waterController,
                                      compact: compact,
                                    ),

                                    SizedBox(height: compact ? 16 : 20),

                                    // Update Record button.
                                    SizedBox(
                                      width: double.infinity,
                                      height: compact ? 46 : 50,
                                      child: ElevatedButton(
                                        onPressed:
                                            isUpdating ? null : updateRecord,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          backgroundColor: _forestGreen,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              _forestGreen.withValues(alpha: 0.6),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: isUpdating
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Update Record',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Cancel button.
                                    SizedBox(
                                      width: double.infinity,
                                      height: compact ? 43 : 48,
                                      child: OutlinedButton(
                                        onPressed: isUpdating
                                            ? null
                                            : () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          foregroundColor: _forestGreen,
                                          side: const BorderSide(
                                            color: Color(0xFFE0E6E2),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 14,
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
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
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
                color: const Color(0xFF203C2B).withValues(alpha: 0.07),
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

  Widget _buildInputField({
    required String title,
    required String hint,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required bool compact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF234B3A),
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          enabled: !isUpdating,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF34483D),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9AA69E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            suffixText: unit,
            suffixStyle: const TextStyle(
              color: Color(0xFF718078),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAF8),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 12 : 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE0E6E2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF568568),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
