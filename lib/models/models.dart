import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// The shape HugeIcons exposes for an icon (SVG path data).
typedef HugeIconData = List<List<dynamic>>;

/// Status of a single stop along a sales route.
enum StopStatus { pending, visited, skipped }

extension StopStatusInfo on StopStatus {
  String get label {
    switch (this) {
      case StopStatus.pending:
        return 'Pending';
      case StopStatus.visited:
        return 'Visited';
      case StopStatus.skipped:
        return 'Skipped';
    }
  }

  Color get color {
    switch (this) {
      case StopStatus.pending:
        return Colors.orange;
      case StopStatus.visited:
        return Colors.green;
      case StopStatus.skipped:
        return Colors.grey;
    }
  }

  HugeIconData get icon {
    switch (this) {
      case StopStatus.pending:
        return HugeIcons.strokeRoundedClock01;
      case StopStatus.visited:
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      case StopStatus.skipped:
        return HugeIcons.strokeRoundedMinusSignCircle;
    }
  }
}

/// Lifecycle status of a customer order.
enum OrderStatus { pending, confirmed, delivered, cancelled }

extension OrderStatusInfo on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

/// A customer/stop to visit on a route.
class RouteStop {
  RouteStop({
    required this.customerName,
    required this.address,
    required this.eta,
    required this.tier,
    required this.distanceMeters,
    this.budgetMinutes = 15,
    this.status = StopStatus.pending,
  });

  final String customerName;
  final String address;
  final String eta;
  final OutletTier tier;

  /// Simulated current distance from the outlet's coordinates (metres).
  /// Geofenced check-in unlocks at or below [geofenceRadiusMeters].
  double distanceMeters;

  /// Allocated time-on-site budget for this outlet tier.
  final int budgetMinutes;

  StopStatus status;

  /// Whether the agent is inside the 50 m geofence and may check in.
  bool get withinGeofence => distanceMeters <= geofenceRadiusMeters;

  static const double geofenceRadiusMeters = 50;
}

/// Retail outlet channel/tier for beat mapping.
enum OutletTier { horeca, gt, mt }

extension OutletTierInfo on OutletTier {
  /// Short code shown on the beat list.
  String get code {
    switch (this) {
      case OutletTier.horeca:
        return 'HoReCa';
      case OutletTier.gt:
        return 'GT';
      case OutletTier.mt:
        return 'MT';
    }
  }

  String get label {
    switch (this) {
      case OutletTier.horeca:
        return 'Hotel / Restaurant / Café';
      case OutletTier.gt:
        return 'General Trade';
      case OutletTier.mt:
        return 'Modern Trade';
    }
  }

  Color get color {
    switch (this) {
      case OutletTier.horeca:
        return Colors.purpleAccent;
      case OutletTier.gt:
        return Colors.tealAccent;
      case OutletTier.mt:
        return Colors.amberAccent;
    }
  }
}

/// A single line item within an order.
class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String name;
  final int quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;
}

/// A customer order.
class Order {
  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.items,
    this.status = OrderStatus.pending,
  });

  final String id;
  final String customerName;
  final DateTime date;
  final List<OrderItem> items;
  OrderStatus status;

  double get total => items.fold(0, (sum, item) => sum + item.total);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

/// In-memory sample data so the app runs out of the box.
class SampleData {
  static final List<RouteStop> route = [
    RouteStop(
      customerName: 'Nakasero Supermarket',
      address: 'Kampala Rd, Nakasero',
      eta: '09:00 AM',
      tier: OutletTier.mt,
      distanceMeters: 0,
      budgetMinutes: 25,
      status: StopStatus.visited,
    ),
    RouteStop(
      customerName: 'Café Javas Kololo',
      address: '7 Acacia Ave, Kololo',
      eta: '10:30 AM',
      tier: OutletTier.horeca,
      distanceMeters: 0,
      budgetMinutes: 20,
      status: StopStatus.visited,
    ),
    RouteStop(
      customerName: 'Kabalagala Duka',
      address: 'Ggaba Rd, Kabalagala',
      eta: '11:45 AM',
      tier: OutletTier.gt,
      distanceMeters: 18,
      budgetMinutes: 12,
    ),
    RouteStop(
      customerName: 'Wandegeya Mini Mart',
      address: 'Bombo Rd, Wandegeya',
      eta: '01:15 PM',
      tier: OutletTier.gt,
      distanceMeters: 240,
      budgetMinutes: 12,
    ),
    RouteStop(
      customerName: 'Garden City Shoprite',
      address: 'Yusuf Lule Rd, Nakasero',
      eta: '02:30 PM',
      tier: OutletTier.mt,
      distanceMeters: 1100,
      budgetMinutes: 25,
    ),
  ];

