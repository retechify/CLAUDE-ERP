import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/trade.dart';
import '../services/trade_service.dart';

class TradeProvider extends ChangeNotifier {
  TradeProvider({required TradeService tradeService})
    : _tradeService = tradeService;

  final TradeService _tradeService;

  StreamSubscription<List<Trade>>? _subscription;
  String? _userId;

  List<Trade> trades = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    trades = [];
    error = null;
    if (userId == null) {
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    _subscription = _tradeService
        .watchTrades(userId)
        .listen(
          (items) {
            trades = items;
            isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            error = 'Unable to load trades from local storage.';
            isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> saveTrade(Trade trade, {String? chartImageUrl}) async {
    if (_userId == null) return false;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final tradeToSave = trade.copyWith(chartImageUrl: chartImageUrl);
      if (trade.id.isEmpty) {
        await _tradeService.createTrade(tradeToSave);
      } else {
        await _tradeService.updateTrade(tradeToSave);
      }
      return true;
    } catch (_) {
      error = 'Unable to save trade locally.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrade(String tradeId) async {
    if (_userId == null) return;
    await _tradeService.deleteTrade(_userId!, tradeId);
  }

  List<Trade> filteredTrades({
    DateTime? start,
    DateTime? end,
    String? strategy,
    TradeOutcome? outcome,
  }) {
    return trades.where((trade) {
      final afterStart = start == null || !trade.tradeDate.isBefore(start);
      final beforeEnd = end == null || !trade.tradeDate.isAfter(end);
      final matchesStrategy =
          strategy == null ||
          strategy.isEmpty ||
          trade.strategy.toLowerCase().contains(strategy.toLowerCase());
      final matchesOutcome = outcome == null || trade.outcome == outcome;
      return afterStart && beforeEnd && matchesStrategy && matchesOutcome;
    }).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
