import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/trade.dart';
import '../../providers/trade_provider.dart';

class TradeDetailScreen extends StatelessWidget {
  const TradeDetailScreen({required this.trade, super.key});

  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final isProfit = trade.pnl >= 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(trade.strategy),
        actions: [
          IconButton(
            tooltip: 'Delete trade',
            onPressed: () async {
              await context.read<TradeProvider>().deleteTrade(trade.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (trade.chartImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _TradeImage(imageUrl: trade.chartImageUrl!),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _RowItem(
                    'Date',
                    DateFormat('dd MMM yyyy, hh:mm a').format(trade.tradeDate),
                  ),
                  _RowItem('Market', trade.market),
                  _RowItem('Instrument', trade.instrument),
                  _RowItem('Setup', trade.setupType),
                  _RowItem('Entry', trade.entryPrice.toStringAsFixed(2)),
                  _RowItem('Exit', trade.exitPrice.toStringAsFixed(2)),
                  _RowItem('Stop loss', trade.stopLoss.toStringAsFixed(2)),
                  _RowItem('Target', trade.target.toStringAsFixed(2)),
                  _RowItem('Quantity', trade.quantity.toString()),
                  _RowItem('Risk', '₹${trade.risk.toStringAsFixed(2)}'),
                  _RowItem(
                    'P&L',
                    '₹${trade.pnl.toStringAsFixed(2)}',
                    valueColor: isProfit ? Colors.green : Colors.red,
                  ),
                  _RowItem('Before', trade.emotionBefore),
                  _RowItem('After', trade.emotionAfter),
                  _RowItem('Mistakes', trade.mistakes.join(', ')),
                  _RowItem('Notes', trade.notes.isEmpty ? '-' : trade.notes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeImage extends StatelessWidget {
  const _TradeImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      final base64Data = imageUrl.substring(imageUrl.indexOf(',') + 1);
      return Image.memory(
        base64Decode(base64Data),
        height: 220,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imageUrl,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
