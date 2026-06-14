class TradeCalculator {
  static double calculateRisk({
    required double entryPrice,
    required double stopLoss,
    required int quantity,
  }) {
    return (entryPrice - stopLoss).abs() * quantity;
  }

  static double calculatePnl({
    required double entryPrice,
    required double exitPrice,
    required int quantity,
  }) {
    return (exitPrice - entryPrice) * quantity;
  }
}
