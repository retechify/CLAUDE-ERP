import 'dart:math';

import '../models/trade.dart';

class TradeAnalytics {
  TradeAnalytics(this.trades);

  final List<Trade> trades;

  double get totalPnl => trades.fold(0, (sum, trade) => sum + trade.pnl);

  double get winRate {
    if (trades.isEmpty) return 0;
    final wins = trades.where((trade) => trade.pnl > 0).length;
    return wins / trades.length * 100;
  }

  double get averageWin {
    final wins = trades
        .where((trade) => trade.pnl > 0)
        .map((trade) => trade.pnl);
    if (wins.isEmpty) return 0;
    return wins.reduce((a, b) => a + b) / wins.length;
  }

  double get averageLoss {
    final losses = trades
        .where((trade) => trade.pnl < 0)
        .map((trade) => trade.pnl);
    if (losses.isEmpty) return 0;
    return losses.reduce((a, b) => a + b) / losses.length;
  }

  double get riskRewardRatio {
    final valid = trades.where((trade) => trade.riskRewardRatio > 0);
    if (valid.isEmpty) return 0;
    return valid.fold(0.0, (sum, trade) => sum + trade.riskRewardRatio) /
        valid.length;
  }

  String get bestStrategy => _bestByAveragePnl(strategyGroups);

  Map<String, int> get mistakeCounts {
    final counts = <String, int>{};
    for (final trade in trades) {
      for (final mistake in trade.mistakes) {
        counts[mistake] = (counts[mistake] ?? 0) + 1;
      }
    }
    return _sortIntMap(counts);
  }

  Map<String, double> get weekdayPnl {
    final values = <String, double>{};
    for (final trade in trades) {
      values[trade.weekdayName] = (values[trade.weekdayName] ?? 0) + trade.pnl;
    }
    return values;
  }

  Map<String, double> get emotionPnl {
    final values = <String, double>{};
    for (final trade in trades) {
      values[trade.emotionBefore] =
          (values[trade.emotionBefore] ?? 0) + trade.pnl;
      values[trade.emotionAfter] =
          (values[trade.emotionAfter] ?? 0) + trade.pnl;
    }
    return values;
  }

  Map<String, List<Trade>> get strategyGroups {
    final groups = <String, List<Trade>>{};
    for (final trade in trades) {
      groups.putIfAbsent(trade.strategy, () => []).add(trade);
    }
    return groups;
  }

  List<double> get cumulativePnl {
    final sorted = [...trades]
      ..sort((a, b) => a.tradeDate.compareTo(b.tradeDate));
    var running = 0.0;
    return [for (final trade in sorted) running += trade.pnl];
  }

  String _bestByAveragePnl(Map<String, List<Trade>> groups) {
    if (groups.isEmpty) return 'No trades yet';
    var bestName = groups.keys.first;
    var bestAverage = -double.infinity;
    for (final entry in groups.entries) {
      final average =
          entry.value.fold(0.0, (sum, trade) => sum + trade.pnl) /
          max(entry.value.length, 1);
      if (average > bestAverage) {
        bestAverage = average;
        bestName = entry.key;
      }
    }
    return bestName;
  }

  Map<String, int> _sortIntMap(Map<String, int> values) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }
}
