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
    this.status = StopStatus.pending,
  });

  final String customerName;
  final String address;
  final String eta;
  StopStatus status;
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
      customerName: 'Acme Grocers',
      address: '12 Market St, Downtown',
      eta: '09:00 AM',
      status: StopStatus.visited,
    ),
    RouteStop(
      customerName: 'Bright Mart',
      address: '88 River Rd, Westside',
      eta: '10:30 AM',
      status: StopStatus.visited,
    ),
    RouteStop(
      customerName: 'Corner Store Plus',
      address: '4 Hill Ave, Uptown',
      eta: '11:45 AM',
    ),
    RouteStop(
      customerName: 'Daily Fresh Foods',
      address: '210 Oak Blvd, Eastend',
      eta: '01:15 PM',
    ),
    RouteStop(
      customerName: 'Evergreen Supplies',
      address: '57 Pine Ln, Northgate',
      eta: '02:30 PM',
      status: StopStatus.skipped,
    ),
  ];

  static final List<Order> orders = [
    Order(
      id: 'ORD-1042',
      customerName: 'Acme Grocers',
      date: DateTime(2026, 6, 28, 9, 20),
      status: OrderStatus.delivered,
      items: const [
        OrderItem(name: 'Cola 1L (case)', quantity: 10, unitPrice: 12.5),
        OrderItem(name: 'Spring Water 500ml (case)', quantity: 6, unitPrice: 8.0),
      ],
    ),
    Order(
      id: 'ORD-1043',
      customerName: 'Bright Mart',
      date: DateTime(2026, 6, 28, 10, 50),
      status: OrderStatus.confirmed,
      items: const [
        OrderItem(name: 'Energy Drink (case)', quantity: 4, unitPrice: 22.0),
        OrderItem(name: 'Juice Pack (case)', quantity: 8, unitPrice: 15.0),
      ],
    ),
    Order(
      id: 'ORD-1044',
      customerName: 'Corner Store Plus',
      date: DateTime(2026, 6, 28, 11, 5),
      status: OrderStatus.pending,
      items: const [
        OrderItem(name: 'Snack Box (case)', quantity: 12, unitPrice: 18.75),
      ],
    ),
    Order(
      id: 'ORD-1041',
      customerName: 'Daily Fresh Foods',
      date: DateTime(2026, 6, 27, 15, 40),
      status: OrderStatus.cancelled,
      items: const [
        OrderItem(name: 'Bottled Tea (case)', quantity: 5, unitPrice: 14.0),
      ],
    ),
  ];
}
