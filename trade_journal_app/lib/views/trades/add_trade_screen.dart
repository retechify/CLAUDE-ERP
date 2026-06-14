import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/trade.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trade_provider.dart';
import '../../utils/trade_calculator.dart';

class AddTradeScreen extends StatefulWidget {
  const AddTradeScreen({super.key});

  @override
  State<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends State<AddTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _instrument = TextEditingController();
  final _strategy = TextEditingController();
  final _entry = TextEditingController();
  final _exit = TextEditingController();
  final _stopLoss = TextEditingController();
  final _target = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _notes = TextEditingController();

  DateTime _tradeDate = DateTime.now();
  String _market = 'Nifty';
  String _setup = 'Breakout';
  String _emotionBefore = 'Calm';
  String _emotionAfter = 'Satisfied';
  final Set<String> _mistakes = {};
  Uint8List? _chartImageBytes;
  String? _chartImageDataUrl;
  double _risk = 0;
  double _pnl = 0;

  @override
  void initState() {
    super.initState();
    for (final controller in [_entry, _exit, _stopLoss, _quantity]) {
      controller.addListener(_calculate);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _instrument,
      _strategy,
      _entry,
      _exit,
      _stopLoss,
      _target,
      _quantity,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tradeProvider = context.watch<TradeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Trade')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: 'Trade setup',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(_tradeDate),
                  ),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _pickDateTime,
                ),
                _DropdownField(
                  label: 'Market',
                  value: _market,
                  items: const ['Nifty', 'BankNifty', 'Stocks', 'Crypto'],
                  onChanged: (value) => setState(() => _market = value),
                ),
                TextFormField(
                  controller: _instrument,
                  decoration: const InputDecoration(
                    labelText: 'Instrument',
                    hintText: 'CE, PE, Futures, Spot',
                  ),
                  validator: _required,
                ),
                TextFormField(
                  controller: _strategy,
                  decoration: const InputDecoration(labelText: 'Strategy'),
                  validator: _required,
                ),
                _DropdownField(
                  label: 'Setup type',
                  value: _setup,
                  items: const ['Breakout', 'Pullback', 'Scalping'],
                  onChanged: (value) => setState(() => _setup = value),
                ),
              ],
            ),
            _Section(
              title: 'Execution',
              children: [
                _NumberField(controller: _entry, label: 'Entry price'),
                _NumberField(controller: _exit, label: 'Exit price'),
                _NumberField(controller: _stopLoss, label: 'Stop loss'),
                _NumberField(controller: _target, label: 'Target'),
                _NumberField(
                  controller: _quantity,
                  label: 'Lot size / quantity',
                  isInteger: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _CalculatedCard(label: 'Risk', value: _risk),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CalculatedCard(label: 'P&L', value: _pnl),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              title: 'Psychology',
              children: [
                _DropdownField(
                  label: 'Emotion before trade',
                  value: _emotionBefore,
                  items: const [
                    'Calm',
                    'Confident',
                    'Fearful',
                    'Greedy',
                    'Anxious',
                  ],
                  onChanged: (value) => setState(() => _emotionBefore = value),
                ),
                _DropdownField(
                  label: 'Emotion after trade',
                  value: _emotionAfter,
                  items: const [
                    'Satisfied',
                    'Regretful',
                    'Angry',
                    'Neutral',
                    'Excited',
                  ],
                  onChanged: (value) => setState(() => _emotionAfter = value),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mistake in const [
                      'FOMO',
                      'No SL',
                      'Overtrading',
                      'Revenge trade',
                    ])
                      FilterChip(
                        label: Text(mistake),
                        selected: _mistakes.contains(mistake),
                        onSelected: (selected) => setState(() {
                          selected
                              ? _mistakes.add(mistake)
                              : _mistakes.remove(mistake);
                        }),
                      ),
                  ],
                ),
                TextFormField(
                  controller: _notes,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _chartImageBytes == null
                        ? 'Upload chart screenshot'
                        : 'Change screenshot',
                  ),
                ),
                if (_chartImageBytes != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _chartImageBytes!,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
            if (tradeProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  tradeProvider.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton.icon(
              onPressed: tradeProvider.isSaving ? null : _saveTrade,
              icon: tradeProvider.isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save trade'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tradeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tradeDate),
    );
    if (time == null) return;
    setState(() {
      _tradeDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _chartImageBytes = bytes;
      _chartImageDataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _saveTrade() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;

    final trade = Trade(
      id: '',
      userId: userId,
      tradeDate: _tradeDate,
      market: _market,
      instrument: _instrument.text,
      strategy: _strategy.text,
      setupType: _setup,
      entryPrice: _toDouble(_entry.text),
      exitPrice: _toDouble(_exit.text),
      stopLoss: _toDouble(_stopLoss.text),
      target: _toDouble(_target.text),
      quantity: _toInt(_quantity.text),
      risk: _risk,
      pnl: _pnl,
      emotionBefore: _emotionBefore,
      emotionAfter: _emotionAfter,
      mistakes: _mistakes.toList(),
      notes: _notes.text,
    );

    final saved = await context.read<TradeProvider>().saveTrade(
      trade,
      chartImageUrl: _chartImageDataUrl,
    );
    if (saved && mounted) Navigator.of(context).pop();
  }

  void _calculate() {
    final entry = _toDouble(_entry.text);
    final exit = _toDouble(_exit.text);
    final stop = _toDouble(_stopLoss.text);
    final quantity = _toInt(_quantity.text);
    setState(() {
      _risk = TradeCalculator.calculateRisk(
        entryPrice: entry,
        stopLoss: stop,
        quantity: quantity,
      );
      _pnl = TradeCalculator.calculatePnl(
        entryPrice: entry,
        exitPrice: exit,
        quantity: quantity,
      );
    });
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;
  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            for (final child in children) ...[
              child,
              if (child != children.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.isInteger = false,
  });

  final TextEditingController controller;
  final String label;
  final bool isInteger;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final parsed = isInteger
            ? int.tryParse(value?.trim() ?? '')
            : double.tryParse(value?.trim() ?? '');
        if (parsed == null) return 'Enter a valid number';
        if (parsed <= 0) return 'Must be greater than zero';
        return null;
      },
    );
  }
}

class _CalculatedCard extends StatelessWidget {
  const _CalculatedCard({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: isNegative ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
