import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import '../controllers/health_provider.dart';
import '../models/health_record.dart';
import 'add_details_screen.dart';
import 'edit_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'view_list_screen.dart';

class ListScreen extends StatefulWidget {
  final int userId;

  const ListScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {


  List<HealthRecord> healthRecords = [];

  DateTime? selectedDate;

  bool newestFirst = true;
  bool isLoading = true;
  String? errorMessage;

  static const Color _darkGreen = Color(0xFF1E3A2B);
  static const Color _forestGreen = Color(0xFF245640);
  static const Color _mediumGreen = Color(0xFF3D795B);
  static const Color _mutedGreen = Color(0xFF52665B);
  static const Color _glassColor = Color(0xFFDDEBDD);

  final NumberFormat _numberFormat = NumberFormat('#,##0');

  @override
  void initState() {
    super.initState();



    loadRecords();
  }

  // Retrieve health records from the database.
  Future<void> loadRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
  final healthProvider = context.read<HealthProvider>();

  List<HealthRecord> records;

  if (selectedDate != null) {
    final formattedDate = formatDatabaseDate(selectedDate!);

    await healthProvider.searchRecordsByDate(formattedDate);

    records = healthProvider.searchResults;
  } else {
    await healthProvider.loadRecords(
      newestFirst: newestFirst,
    );

    records = healthProvider.healthRecords;
  }

      if (!mounted) return;

      setState(() {
        healthRecords = records;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load health records. Please try again.';
        isLoading = false;
      });

      debugPrint('LOAD RECORDS ERROR: $error');
    }
  }

  // Format a date for SQLite.
  String formatDatabaseDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Display the date in a readable format.
  String formatDisplayDate(String date) {
    final parsedDate = DateTime.parse(date);

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

    return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
  }

  // Select a date to filter health records.
  Future<void> selectFilterDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      await loadRecords();
    }
  }

  // Remove the date filter.
  Future<void> clearDateFilter() async {
    setState(() {
      selectedDate = null;
    });

    await loadRecords();
  }

  // Show delete confirmation.
  void confirmDelete(HealthRecord record) {
    final displayDate = formatDisplayDate(record.date);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5FAF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Record?',
            style: TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete the health record for $displayDate?',
            style: const TextStyle(
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
                  color: _mutedGreen,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  if (record.id == null) {
                    throw Exception('Record ID is missing.');
                  }

                  await context.read<HealthProvider>().deleteRecord(record.id!);

                  if (!mounted) return;

                  await loadRecords();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Health record deleted successfully!'),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;

                  debugPrint('DELETE RECORD ERROR: $error');

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to delete the health record. Please try again.',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
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

  // Reusable glass-effect card matching the Dashboard.
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

  // Reusable section heading matching the Dashboard.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkGreen,
        letterSpacing: -0.4,
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEE5),

      // Background image and glass-effect content.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fitness_background.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(230, 238, 229, 0.48),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 550,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Health History header.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          8,
                        ),
                        child: _buildGlassCard(
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
                                  const Icon(
                                    Icons.history_rounded,
                                    color: _forestGreen,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Health History',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _darkGreen,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'View and manage your daily health records.',
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
                      ),

                      // History content.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          13,
                          16,
                          20,
                        ),
                        child: _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Health Records'),

                              const SizedBox(height: 6),

                              const Text(
                                'Keep track of your daily health progress.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _mutedGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Date filter and sorting.
                              _buildDateFilter(),

                              const SizedBox(height: 18),

                              // Record count.
                              Text(
                                selectedDate == null
                                    ? '${healthRecords.length} record(s) found'
                                    : '${healthRecords.length} record(s) found for selected date',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _mutedGreen,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Loading, error, empty or record list.
                              if (isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: _forestGreen,
                                    ),
                                  ),
                                )
                              else if (errorMessage != null)
                                _buildMessage(
                                  icon: Icons.error_outline,
                                  message: errorMessage!,
                                  buttonText: 'Try Again',
                                  onPressed: loadRecords,
                                )
                              else if (healthRecords.isEmpty)
                                _buildMessage(
                                  icon: Icons.history_rounded,
                                  message: selectedDate == null
                                      ? 'No health records found. Add your first daily record to get started.'
                                      : 'No health records found for ${formatDisplayDate(formatDatabaseDate(selectedDate!))}.',
                                  buttonText: selectedDate == null
                                      ? 'Refresh'
                                      : 'Show All Records',
                                  onPressed: selectedDate == null
                                      ? loadRecords
                                      : clearDateFilter,
                                )
                              else
                                ...healthRecords.map(
                                  (record) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 14,
                                    ),
                                    child: _buildRecordCard(record),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Dashboard-style glass bottom navigation.
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

  // Date filtering and sorting section.
  Widget _buildDateFilter() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: _forestGreen,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Filter by Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : selectFilterDate,
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                  ),
                  label: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : formatDisplayDate(
                            formatDatabaseDate(selectedDate!),
                          ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _forestGreen,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear date filter',
                  onPressed: isLoading ? null : clearDateFilter,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFFD9534F),
                    size: 23,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Sort Records',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkGreen,
            ),
          ),

          const SizedBox(height: 9),

          DropdownButtonFormField<bool>(
            initialValue: newestFirst,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.sort_rounded,
                color: _forestGreen,
              ),
              filled: true,
              fillColor: const Color(0xFFDDEBDD).withValues(alpha: 0.85),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            items: const [
              DropdownMenuItem<bool>(
                value: true,
                child: Text(
                  'Newest First',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              DropdownMenuItem<bool>(
                value: false,
                child: Text(
                  'Oldest First',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
            onChanged: isLoading
                ? null
                : (value) async {
                    if (value == null) return;

                    setState(() {
                      newestFirst = value;
                    });

                    await loadRecords();
                  },
          ),
        ],
      ),
    );
  }
    // Display loading-independent messages.
  Widget _buildMessage({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: _mutedGreen.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _mutedGreen,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _forestGreen,
                side: const BorderSide(
                  color: _forestGreen,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Individual health record card.
  Widget _buildRecordCard(HealthRecord record) {
    final String displayDate = formatDisplayDate(record.date);

    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Record date.
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: _forestGreen,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(
            color: _darkGreen.withValues(alpha: 0.13),
            height: 1,
          ),

          const SizedBox(height: 16),

          // Health details.
          _buildRecordDetail(
            icon: Icons.directions_walk_rounded,
            title: 'Daily Steps',
            value: _numberFormat.format(record.steps),
            iconColor: _mediumGreen,
          ),

          const SizedBox(height: 14),

          _buildRecordDetail(
            icon: Icons.local_fire_department_rounded,
            title: 'Calories Burned',
            value: '${_numberFormat.format(record.calories)} kcal',
            iconColor: const Color(0xFFE89B69),
          ),

          const SizedBox(height: 14),

          _buildRecordDetail(
            icon: Icons.water_drop_rounded,
            title: 'Water Intake',
            value: '${_numberFormat.format(record.waterMl)} ml',
            iconColor: const Color(0xFF69A9C7),
          ),

          const SizedBox(height: 19),

          // View details.
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewListScreen(record: record),
                  ),
                );

                await loadRecords();
              },
              icon: const Icon(
                Icons.visibility_outlined,
                size: 20,
              ),
              label: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          // Edit record.
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditScreen(
                      record: record,
                      userId: widget.userId,
                    ),
                  ),
                );

                await loadRecords();
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
              ),
              label: const Text(
                'Edit Record',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _forestGreen,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          // Delete record.
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                confirmDelete(record);
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
              ),
              label: const Text(
                'Delete Record',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD9534F),
                side: const BorderSide(
                  color: Color(0xFFE6B8B6),
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual record detail.
  Widget _buildRecordDetail({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: _mutedGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = index == 2;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      hoverColor: const Color(0xFFE6EEE5),
      splashColor: const Color(0xFFD5E5D7),
      onTap: () async {
        
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
      }
        else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddDetailsScreen(userId: widget.userId),
            ),
          );
        
        } else if (index == 2) {
          await loadRecords();
        } else if (index == 3) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(userId: widget.userId),
            ),
          );

          if (mounted) {
            await loadRecords();
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