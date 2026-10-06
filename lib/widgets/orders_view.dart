import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final service = TradingService();

    return Column(
      children: [
        // Tab Header: Pending, Executed, Cancelled
        Container(
          color: KiteTheme.panelBg,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Pending Orders'),
              Tab(text: 'Executed Orders'),
              Tab(text: 'Cancelled Orders'),
            ],
          ),
        ),

        Expanded(
          child: AnimatedBuilder(
            animation: service,
            builder: (context, _) {
              final pending = service.orders.where((o) => o.status == OrderStatus.pending).toList();
              final executed = service.orders.where((o) => o.status == OrderStatus.executed).toList();
              final cancelled = service.orders.where((o) => o.status == OrderStatus.cancelled).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersTable(pending, isPending: true),
                  _buildOrdersTable(executed),
                  _buildOrdersTable(cancelled),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTable(List<OrderItem> list, {bool isPending = false}) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No orders found', style: TextStyle(color: KiteTheme.textMuted, fontSize: 14)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 800),
          child: Container(
            decoration: BoxDecoration(
              color: KiteTheme.panelBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: KiteTheme.border),
            ),
            child: DataTable(
          columns: const [
            DataColumn(label: Text('Time', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Type', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Instrument', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Product', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Qty', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Price', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
          ],
          rows: list.map((order) {
            bool isBuy = order.side == OrderSide.buy;
            return DataRow(
              cells: [
                DataCell(Text('${order.timestamp.hour.toString().padLeft(2, '0')}:${order.timestamp.minute.toString().padLeft(2, '0')}:${order.timestamp.second.toString().padLeft(2, '0')}', style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBuy ? KiteTheme.kiteBlue.withOpacity(0.2) : KiteTheme.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(isBuy ? 'BUY' : 'SELL', style: TextStyle(color: isBuy ? KiteTheme.kiteBlue : KiteTheme.red, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
                DataCell(Text(order.symbol, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
                DataCell(Text(order.product.name.toUpperCase(), style: const TextStyle(color: KiteTheme.textSecondary))),
                DataCell(Text('${order.quantity}', style: const TextStyle(color: KiteTheme.textPrimary))),
                DataCell(Text('₹${order.price.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
                DataCell(
                  Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      color: order.status == OrderStatus.executed
                          ? KiteTheme.green
                          : order.status == OrderStatus.pending
                              ? KiteTheme.orange
                              : KiteTheme.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                DataCell(
                  isPending
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: KiteTheme.kiteBlue),
                              onPressed: () => _showModifyDialog(context, order),
                              tooltip: 'Modify Order',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined, size: 16, color: KiteTheme.red),
                              onPressed: () => TradingService().cancelOrder(order.id),
                              tooltip: 'Cancel Order',
                            ),
                          ],
                        )
                      : const Text('-', style: TextStyle(color: KiteTheme.textMuted)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
        ),
      ),
    );
  }

  void _showModifyDialog(BuildContext context, OrderItem order) {
    final priceController = TextEditingController(text: order.price.toString());
    final qtyController = TextEditingController(text: order.quantity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KiteTheme.panelBg,
        title: Text('Modify Order ${order.id}', style: const TextStyle(color: KiteTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'New Price'),
              style: const TextStyle(color: KiteTheme.textPrimary),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'New Quantity'),
              style: const TextStyle(color: KiteTheme.textPrimary),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              double p = double.tryParse(priceController.text) ?? order.price;
              int q = int.tryParse(qtyController.text) ?? order.quantity;
              TradingService().modifyOrder(order.id, p, q);
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
