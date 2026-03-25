import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _OverviewTab(),
          _CategoriesTab(
            touchedIndex: _touchedIndex,
            onTouch: (i) => setState(() => _touchedIndex = i),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final data = provider.last6Months;

    if (data.isEmpty) {
      return const Center(
        child: Text('No data yet', style: TextStyle(color: Colors.white54)),
      );
    }

    final maxVal = data.fold<double>(
      0,
      (m, d) => [
        m,
        d['income'] as double,
        d['expense'] as double,
      ].reduce((a, b) => a > b ? a : b),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 6 Months',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 260,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, _) => Text(
                        Formatters.compact(value),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox();
                        }
                        final month = DateTime(
                          data[i]['year'] as int,
                          data[i]['month'] as int,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            Formatters.month(month),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: data[i]['income'] as double,
                        color: AppTheme.incomeColor,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: data[i]['expense'] as double,
                        color: AppTheme.expenseColor,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _Legend(color: AppTheme.incomeColor, label: 'Income'),
              SizedBox(width: 20),
              _Legend(color: AppTheme.expenseColor, label: 'Expense'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Monthly Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...data.reversed.map((d) {
            final income = d['income'] as double;
            final expense = d['expense'] as double;
            final savings = income - expense;
            final month = DateTime(d['year'] as int, d['month'] as int);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.monthYear(month),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${Formatters.compact(income)}',
                        style: const TextStyle(
                          color: AppTheme.incomeColor,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '-${Formatters.compact(expense)}',
                        style: const TextStyle(
                          color: AppTheme.expenseColor,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '=${Formatters.compact(savings)}',
                        style: TextStyle(
                          color: savings >= 0
                              ? AppTheme.incomeColor
                              : AppTheme.expenseColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _CategoriesTab({required this.touchedIndex, required this.onTouch});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final spending = provider.categorySpending;
    final total = spending.fold<double>(0, (s, d) => s + (d['total'] as num));

    if (spending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📊', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'No expense data this month',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    final sections = spending.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;
      final pct = (d['total'] as num) / total;
      final isTouched = touchedIndex == i;
      return PieChartSectionData(
        color: Color(d['color'] as int),
        value: (d['total'] as num).toDouble(),
        title: isTouched ? '${(pct * 100).toStringAsFixed(1)}%' : '',
        radius: isTouched ? 80 : 65,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        badgeWidget: isTouched
            ? Text(d['icon'] as String, style: const TextStyle(fontSize: 18))
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sections: sections,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (response?.touchedSection != null) {
                      onTouch(response!.touchedSection!.touchedSectionIndex);
                    } else {
                      onTouch(-1);
                    }
                  },
                ),
                centerSpaceRadius: 50,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Category Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...spending.asMap().entries.map((entry) {
            final d = entry.value;
            final pct = ((d['total'] as num) / total * 100);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: touchedIndex == entry.key
                    ? Border.all(color: Color(d['color'] as int), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    d['icon'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(d['color'] as int),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency((d['total'] as num).toDouble()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
