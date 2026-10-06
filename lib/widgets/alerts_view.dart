import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class AlertsView extends StatefulWidget {
  const AlertsView({super.key});

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  final TextEditingController _priceController = TextEditingController();
  String _selectedSymbol = 'RELIANCE';
  bool _isAbove = true;

  @override
  Widget build(BuildContext context) {
    final service = TradingService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price & Volume Trigger Alerts', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Set custom price triggers to receive real-time notifications on tick updates.', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),

              // Add New Alert Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KiteTheme.border),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Symbol Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedSymbol,
                            dropdownColor: KiteTheme.panelBg,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Select Instrument',
                              labelStyle: const TextStyle(color: KiteTheme.textMuted),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            items: service.allStocks.map((s) {
                              return DropdownMenuItem(value: s.symbol, child: Text(s.symbol));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSymbol = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Trigger Condition
                          DropdownButtonFormField<bool>(
                            value: _isAbove,
                            dropdownColor: KiteTheme.panelBg,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Condition',
                              labelStyle: const TextStyle(color: KiteTheme.textMuted),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Price >= Target')),
                              DropdownMenuItem(value: false, child: Text('Price <= Target')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _isAbove = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          // Target Price Input
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Target Price (₹)',
                              labelStyle: const TextStyle(color: KiteTheme.textMuted),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              double target = double.tryParse(_priceController.text) ?? 0.0;
                              if (target > 0) {
                                service.addAlert(symbol: _selectedSymbol, price: target, isAbove: _isAbove);
                                _priceController.clear();
                              }
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Create Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KiteTheme.kiteBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Symbol Dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSymbol,
                              dropdownColor: KiteTheme.panelBg,
                              style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Select Instrument',
                                labelStyle: const TextStyle(color: KiteTheme.textMuted),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              items: service.allStocks.map((s) {
                                return DropdownMenuItem(value: s.symbol, child: Text(s.symbol));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSymbol = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Trigger Condition
                          Expanded(
                            child: DropdownButtonFormField<bool>(
                              value: _isAbove,
                              dropdownColor: KiteTheme.panelBg,
                              style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Condition',
                                labelStyle: const TextStyle(color: KiteTheme.textMuted),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              items: const [
                                DropdownMenuItem(value: true, child: Text('Price >= Target')),
                                DropdownMenuItem(value: false, child: Text('Price <= Target')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _isAbove = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Target Price Input
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Target Price (₹)',
                                labelStyle: const TextStyle(color: KiteTheme.textMuted),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              double target = double.tryParse(_priceController.text) ?? 0.0;
                              if (target > 0) {
                                service.addAlert(symbol: _selectedSymbol, price: target, isAbove: _isAbove);
                                _priceController.clear();
                              }
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Create Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KiteTheme.kiteBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Notifications Feed Banner
              if (service.notifications.isNotEmpty) ...[
                const Text('LIVE NOTIFICATION FEED', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...service.notifications.take(3).map((n) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: KiteTheme.zerodhaOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: KiteTheme.zerodhaOrange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: KiteTheme.zerodhaOrange, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(n, style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Active Alerts List Table
              const Text('CONFIGURED ALERTS', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: service,
                builder: (context, _) {
                  if (service.alerts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No active alerts set', style: TextStyle(color: KiteTheme.textMuted))),
                    );
                  }

                  return SingleChildScrollView(
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
                            DataColumn(label: Text('Instrument', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Condition', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Target Price', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Created At', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                          ],
                          rows: service.alerts.map((alert) {
                            return DataRow(
                              cells: [
                                DataCell(Text(alert.symbol, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
                                DataCell(Text(alert.isAbove ? '>= Target' : '<= Target', style: const TextStyle(color: KiteTheme.textSecondary))),
                                DataCell(Text('₹${alert.targetPrice.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.kiteBlue, fontWeight: FontWeight.bold))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: alert.isTriggered
                                          ? KiteTheme.greenBg
                                          : alert.isActive
                                              ? KiteTheme.kiteBlue.withOpacity(0.2)
                                              : KiteTheme.border,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      alert.isTriggered ? 'TRIGGERED' : alert.isActive ? 'ACTIVE' : 'DISABLED',
                                      style: TextStyle(
                                        color: alert.isTriggered ? KiteTheme.green : alert.isActive ? KiteTheme.kiteBlue : KiteTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text('${alert.createdAt.hour}:${alert.createdAt.minute}', style: const TextStyle(color: KiteTheme.textMuted))),
                                DataCell(
                                  Row(
                                    children: [
                                      Switch(
                                        value: alert.isActive,
                                        activeColor: KiteTheme.kiteBlue,
                                        onChanged: (_) => service.toggleAlert(alert.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: KiteTheme.red, size: 18),
                                        onPressed: () => service.deleteAlert(alert.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
