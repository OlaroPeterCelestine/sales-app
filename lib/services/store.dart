import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// A single offline event waiting to be replayed to the DMS.
class SyncEvent {
  SyncEvent({required this.type, required this.summary, required this.at});

  final String type;
  final String summary;
  final DateTime at;

  Map<String, dynamic> toJson() =>
      {'type': type, 'summary': summary, 'at': at.toIso8601String()};

  factory SyncEvent.fromJson(Map<String, dynamic> j) => SyncEvent(
        type: j['type'] as String,
        summary: j['summary'] as String,
        at: DateTime.parse(j['at'] as String),
      );
}

/// Local-first data store. Persists mutable state to device storage and holds
/// a serialized sync queue that is replayed to the DMS when a signal returns.
///
/// This is the real offline-first layer: state survives an app reload, and
/// offline actions are queued rather than lost. The actual DMS endpoint is the
/// only simulated part of replay (no live backend) — events are cleared on a
/// successful "sync" exactly as a real HTTP replay would do.
class Store extends ChangeNotifier {
  Store._();
  static final Store instance = Store._();

  static const _kOrders = 'safari.orders';
  static const _kStops = 'safari.stops';
  static const _kStock = 'safari.stock';
  static const _kQueue = 'safari.queue';

  SharedPreferences? _prefs;
  final List<SyncEvent> _queue = [];

  /// Simulated connectivity. When false, sync attempts hold the queue.
  bool online = true;

  List<SyncEvent> get queue => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _restoreOrders();
    _restoreStops();
    _restoreStock();
    _restoreQueue();
  }

  // ---- Persistence ---------------------------------------------------------

  void persistOrders() {
    _prefs?.setString(
      _kOrders,
      jsonEncode(SampleData.orders.map((o) => o.toJson()).toList()),
    );
  }

  void persistStops() {
    final data = {
      for (final s in SampleData.route)
        s.customerName: {
          'status': s.status.index,
          'distance': s.distanceMeters,
        },
    };
    _prefs?.setString(_kStops, jsonEncode(data));
  }

  void persistStock() {
    final data = {for (final l in SampleData.stockOnHand) l.sku: l.onHand};
    _prefs?.setString(_kStock, jsonEncode(data));
  }

  void _persistQueue() {
    _prefs?.setString(
      _kQueue,
      jsonEncode(_queue.map((e) => e.toJson()).toList()),
    );
  }

  // ---- Restore -------------------------------------------------------------

  void _restoreOrders() {
    final raw = _prefs?.getString(_kOrders);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
      SampleData.orders
        ..clear()
        ..addAll(list);
    } catch (_) {/* ignore corrupt cache, keep seed data */}
  }

  void _restoreStops() {
    final raw = _prefs?.getString(_kStops);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final stop in SampleData.route) {
        final saved = data[stop.customerName] as Map<String, dynamic>?;
        if (saved == null) continue;
        stop.status = StopStatus.values[saved['status'] as int];
        stop.distanceMeters = (saved['distance'] as num).toDouble();
      }
    } catch (_) {}
  }

  void _restoreStock() {
    final raw = _prefs?.getString(_kStock);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final line in SampleData.stockOnHand) {
        final v = data[line.sku];
        if (v is int) line.onHand = v;
      }
    } catch (_) {}
  }

  void _restoreQueue() {
    final raw = _prefs?.getString(_kQueue);
    if (raw == null) return;
    try {
      _queue
        ..clear()
        ..addAll((jsonDecode(raw) as List)
            .map((e) => SyncEvent.fromJson(e as Map<String, dynamic>)));
    } catch (_) {}
  }

  // ---- Sync queue ----------------------------------------------------------

  /// Queues an offline event and persists it for DMS replay.
  void enqueue(String type, String summary) {
    _queue.add(SyncEvent(type: type, summary: summary, at: DateTime.now()));
    _persistQueue();
    notifyListeners();
  }

  /// Replays the queue to the DMS. Returns the number of events synced, or -1
  /// if offline (queue retained for the next retry).
  Future<int> sync() async {
    if (!online) return -1;
    if (_queue.isEmpty) return 0;
    final count = _queue.length;
    // A real implementation POSTs each event to the DMS here.
    await Future.delayed(const Duration(milliseconds: 700));
    _queue.clear();
    _persistQueue();
    notifyListeners();
    return count;
  }

  void setOnline(bool value) {
    online = value;
    notifyListeners();
  }
}
