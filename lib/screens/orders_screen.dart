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
        onPressed: _showNewOrderDialog,
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

  Future<void> _showNewOrderDialog() async {
    final order = await showDialog<Order>(
      context: context,
      builder: (_) => const _NewOrderDialog(),
    );
    if (order == null) return;
    setState(() => SampleData.orders.add(order));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${order.id} created for ${order.customerName}')),
    );
  }

  static String _formatDate(DateTime date) {
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final m = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour < 12 ? 'AM' : 'PM';
    return '${date.month}/${date.day} $h:$m $ampm';
  }
}

/// Modal form for creating a new order.
class _NewOrderDialog extends StatefulWidget {
  const _NewOrderDialog();

  @override
  State<_NewOrderDialog> createState() => _NewOrderDialogState();
}

class _NewOrderDialogState extends State<_NewOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customer = TextEditingController();
  final _item = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _price = TextEditingController();

  @override
  void dispose() {
    _customer.dispose();
    _item.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final nextId = 1045 + SampleData.orders.length;
    final order = Order(
      id: 'ORD-$nextId',
      customerName: _customer.text.trim(),
      date: DateTime.now(),
      status: OrderStatus.pending,
      items: [
        OrderItem(
          name: _item.text.trim(),
          quantity: int.parse(_quantity.text),
          unitPrice: double.parse(_price.text),
        ),
      ],
    );
    Navigator.of(context).pop(order);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Order'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _customer,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Customer',
                prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedStore01),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _item,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Item',
                prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedInvoice01),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return (n == null || n <= 0) ? 'Invalid' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit price',
                      prefixText: '\$',
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      return (n == null || n <= 0) ? 'Invalid' : null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
