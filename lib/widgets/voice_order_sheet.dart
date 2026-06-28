import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';

/// Voice ordering sheet — natural-language order capture in English, Luganda
/// or Swahili. Trade-promotion rules (BOGO) are auto-applied to the parsed
/// lines.
///
/// NOTE: live speech recognition + NLP needs a speech-to-text engine and an
/// intent parser. Here a representative utterance per language is recognised
/// and parsed locally to demonstrate the end-to-end flow.
class VoiceOrderSheet extends StatefulWidget {
  const VoiceOrderSheet({super.key});

  @override
  State<VoiceOrderSheet> createState() => _VoiceOrderSheetState();
}

enum _Lang { english, luganda, swahili }

extension _LangInfo on _Lang {
  String get label => switch (this) {
        _Lang.english => 'English',
        _Lang.luganda => 'Luganda',
        _Lang.swahili => 'Swahili',
      };

  /// A representative spoken order in this language.
  String get utterance => switch (this) {
        _Lang.english => 'Add six cartons of Bugisu AA and two of Energy Drink',
        _Lang.luganda => 'Waako ssanduuko mukaaga eza Bugisu AA n\'ebbiri eza Energy Drink',
        _Lang.swahili => 'Ongeza makartoni sita ya Bugisu AA na mbili za Energy Drink',
      };
}

class _ParsedLine {
  _ParsedLine(this.item, {this.isPromo = false});
  final OrderItem item;
  final bool isPromo;
}

class _VoiceOrderSheetState extends State<VoiceOrderSheet> {
  _Lang _lang = _Lang.english;
  bool _listening = false;
  String? _transcript;
  List<_ParsedLine> _lines = [];

  /// Known SKUs the parser can resolve (keyword → name + unit price).
  static const _catalog = {
    'bugisu': OrderItem(name: 'Bugisu AA 500g (case)', quantity: 1, unitPrice: 18.75),
    'energy': OrderItem(name: 'Energy Drink (case)', quantity: 1, unitPrice: 22.0),
    'cola': OrderItem(name: 'Cola 1L (case)', quantity: 1, unitPrice: 12.5),
    'water': OrderItem(name: 'Spring Water 500ml (case)', quantity: 1, unitPrice: 8.0),
  };

  /// SKUs that carry a Buy-One-Get-One trade promotion.
  static const _bogoKeywords = {'energy'};

  Future<void> _listen() async {
    setState(() {
      _listening = true;
      _transcript = null;
      _lines = [];
    });
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final text = _lang.utterance;
    setState(() {
      _listening = false;
      _transcript = text;
      _lines = _parse(text);
    });
    HapticFeedback.mediumImpact();
  }

  List<_ParsedLine> _parse(String text) {
    final lower = text.toLowerCase();
    // Multilingual quantity words mapped to numbers.
    const numbers = {
      'two': 2, 'six': 6,
      'bbiri': 2, 'mukaaga': 6,
      'mbili': 2, 'sita': 6,
    };
    final result = <_ParsedLine>[];
    _catalog.forEach((key, base) {
      if (!lower.contains(key)) return;
      // Find a quantity word near the keyword; default to 1.
      var qty = 1;
      for (final entry in numbers.entries) {
        if (lower.contains(entry.key)) qty = entry.value;
      }
      result.add(_ParsedLine(
        OrderItem(name: base.name, quantity: qty, unitPrice: base.unitPrice),
      ));
      if (_bogoKeywords.contains(key)) {
        result.add(_ParsedLine(
          OrderItem(name: '${base.name} — BOGO free', quantity: qty, unitPrice: 0),
          isPromo: true,
        ));
      }
    });
    return result;
  }

  void _confirm() {
    final nextId = 1045 + SampleData.orders.length;
    final order = Order(
      id: 'ORD-$nextId',
      customerName: 'Kabalagala Duka',
      date: DateTime.now(),
      status: OrderStatus.pending,
      items: _lines.map((l) => l.item).toList(),
    );
    Navigator.of(context).pop(order);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice Order',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Speak the order — TPM promos apply automatically.',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _Lang.values
                .map((l) => ChoiceChip(
                      label: Text(l.label),
                      selected: _lang == l,
                      onSelected: (_) => setState(() => _lang = l),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _listening ? null : _listen,
              child: CircleAvatar(
                radius: 44,
                backgroundColor: _listening
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.15),
                child: HugeIcon(
                  icon: _listening
                      ? HugeIcons.strokeRoundedMic02
                      : HugeIcons.strokeRoundedMic01,
                  color: _listening ? Colors.red : Colors.orange,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _listening ? 'Listening…' : 'Tap to speak',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          if (_transcript != null) ...[
            const SizedBox(height: 20),
            const Text('Heard', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('“$_transcript”',
                style: const TextStyle(fontStyle: FontStyle.italic)),
            const Divider(height: 28),
            const Text('Parsed order',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._lines.map(
              (l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: l.isPromo
                          ? HugeIcons.strokeRoundedGift
                          : HugeIcons.strokeRoundedShoppingBasket01,
                      size: 18,
                      color: l.isPromo ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${l.item.quantity} × ${l.item.name}'),
                    ),
                    Text(
                      l.item.unitPrice == 0
                          ? 'FREE'
                          : '\$${l.item.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: l.isPromo ? Colors.green : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _lines.isEmpty ? null : _confirm,
                icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01),
                label: const Text('Confirm order'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
