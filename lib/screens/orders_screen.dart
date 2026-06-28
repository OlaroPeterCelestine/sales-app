import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';

/// List of orders with status filtering and a detail view.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _filter;

  List<Order> get _orders {
    final all = SampleData.orders;
    final list =
        _filter == null ? all : all.where((o) => o.status == _filter).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip('All', null),
                ...OrderStatus.values.map((s) => _filterChip(s.label, s)),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('No orders match this filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                order.status.color.withValues(alpha: 0.15),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedInvoice01,
                              color: order.status.color,
                            ),
                          ),
                          title: Text(order.customerName),
                          subtitle: Text(
                            '${order.id} · ${order.itemCount} items · '
                            '${_formatDate(order.date)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                order.status.label,
                                style: TextStyle(
                                  color: order.status.color,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showOrderDetail(order),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New order — coming soon')),
          );
        },
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _filterChip(String label, OrderStatus? status) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = status),
      ),
    );
  }

  void _showOrderDetail(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Chip(
                    label: Text(order.status.label),
                    backgroundColor:
                        order.status.color.withValues(alpha: 0.15),
                    labelStyle: TextStyle(color: order.status.color),
                    side: BorderSide.none,
                  ),
                ],
              ),
              Text(
                '${order.id} · ${_formatDate(order.date)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Divider(height: 28),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${item.quantity} × ${item.name}'),
                      ),
                      Text('\$${item.total.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final m = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';
    return '${date.month}/${date.day} $h:$m $ampm';
  }
}
