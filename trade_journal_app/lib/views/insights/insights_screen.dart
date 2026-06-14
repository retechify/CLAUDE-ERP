import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trade_provider.dart';
import '../../utils/trade_analytics.dart';
import '../../widgets/empty_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trades = context.watch<TradeProvider>().trades;
    if (trades.isEmpty) {
      return const EmptyState(
        icon: Icons.psychology_alt_outlined,
        title: 'Insights need data',
        message: 'Log trades with emotions and mistakes to reveal patterns.',
      );
    }

    final analytics = TradeAnalytics(trades);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InsightTile(
          title: 'Best performing strategy',
          value: analytics.bestStrategy,
          icon: Icons.trending_up,
        ),
        _MapInsight(
          title: 'Worst mistakes',
          emptyText: 'No mistakes selected yet.',
          values: analytics.mistakeCounts.map(
            (key, value) => MapEntry(key, value.toDouble()),
          ),
        ),
        _MapInsight(
          title: 'Performance by weekday',
          emptyText: 'No weekday data yet.',
          values: analytics.weekdayPnl,
          currency: true,
        ),
        _MapInsight(
          title: 'Emotion vs profit',
          emptyText: 'No emotion data yet.',
          values: analytics.emotionPnl,
          currency: true,
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _MapInsight extends StatelessWidget {
  const _MapInsight({
    required this.title,
    required this.emptyText,
    required this.values,
    this.currency = false,
  });

  final String title;
  final String emptyText;
  final Map<String, double> values;
  final bool currency;

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (entries.isEmpty)
              Text(emptyText)
            else
              for (final entry in entries.take(6))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      Text(
                        currency
                            ? '₹${entry.value.toStringAsFixed(2)}'
                            : entry.value.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: currency && entry.value < 0
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
