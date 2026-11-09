import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/health_record.dart';

class ViewListScreen extends StatelessWidget {
  final HealthRecord record;

  const ViewListScreen({
    super.key,
    required this.record,
  });

  static const Color _darkGreen = Color(0xFF1E3A2B);
  static const Color _forestGreen = Color(0xFF245640);
  static const Color _mediumGreen = Color(0xFF3D795B);
  static const Color _mutedGreen = Color(0xFF52665B);
  static const Color _glassColor = Color(0xFFDDEBDD);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMMM yyyy').format(DateTime.parse(record.date));

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
                    image: AssetImage(
                      'assets/images/fitness_background.jpeg',
                    ),
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

            // Main content.
            SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool compact = constraints.maxHeight < 700;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 550,
                          minHeight:
                              constraints.maxHeight - (compact ? 10 : 20),
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Separate heading glass card.
                              _buildGlassCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 23,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.health_and_safety_rounded,
                                          color: _forestGreen,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 8),
                                        const Flexible(
                                          child: Text(
                                            'View Health Record',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _darkGreen,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Review your daily health activity.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _mutedGreen,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Record information glass card.
                              _buildGlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Record date.
                                    const Text(
                                      'Record Date',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _darkGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildGlassCard(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 15,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.58,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.calendar_month_rounded,
                                              color: _forestGreen,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: _darkGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // Activity details.
                                    const Text(
                                      'Activity Details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: _darkGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildDetailCard(
                                      icon: Icons.directions_walk_rounded,
                                      title: 'Daily Steps',
                                      value: NumberFormat('#,###')
                                          .format(record.steps),
                                      unit: 'steps',
                                      iconColor: _mediumGreen,
                                    ),
                                    const SizedBox(height: 13),
                                    _buildDetailCard(
                                      icon: Icons.local_fire_department_rounded,
                                      title: 'Calories Burned',
                                      value: NumberFormat('#,###')
                                          .format(record.calories),
                                      unit: 'kcal',
                                      iconColor: const Color(0xFFE89B69),
                                    ),
                                    const SizedBox(height: 13),
                                    _buildDetailCard(
                                      icon: Icons.water_drop_rounded,
                                      title: 'Water Intake',
                                      value: NumberFormat('#,###')
                                          .format(record.waterMl),
                                      unit: 'ml',
                                      iconColor: const Color(0xFF69A9C7),
                                    ),
                                                                        const SizedBox(height: 20),

                                    // Information message.
                                    _buildGlassCard(
                                      padding: const EdgeInsets.all(15),
                                      child: const Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: _forestGreen,
                                            size: 23,
                                          ),
                                          SizedBox(width: 11),
                                          Expanded(
                                            child: Text(
                                              'Keep tracking your daily activities to monitor your health progress over time.',
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.5,
                                                fontWeight: FontWeight.w600,
                                                color: _mutedGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Back to Health History.
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          size: 21,
                                        ),
                                        label: const Text(
                                          'Back to Health History',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _forestGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(13),
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

  // Reusable glass-effect card.
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

  // Reusable activity detail card.
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color iconColor,
  }) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _mutedGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _mutedGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}