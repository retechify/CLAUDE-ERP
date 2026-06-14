import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/trade.dart';
import '../../providers/trade_provider.dart';
import '../../widgets/empty_state.dart';
import 'trade_detail_screen.dart';

class TradeListScreen extends StatefulWidget {
  const TradeListScreen({super.key});

  @override
  State<TradeListScreen> createState() => _TradeListScreenState();
}

class _TradeListScreenState extends State<TradeListScreen> {
  DateTimeRange? _range;
  final _strategyController = TextEditingController();
  TradeOutcome? _outcome;

  @override
  void dispose() {
    _strategyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TradeProvider>();
    final trades = provider.filteredTrades(
      start: _range?.start,
      end: _range?.end,
      strategy: _strategyController.text,
      outcome: _outcome,
    );

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _Filters(
          range: _range,
          strategyController: _strategyController,
          outcome: _outcome,
          onRangeChanged: (range) => setState(() => _range = range),
          onOutcomeChanged: (outcome) => setState(() => _outcome = outcome),
          onStrategyChanged: () => setState(() {}),
          onClear: () => setState(() {
            _range = null;
            _outcome = null;
            _strategyController.clear();
          }),
        ),
        Expanded(
          child: trades.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No matching trades',
                  message: 'Add a trade or relax the filters.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: trades.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _TradeTile(trade: trades[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.range,
    required this.strategyController,
    required this.outcome,
    required this.onRangeChanged,
    required this.onOutcomeChanged,
    required this.onStrategyChanged,
    required this.onClear,
  });

  final DateTimeRange? range;
  final TextEditingController strategyController;
  final TradeOutcome? outcome;
  final ValueChanged<DateTimeRange?> onRangeChanged;
  final ValueChanged<TradeOutcome?> onOutcomeChanged;
  final VoidCallback onStrategyChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM');
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: strategyController,
                    onChanged: (_) => onStrategyChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Strategy',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Date range',
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: range,
                    );
                    onRangeChanged(picked);
                  },
                  icon: const Icon(Icons.date_range),
                ),
                IconButton(
                  tooltip: 'Clear filters',
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: outcome == null,
                  onSelected: (_) => onOutcomeChanged(null),
                ),
                ChoiceChip(
                  label: const Text('Profit'),
                  selected: outcome == TradeOutcome.profit,
                  onSelected: (_) => onOutcomeChanged(TradeOutcome.profit),
                ),
                ChoiceChip(
                  label: const Text('Loss'),
                  selected: outcome == TradeOutcome.loss,
                  onSelected: (_) => onOutcomeChanged(TradeOutcome.loss),
                ),
                if (range != null)
                  InputChip(
                    label: Text(
                      '${formatter.format(range!.start)} - ${formatter.format(range!.end)}',
                    ),
                    onDeleted: () => onRangeChanged(null),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade});

  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final isProfit = trade.pnl >= 0;
    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TradeDetailScreen(trade: trade)),
        ),
        title: Text(trade.strategy),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy, hh:mm a').format(trade.tradeDate)} · ${trade.market}',
        ),
        trailing: Text(
          '₹${trade.pnl.toStringAsFixed(2)}',
          style: TextStyle(
            color: isProfit ? Colors.green : Colors.red,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
