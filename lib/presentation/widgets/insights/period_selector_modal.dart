import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PeriodSelectionResult {
  const PeriodSelectionResult({
    required this.label,
    required this.selectedDate,
  });

  final String label;
  final DateTime selectedDate;
}

class PeriodSelectorModal extends StatefulWidget {
  const PeriodSelectorModal({
    super.key,
    required this.initialPeriod,
    required this.onSelected,
  });

  final String initialPeriod;
  final ValueChanged<PeriodSelectionResult> onSelected;

  static Future<void> show(
    BuildContext context, {
    required String currentPeriod,
    required ValueChanged<PeriodSelectionResult> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => PeriodSelectorModal(
        initialPeriod: currentPeriod,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<PeriodSelectorModal> createState() => _PeriodSelectorModalState();
}

class _PeriodSelectorModalState extends State<PeriodSelectorModal> {
  // Figma Design System Tokens
  static const Color brandPurple = Color(0xFF6347D1);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color neutralHandle = Color(0xFFD2D2D2);

  static const List<String> shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> fullMonths = [
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

  late final List<int> years;
  late int selectedMonthIndex;
  late int selectedDay;
  late int selectedYear;

  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    years = List.generate(11, (index) => 2020 + index); // 2020 - 2030

    final parsed = _parseDateFromPeriod(widget.initialPeriod);
    selectedMonthIndex = parsed.month - 1;
    selectedDay = parsed.day;
    selectedYear = parsed.year;

    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _monthController = FixedExtentScrollController(
      initialItem: selectedMonthIndex,
    );
    final yearIdx = years.indexOf(selectedYear);
    _yearController = FixedExtentScrollController(
      initialItem: yearIdx >= 0 ? yearIdx : 6,
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime _parseDateFromPeriod(String period) {
    int year = 2026;
    int month = 3; // Default March as per screen
    int day = 1;

    final yearRegex = RegExp(r'\b(20\d{2})\b');
    final match = yearRegex.firstMatch(period);
    if (match != null) {
      year = int.parse(match.group(1)!);
    }

    final lower = period.toLowerCase();
    for (int i = 0; i < fullMonths.length; i++) {
      if (lower.contains(fullMonths[i].toLowerCase()) ||
          lower.contains(shortMonths[i].toLowerCase())) {
        month = i + 1;
        break;
      }
    }
    return DateTime(year, month, day);
  }

  int _daysInCurrentMonth() {
    return DateUtils.getDaysInMonth(selectedYear, selectedMonthIndex + 1);
  }

  void _onConfirm() {
    final maxDays = _daysInCurrentMonth();
    final safeDay = selectedDay > maxDays ? maxDays : selectedDay;
    final picked = DateTime(selectedYear, selectedMonthIndex + 1, safeDay);

    widget.onSelected(
      PeriodSelectionResult(
        label: '${shortMonths[selectedMonthIndex]} $selectedYear',
        selectedDate: picked,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final daysCount = _daysInCurrentMonth();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: 343,
          height: 445,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 343,
              height: 445,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E1E1B4B),
                    blurRadius: 36,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull Handle Bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: neutralHandle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Select Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // 3-Wheel Picker (Day | Month | Year)
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.28, 0.72, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Row(
                        children: [
                          // 1. Day Wheel (Left) - Formatted with 2-digit padding '01'
                          Expanded(
                            flex: 3,
                            child: CupertinoPicker(
                              scrollController: _dayController,
                              itemExtent: 44,
                              magnification: 1.1,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (index) {
                                setState(() => selectedDay = index + 1);
                              },
                              children: List.generate(daysCount, (i) {
                                final dayStr = (i + 1).toString().padLeft(
                                  2,
                                  '0',
                                );
                                return Center(
                                  child: Text(
                                    dayStr,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // 2. Month Wheel (Middle) - Short Name Format (Jan, Feb...)
                          Expanded(
                            flex: 4,
                            child: CupertinoPicker(
                              scrollController: _monthController,
                              itemExtent: 44,
                              magnification: 1.1,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedMonthIndex = index;
                                  if (selectedDay > _daysInCurrentMonth()) {
                                    selectedDay = _daysInCurrentMonth();
                                  }
                                });
                              },
                              children: shortMonths.map((m) {
                                return Center(
                                  child: Text(
                                    m,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // 3. Year Wheel (Right)
                          Expanded(
                            flex: 4,
                            child: CupertinoPicker(
                              scrollController: _yearController,
                              itemExtent: 44,
                              magnification: 1.1,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (index) {
                                setState(() => selectedYear = years[index]);
                              },
                              children: years.map((y) {
                                return Center(
                                  child: Text(
                                    '$y',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Select',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
