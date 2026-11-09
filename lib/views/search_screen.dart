
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../controllers/health_provider.dart';
import '../models/health_record.dart';
import 'add_details_screen.dart';
import 'list_screen.dart';
import 'login_screen.dart';

class SearchScreen extends StatefulWidget {
  final int userId;

  const SearchScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {


  DateTime? selectedDate;
  bool hasSearched = false;
  bool isSearching = false;

  List<HealthRecord> searchResults = [];

  static const Color _darkGreen = Color(0xFF1E3A2B);
  static const Color _forestGreen = Color(0xFF245640);
  static const Color _mediumGreen = Color(0xFF3D795B);
  static const Color _mutedGreen = Color(0xFF52665B);
  static const Color _glassColor = Color(0xFFDDEBDD);



  // Format date for display.
  String formatDate(DateTime date) {
    const months = [
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

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  // Format date for database search.
  String formatDatabaseDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Select search date.
  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        hasSearched = false;
        searchResults = [];
      });
    }
  }

  // Search records for selected date.
  Future<void> searchRecords() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date first.'),
        ),
      );
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final formattedDate = formatDatabaseDate(selectedDate!);

      final healthProvider = context.read<HealthProvider>();

        await healthProvider.searchRecordsByDate(formattedDate);

        if (!mounted) return;

        setState(() {
          searchResults = healthProvider.searchResults;
          hasSearched = true;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to search records: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  // Clear search.
  void clearSearch() {
    setState(() {
      selectedDate = null;
      hasSearched = false;
      searchResults = [];
    });
  }

  // Reusable glass card.
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
                style: TextStyle(
                  color: _forestGreen,
                ),
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
      // Return to Dashboard.
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } else if (index == 1) {
      // Open Add Health Record.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddDetailsScreen(
            userId: widget.userId,
          ),
        ),
      );
    } else if (index == 2) {
      // Open Health History.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListScreen(
            userId: widget.userId,
          ),
        ),
      );
    } else if (index == 3) {
      // Search is already the active page.
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
    final bool isSelected = index == 3;

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
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen fitness background image.
          Image.asset(
            'assets/images/fitness_background.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // Soft green overlay.
          Container(
            color: const Color.fromRGBO(230, 238, 229, 0.48),
          ),

          // Main page content.
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    compact ? 2 : 8,
                    16,
                    // Extra space allows the final content to scroll
                    // above the bottom navigation bar.
                    MediaQuery.of(context).padding.bottom + 110,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 550,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F0E9),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.search_rounded,
                                        color: _forestGreen,
                                        size: 27,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Flexible(
                                      child: Text(
                                        'Search Records',
                                        textAlign: TextAlign.center,
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
                                  'Find your health activity using a specific date.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _mutedGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: compact ? 12 : 16),

                          // Main search and results glass card.
                          _buildGlassCard(
                            padding: EdgeInsets.all(compact ? 15 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date label.
                                const Text(
                                  'Select Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _darkGreen,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                // Date picker.
                                InkWell(
                                  onTap: selectDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: compact ? 11 : 16,
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
                                          Icons.calendar_month_outlined,
                                          color: _darkGreen,
                                          size: 21,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            selectedDate == null
                                                ? 'Choose a date'
                                                : formatDate(selectedDate!),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF555555),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF718078),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: compact ? 16 : 20),

                                // Search button.
                                SizedBox(
                                  width: double.infinity,
                                  height: compact ? 46 : 50,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        isSearching ? null : searchRecords,
                                    icon: isSearching
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.search,
                                            size: 21,
                                          ),
                                    label: Text(
                                      isSearching
                                          ? 'Searching...'
                                          : 'Search Records',
                                      style: const TextStyle(
                                        fontSize: 13,
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
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Clear button.
                                SizedBox(
                                  width: double.infinity,
                                  height: compact ? 43 : 48,
                                  child: OutlinedButton(
                                    onPressed: clearSearch,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _forestGreen,
                                      side: const BorderSide(
                                        color: Color(0xFFE0E6E2),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear Search',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: compact ? 20 : 25),

                                const Divider(
                                  color: Color(0xFFE5EAE6),
                                  height: 1,
                                ),

                                SizedBox(height: compact ? 16 : 20),

                                // Search results heading.
                                const Text(
                                  'Search Results',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _darkGreen,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  'Your health records for the selected date.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _mutedGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                if (isSearching)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: _forestGreen,
                                      ),
                                    ),
                                  )
                                else if (!hasSearched)
                                  _buildMessage(
                                    Icons.search_outlined,
                                    'No search performed yet',
                                    'Select a date above to find your health records.',
                                  )
                                else if (searchResults.isEmpty)
                                  _buildMessage(
                                    Icons.event_busy_outlined,
                                    'No records found',
                                    'There are no health records for the selected date.',
                                  )
                                else
                                  ...searchResults.map(
                                    (record) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildResultCard(record),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
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

  // Search message card.
  Widget _buildMessage(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 25,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E6E2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: const Color(0xFF8AA58E),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _mutedGreen,
            ),
          ),
        ],
      ),
    );
  }

  // Search result card.
  Widget _buildResultCard(HealthRecord record) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E6E2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: _mediumGreen,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  formatDate(DateTime.parse(record.date)),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _darkGreen,
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            height: 22,
            color: Color(0xFFE0E6E2),
          ),

          _buildResultDetail(
            Icons.directions_walk,
            'Steps',
            record.steps.toString(),
          ),

          const SizedBox(height: 12),

          _buildResultDetail(
            Icons.local_fire_department_outlined,
            'Calories Burned',
            '${record.calories} kcal',
          ),

          const SizedBox(height: 12),

          _buildResultDetail(
            Icons.water_drop_outlined,
            'Water Intake',
            '${record.waterMl} ml',
          ),
        ],
      ),
    );
  }

  // Individual search result details.
  Widget _buildResultDetail(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF78947D),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: _mutedGreen,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkGreen,
          ),
        ),
      ],
    );
  }
}
