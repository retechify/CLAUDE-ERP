enum TradeOutcome { profit, loss, breakeven }

class Trade {
  Trade({
    required this.id,
    required this.userId,
    required this.tradeDate,
    required this.market,
    required this.instrument,
    required this.strategy,
    required this.setupType,
    required this.entryPrice,
    required this.exitPrice,
    required this.stopLoss,
    required this.target,
    required this.quantity,
    required this.risk,
    required this.pnl,
    required this.emotionBefore,
    required this.emotionAfter,
    required this.mistakes,
    required this.notes,
    this.chartImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String userId;
  final DateTime tradeDate;
  final String market;
  final String instrument;
  final String strategy;
  final String setupType;
  final double entryPrice;
  final double exitPrice;
  final double stopLoss;
  final double target;
  final int quantity;
  final double risk;
  final double pnl;
  final String emotionBefore;
  final String emotionAfter;
  final List<String> mistakes;
  final String notes;
  final String? chartImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  TradeOutcome get outcome {
    if (pnl > 0) return TradeOutcome.profit;
    if (pnl < 0) return TradeOutcome.loss;
    return TradeOutcome.breakeven;
  }

  double get reward => (target - entryPrice).abs() * quantity;
  double get riskRewardRatio => risk == 0 ? 0 : reward / risk;
  String get weekdayName => _weekdays[tradeDate.weekday - 1];

  Trade copyWith({String? id, String? chartImageUrl, DateTime? updatedAt}) {
    return Trade(
      id: id ?? this.id,
      userId: userId,
      tradeDate: tradeDate,
      market: market,
      instrument: instrument,
      strategy: strategy,
      setupType: setupType,
      entryPrice: entryPrice,
      exitPrice: exitPrice,
      stopLoss: stopLoss,
      target: target,
      quantity: quantity,
      risk: risk,
      pnl: pnl,
      emotionBefore: emotionBefore,
      emotionAfter: emotionAfter,
      mistakes: mistakes,
      notes: notes,
      chartImageUrl: chartImageUrl ?? this.chartImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tradeDate': tradeDate.toIso8601String(),
      'market': market,
      'instrument': instrument,
      'strategy': strategy.trim(),
      'setupType': setupType,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'stopLoss': stopLoss,
      'target': target,
      'quantity': quantity,
      'risk': risk,
      'pnl': pnl,
      'emotionBefore': emotionBefore,
      'emotionAfter': emotionAfter,
      'mistakes': mistakes,
      'notes': notes.trim(),
      'chartImageUrl': chartImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Trade.fromJson(Map<String, dynamic> data) {
    return Trade(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      tradeDate: _readDate(data['tradeDate']),
      market: data['market'] as String? ?? '',
      instrument: data['instrument'] as String? ?? '',
      strategy: data['strategy'] as String? ?? '',
      setupType: data['setupType'] as String? ?? '',
      entryPrice: _readDouble(data['entryPrice']),
      exitPrice: _readDouble(data['exitPrice']),
      stopLoss: _readDouble(data['stopLoss']),
      target: _readDouble(data['target']),
      quantity: _readInt(data['quantity']),
      risk: _readDouble(data['risk']),
      pnl: _readDouble(data['pnl']),
      emotionBefore: data['emotionBefore'] as String? ?? '',
      emotionAfter: data['emotionAfter'] as String? ?? '',
      mistakes: List<String>.from(data['mistakes'] as List? ?? const []),
      notes: data['notes'] as String? ?? '',
      chartImageUrl: data['chartImageUrl'] as String?,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static double _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _readInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
