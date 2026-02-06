import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
// Using provider data instead of DummyData

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final analyticsProvider =
        Provider.of<AnalyticsProvider>(context, listen: false);
    await analyticsProvider.initialize('current_event');
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.softTealBlue,
              surface: Color(0xFF1A3A5C),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F253D),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      final analyticsProvider =
          Provider.of<AnalyticsProvider>(context, listen: false);
      await analyticsProvider.loadHistoricalData(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, _) {
          if (analyticsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.softTealBlue),
            );
          }

          return RefreshIndicator(
            onRefresh: () => analyticsProvider.loadHistoricalData(
                _startDate, _endDate),
            color: AppColors.softTealBlue,
            backgroundColor: AppColors.deepNavyBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Picker
                  _DateRangeBar(
                    startDate: _startDate,
                    endDate: _endDate,
                    onTap: _selectDateRange,
                  ),
                  const SizedBox(height: 20),

                  // Summary Stats Cards
                  _SummaryStatsSection(
                    analyticsProvider: analyticsProvider,
                  ),
                  const SizedBox(height: 20),

                  // Crowd Density Over Time (Line Chart)
                  _DensityLineChart(
                    data: analyticsProvider.hourlyDensityData,
                  ),
                  const SizedBox(height: 20),

                  // Incidents by Type (Bar Chart)
                  _IncidentBarChart(
                    data: analyticsProvider.incidentStats,
                  ),
                  const SizedBox(height: 20),

                  // Zone Occupancy Distribution (Pie Chart)
                  _ZoneOccupancyPieChart(
                    data: analyticsProvider.zoneComparisonData,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== DATE RANGE BAR ====================
class _DateRangeBar extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onTap;

  const _DateRangeBar({
    required this.startDate,
    required this.endDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.softTealBlue,
                size: 20),
            const SizedBox(width: 12),
            Text(
              '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

// ==================== SUMMARY STATS ====================
class _SummaryStatsSection extends StatelessWidget {
  final AnalyticsProvider analyticsProvider;

  const _SummaryStatsSection({required this.analyticsProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryStatCard(
                title: 'Total Incidents',
                value: '${analyticsProvider.totalIncidents}',
                icon: Icons.report_problem_outlined,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryStatCard(
                title: 'Avg Response',
                value: '${analyticsProvider.avgResponseTime.toStringAsFixed(1)}m',
                icon: Icons.timer_outlined,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryStatCard(
                title: 'Peak Attendance',
                value: _formatNumber(analyticsProvider.peakAttendance),
                icon: Icons.groups_outlined,
                color: AppColors.softTealBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryStatCard(
                title: 'Alerts Sent',
                value: '${analyticsProvider.alertsSent}',
                icon: Icons.campaign_outlined,
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== DENSITY LINE CHART ====================
class _DensityLineChart extends StatelessWidget {
  final List<HourlyDensityPoint> data;

  const _DensityLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crowd Density Over Time',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Average people per m\u00B2 by hour',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No density data available',
                      style: GoogleFonts.roboto(
                          fontSize: 14, color: Colors.white38),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1.0,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.08),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 1.0,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: 4,
                            getTitlesWidget: (value, meta) {
                              final hour = value.toInt();
                              if (hour % 4 != 0) return const SizedBox.shrink();
                              return Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 23,
                      minY: 0,
                      maxY: 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.map((point) {
                            return FlSpot(
                              point.hour.toDouble(),
                              point.averageDensity,
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppColors.softTealBlue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.softTealBlue.withOpacity(0.15),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: const Color(0xFF1A3A5C),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toStringAsFixed(1)} p/m\u00B2\n${spot.x.toInt().toString().padLeft(2, '0')}:00',
                                GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          // Density threshold legend
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ChartLegendItem(label: 'Safe (<1.5)', color: AppColors.green),
              _ChartLegendItem(
                  label: 'Moderate', color: AppColors.yellow),
              _ChartLegendItem(label: 'High', color: AppColors.orange),
              _ChartLegendItem(
                  label: 'Critical (>4.5)', color: AppColors.red),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== INCIDENT BAR CHART ====================
class _IncidentBarChart extends StatelessWidget {
  final List<IncidentTypeData> data;

  const _IncidentBarChart({required this.data});

  Color _getColorForType(String type) {
    switch (type) {
      case 'medical':
        return AppColors.red;
      case 'security':
        return AppColors.orange;
      case 'overcrowding':
        return AppColors.yellow;
      case 'other':
        return AppColors.blue;
      default:
        return AppColors.softTealBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incidents by Type',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total incidents breakdown',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No incident data available',
                      style: GoogleFonts.roboto(
                          fontSize: 14, color: Colors.white38),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.08),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < data.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    data[index].displayName,
                                    style: GoogleFonts.roboto(
                                      fontSize: 10,
                                      color: Colors.white54,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: item.count.toDouble(),
                              color: _getColorForType(item.type),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: const Color(0xFF1A3A5C),
                          getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                            final item = data[group.x.toInt()];
                            return BarTooltipItem(
                              '${item.displayName}\n${item.count} incidents',
                              GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ChartLegendItem(label: 'Medical', color: AppColors.red),
              _ChartLegendItem(label: 'Security', color: AppColors.orange),
              _ChartLegendItem(
                  label: 'Overcrowding', color: AppColors.yellow),
              _ChartLegendItem(label: 'Other', color: AppColors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== ZONE OCCUPANCY PIE CHART ====================
class _ZoneOccupancyPieChart extends StatelessWidget {
  final List<ZoneComparisonData> data;

  const _ZoneOccupancyPieChart({required this.data});

  static const List<Color> _pieColors = [
    AppColors.softTealBlue,
    AppColors.blue,
    AppColors.orange,
    AppColors.green,
    AppColors.red,
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
    AppColors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    final totalDensity =
        data.fold<double>(0, (sum, z) => sum + z.averageDensity);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zone Occupancy Distribution',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Average density by zone',
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No zone data available',
                      style: GoogleFonts.roboto(
                          fontSize: 14, color: Colors.white38),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final zone = entry.value;
                        final percentage = totalDensity > 0
                            ? (zone.averageDensity / totalDensity * 100)
                            : 0.0;
                        return PieChartSectionData(
                          value: zone.averageDensity,
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: _pieColors[index % _pieColors.length],
                          radius: 55,
                          titleStyle: GoogleFonts.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          // Zone legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.asMap().entries.map((entry) {
              final index = entry.key;
              final zone = entry.value;
              return _ChartLegendItem(
                label: zone.zoneName,
                color: _pieColors[index % _pieColors.length],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ==================== CHART LEGEND ITEM ====================
class _ChartLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _ChartLegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
