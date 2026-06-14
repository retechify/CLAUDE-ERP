import 'package:flutter_test/flutter_test.dart';
import 'package:trade_journal_app/utils/trade_calculator.dart';

void main() {
  test('calculates risk from entry, stop loss, and quantity', () {
    final risk = TradeCalculator.calculateRisk(
      entryPrice: 100,
      stopLoss: 95,
      quantity: 50,
    );

    expect(risk, 250);
  });

  test('calculates pnl from entry, exit, and quantity', () {
    final pnl = TradeCalculator.calculatePnl(
      entryPrice: 100,
      exitPrice: 108,
      quantity: 25,
    );

    expect(pnl, 200);
  });
}
