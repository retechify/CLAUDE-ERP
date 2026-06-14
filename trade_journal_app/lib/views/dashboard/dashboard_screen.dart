import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trade_provider.dart';
import '../../utils/trade_analytics.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tradeProvider = context.watch<TradeProvider>();
    if (tradeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tradeProvider.trades.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart,
        title: 'No trades recorded',
        message: 'Add your first trade to unlock dashboard metrics.',
      );
    }

    final analytics = TradeAnalytics(tradeProvider.trades);
    final isProfit = analytics.totalPnl >= 0;
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MetricCard(
                title: 'Total P&L',
                value: '₹${analytics.totalPnl.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: isProfit ? Colors.green : Colors.red,
              ),
              MetricCard(
                title: 'Win rate',
                value: '${analytics.winRate.toStringAsFixed(1)}%',
                icon: Icons.emoji_events_outlined,
              ),
              MetricCard(
                title: 'Avg win / loss',
                value:
                    '₹${analytics.averageWin.toStringAsFixed(0)} / ₹${analytics.averageLoss.toStringAsFixed(0)}',
                icon: Icons.compare_arrows,
              ),
              MetricCard(
                title: 'Risk reward',
                value: '1:${analytics.riskRewardRatio.toStringAsFixed(2)}',
                icon: Icons.speed_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 240,
                    child: _PerformanceChart(values: analytics.cumulativePnl),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return const Center(
        child: Text('Add more trades to draw the equity curve.'),
      );
    }
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        minY: minY == maxY ? minY - 10 : minY,
        maxY: minY == maxY ? maxY + 10 : maxY,
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            barWidth: 3,
            color: Theme.of(context).colorScheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
