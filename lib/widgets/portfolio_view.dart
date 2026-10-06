import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class PortfolioView extends StatefulWidget {
  final bool isPositions;

  const PortfolioView({super.key, this.isPositions = false});

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  @override
  Widget build(BuildContext context) {
    final service = TradingService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        if (widget.isPositions) {
          return _buildPositionsContent(service);
        } else {
          return _buildHoldingsContent(service);
        }
      },
    );
  }

  Widget _buildHoldingsContent(TradingService service) {
    double totalInvested = service.holdings.fold(0.0, (sum, item) => sum + item.investedAmount);
    double totalCurrent = service.holdings.fold(0.0, (sum, item) => sum + item.currentValue);
    double totalPnL = totalCurrent - totalInvested;
    double totalPnLPct = (totalInvested > 0) ? (totalPnL / totalInvested) * 100 : 0.0;
    bool isProfit = totalPnL >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Holdings Metrics Header Summary
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KiteTheme.border),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invested Value', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('₹${totalInvested.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Value', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('₹${totalCurrent.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Profit / Loss', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '${isProfit ? '+' : ''}₹${totalPnL.toStringAsFixed(2)}',
                                    style: TextStyle(color: isProfit ? KiteTheme.green : KiteTheme.red, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isProfit ? KiteTheme.greenBg : KiteTheme.redBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${isProfit ? '+' : ''}${totalPnLPct.toStringAsFixed(2)}%',
                                      style: TextStyle(color: isProfit ? KiteTheme.green : KiteTheme.red, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invested Value', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('₹${totalInvested.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Value', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('₹${totalCurrent.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Profit / Loss', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${isProfit ? '+' : ''}₹${totalPnL.toStringAsFixed(2)}',
                                    style: TextStyle(color: isProfit ? KiteTheme.green : KiteTheme.red, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isProfit ? KiteTheme.greenBg : KiteTheme.redBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${isProfit ? '+' : ''}${totalPnLPct.toStringAsFixed(2)}%',
                                      style: TextStyle(color: isProfit ? KiteTheme.green : KiteTheme.red, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Holdings Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: KiteTheme.border),
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Instrument', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Qty.', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Avg. Cost', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('LTP', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Cur. Val', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('P&L', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Net Chg.%', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Day Chg.%', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                  ],
                  rows: service.holdings.map((h) {
                    bool pnlPos = h.totalPnL >= 0;
                    bool dayPos = h.dayChangePercent >= 0;

                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.symbol, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold)),
                              Text(h.name, style: const TextStyle(color: KiteTheme.textMuted, fontSize: 10)),
                            ],
                          ),
                        ),
                        DataCell(Text('${h.quantity}', style: const TextStyle(color: KiteTheme.textPrimary))),
                        DataCell(Text('₹${h.avgPrice.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textSecondary))),
                        DataCell(Text('₹${h.ltp.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
                        DataCell(Text('₹${h.currentValue.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary))),
                        DataCell(Text('${pnlPos ? '+' : ''}₹${h.totalPnL.toStringAsFixed(2)}', style: TextStyle(color: pnlPos ? KiteTheme.green : KiteTheme.red, fontWeight: FontWeight.bold))),
                        DataCell(Text('${pnlPos ? '+' : ''}${h.totalPnLPercent.toStringAsFixed(2)}%', style: TextStyle(color: pnlPos ? KiteTheme.green : KiteTheme.red))),
                        DataCell(Text('${dayPos ? '+' : ''}${h.dayChangePercent.toStringAsFixed(2)}%', style: TextStyle(color: dayPos ? KiteTheme.green : KiteTheme.red))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsContent(TradingService service) {
    double totalM2M = service.positions.fold(0.0, (sum, p) => sum + p.m2mPnL);
    bool isProfit = totalM2M >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // M2M Live Total Card
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KiteTheme.border),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Open Positions M2M', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 4),
                          const Text('Live Recalculating...', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 11)),
                          const SizedBox(height: 12),
                          Text(
                            '${isProfit ? '+' : ''}₹${totalM2M.toStringAsFixed(2)}',
                            style: TextStyle(color: isProfit ? KiteTheme.green : KiteTheme.red, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Square Off All
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All open intraday positions squared off!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: KiteTheme.red),
                              child: const Text('Square Off All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Total Open Positions M2M', style: TextStyle(color: KiteTheme.textMuted, fontSize: 12)),
                              SizedBox(height: 4),
                              Text('Live Recalculating...', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 11)),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${isProfit ? '+' : ''}₹${totalM2M.toStringAsFixed(2)}',
                                style: TextStyle(color: isProfit ? KiteTheme.green : KiteTheme.red, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Square Off All
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('All open intraday positions squared off!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: KiteTheme.red),
                                child: const Text('Square Off All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Positions Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: KiteTheme.border),
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Product', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Instrument', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Qty', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Buy Avg', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sell Avg', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('LTP', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('P&L (M2M)', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                  ],
                  rows: service.positions.map((p) {
                    bool pnlPos = p.m2mPnL >= 0;

                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: KiteTheme.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(p.product.name.toUpperCase(), style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        DataCell(Text(p.symbol, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
                        DataCell(Text('${p.quantity}', style: TextStyle(color: p.quantity > 0 ? KiteTheme.green : KiteTheme.red, fontWeight: FontWeight.bold))),
                        DataCell(Text(p.buyAvg > 0 ? '₹${p.buyAvg.toStringAsFixed(2)}' : '-', style: const TextStyle(color: KiteTheme.textSecondary))),
                        DataCell(Text(p.sellAvg > 0 ? '₹${p.sellAvg.toStringAsFixed(2)}' : '-', style: const TextStyle(color: KiteTheme.textSecondary))),
                        DataCell(Text('₹${p.ltp.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
                        DataCell(Text('${pnlPos ? '+' : ''}₹${p.m2mPnL.toStringAsFixed(2)}', style: TextStyle(color: pnlPos ? KiteTheme.green : KiteTheme.red, fontWeight: FontWeight.bold))),
                        DataCell(
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Position for ${p.symbol} squared off!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: KiteTheme.red,
                              side: const BorderSide(color: KiteTheme.red),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: const Text('Exit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
