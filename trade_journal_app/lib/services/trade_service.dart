import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/trade.dart';

class TradeService {
  final _controllers = <String, StreamController<List<Trade>>>{};
  final _uuid = const Uuid();

  Stream<List<Trade>> watchTrades(String userId) {
    final controller = _controllers.putIfAbsent(
      userId,
      () => StreamController<List<Trade>>.broadcast(),
    );
    _emit(userId);
    return controller.stream;
  }

  Future<String> createTrade(Trade trade) async {
    final id = trade.id.isEmpty ? _uuid.v4() : trade.id;
    final savedTrade = trade.copyWith(id: id, updatedAt: DateTime.now());
    final trades = await _readTrades(trade.userId);
    trades.add(savedTrade);
    await _writeTrades(trade.userId, trades);
    await _emit(trade.userId);
    return id;
  }

  Future<void> updateTrade(Trade trade) async {
    final trades = await _readTrades(trade.userId);
    final index = trades.indexWhere((item) => item.id == trade.id);
    if (index == -1) {
      trades.add(trade.copyWith(updatedAt: DateTime.now()));
    } else {
      trades[index] = trade.copyWith(updatedAt: DateTime.now());
    }
    await _writeTrades(trade.userId, trades);
    await _emit(trade.userId);
  }

  Future<void> deleteTrade(String userId, String tradeId) async {
    final trades = await _readTrades(userId);
    trades.removeWhere((trade) => trade.id == tradeId);
    await _writeTrades(userId, trades);
    await _emit(userId);
  }

  Future<void> _emit(String userId) async {
    final controller = _controllers[userId];
    if (controller == null || controller.isClosed) return;
    final trades = await _readTrades(userId);
    trades.sort((a, b) => b.tradeDate.compareTo(a.tradeDate));
    controller.add(trades);
  }

  Future<List<Trade>> _readTrades(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tradesKey(userId));
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => Trade.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _writeTrades(String userId, List<Trade> trades) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(trades.map((trade) => trade.toJson()).toList());
    await prefs.setString(_tradesKey(userId), encoded);
  }
}

String _tradesKey(String userId) => 'trades_$userId';