  /// SAFARI Coach contextual upsell suggestions per outlet.
  static const Map<String, String> coachTips = {
    'Kabalagala Duka':
        'Last 3 visits skipped Bugisu AA. Suggest a 6-pack — 80% accept rate here.',
    'Wandegeya Mini Mart':
        'Energy Drink velocity up 22%. Push the BOGO promo before competitor restocks.',
    'Garden City Shoprite':
        'MT outlet — propose end-cap facing for the new Juice Pack SKU.',
  };

  /// Leaderboard standings driven by "Day Score".
  static const List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(name: 'Sarah N.', dayScore: 94, streakDays: 12),
    LeaderboardEntry(name: 'Peter Olaro', dayScore: 88, streakDays: 7, isMe: true),
    LeaderboardEntry(name: 'David K.', dayScore: 81, streakDays: 4),
    LeaderboardEntry(name: 'Grace A.', dayScore: 76, streakDays: 9),
    LeaderboardEntry(name: 'Moses T.', dayScore: 63, streakDays: 2),
  ];

  /// Stock-on-hand lines captured during the audit.
  static final List<StockLine> stockOnHand = [
    StockLine(sku: 'Bugisu AA 500g', onHand: 4, reorderPoint: 12),
    StockLine(sku: 'Cola 1L', onHand: 26, reorderPoint: 10),
    StockLine(sku: 'Energy Drink 250ml', onHand: 2, reorderPoint: 8),
    StockLine(sku: 'Spring Water 500ml', onHand: 40, reorderPoint: 15),
  ];

  /// Competitor price/promo intel captured via OCR scan.
  static const List<CompetitorIntel> competitorIntel = [
    CompetitorIntel(
      brand: 'RivalCo Coffee',
      product: 'Robusta 500g',
      price: 'UGX 11,500',
      note: 'End-cap promo: buy 2 get mug',
    ),
    CompetitorIntel(
      brand: 'PowerMax',
      product: 'Energy 250ml',
      price: 'UGX 2,800',
      note: '15% below our shelf price',
    ),
  ];

  /// Today's planogram audit result (simulated AI gap analysis).
  static const PlanogramAudit planogram = PlanogramAudit(
    detectedFacings: 14,
    targetFacings: 20,
    competitorShare: 0.38,
    gaps: ['Bugisu AA out of eye-level', 'Juice Pack missing from cold shelf'],
  );

  static final List<Order> orders = [
    Order(
      id: 'ORD-1042',
      customerName: 'Nakasero Supermarket',
      date: DateTime(2026, 6, 28, 9, 20),
      status: OrderStatus.delivered,
      items: const [
        OrderItem(name: 'Cola 1L (case)', quantity: 10, unitPrice: 12.5),
        OrderItem(name: 'Spring Water 500ml (case)', quantity: 6, unitPrice: 8.0),
      ],
    ),
    Order(
      id: 'ORD-1043',
      customerName: 'Café Javas Kololo',
      date: DateTime(2026, 6, 28, 10, 50),
      status: OrderStatus.confirmed,
      items: const [
        OrderItem(name: 'Energy Drink (case)', quantity: 4, unitPrice: 22.0),
        OrderItem(name: 'Juice Pack (case)', quantity: 8, unitPrice: 15.0),
      ],
    ),
    Order(
      id: 'ORD-1044',
      customerName: 'Kabalagala Duka',
      date: DateTime(2026, 6, 28, 11, 5),
      status: OrderStatus.pending,
      items: const [
        OrderItem(name: 'Bugisu AA 500g (case)', quantity: 12, unitPrice: 18.75),
      ],
    ),
    Order(
      id: 'ORD-1041',
      customerName: 'Wandegeya Mini Mart',
      date: DateTime(2026, 6, 27, 15, 40),
      status: OrderStatus.cancelled,
      items: const [
        OrderItem(name: 'Bottled Tea (case)', quantity: 5, unitPrice: 14.0),
      ],
    ),
  ];
}

/// A peer ranking row on the gamified leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.dayScore,
    required this.streakDays,
    this.isMe = false,
  });

  final String name;
  final int dayScore;
  final int streakDays;
  final bool isMe;
}

/// A stock-on-hand line captured during the audit.
class StockLine {
  StockLine({
    required this.sku,
    required this.onHand,
    required this.reorderPoint,
  });

  final String sku;
  int onHand;
  final int reorderPoint;

  /// Flagged when inventory has dropped to/below the reorder point.
  bool get isCritical => onHand <= reorderPoint;
}

/// Competitor price/promo captured via OCR scanning.
class CompetitorIntel {
  const CompetitorIntel({
    required this.brand,
    required this.product,
    required this.price,
    required this.note,
  });

  final String brand;
  final String product;
  final String price;
  final String note;
}

/// Result of the AI planogram audit (facings + gap analysis).
class PlanogramAudit {
  const PlanogramAudit({
    required this.detectedFacings,
    required this.targetFacings,
    required this.competitorShare,
    required this.gaps,
  });

  final int detectedFacings;
  final int targetFacings;
  final double competitorShare;
  final List<String> gaps;

  double get compliance => detectedFacings / targetFacings;
}
