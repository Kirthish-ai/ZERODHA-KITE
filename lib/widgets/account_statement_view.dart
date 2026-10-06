import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/trading_service.dart';

class AccountStatementView extends StatelessWidget {
  const AccountStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TradingService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Account Funds & Statement', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Detailed overview of available margins, used funds, collateral, and tax statements.', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),

              // Funds Summary Card Grid
              AnimatedBuilder(
                animation: service,
                builder: (context, _) {
                  final f = service.funds;
                  if (isMobile) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildFundCard('Available Margin', '₹${f.availableMargin.toStringAsFixed(2)}', KiteTheme.green, Icons.account_balance_wallet)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFundCard('Used Margin', '₹${f.usedMargin.toStringAsFixed(2)}', KiteTheme.zerodhaOrange, Icons.pie_chart)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildFundCard('Total Collateral', '₹${f.totalCollateral.toStringAsFixed(2)}', KiteTheme.kiteBlue, Icons.shield)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFundCard('Opening Balance', '₹${f.openingBalance.toStringAsFixed(2)}', KiteTheme.textPrimary, Icons.account_balance)),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _buildFundCard('Available Margin', '₹${f.availableMargin.toStringAsFixed(2)}', KiteTheme.green, Icons.account_balance_wallet),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFundCard('Used Margin', '₹${f.usedMargin.toStringAsFixed(2)}', KiteTheme.zerodhaOrange, Icons.pie_chart),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFundCard('Total Collateral', '₹${f.totalCollateral.toStringAsFixed(2)}', KiteTheme.kiteBlue, Icons.shield),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFundCard('Opening Balance', '₹${f.openingBalance.toStringAsFixed(2)}', KiteTheme.textPrimary, Icons.account_balance),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Action Buttons: Pay-in / Pay-out
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Funds (Pay-in) dialog simulated.')),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Funds (Pay-in)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KiteTheme.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Withdraw Funds (Pay-out) request simulated.')),
                      );
                    },
                    icon: const Icon(Icons.arrow_upward, color: KiteTheme.kiteBlue),
                    label: const Text('Withdraw Funds', style: TextStyle(color: KiteTheme.kiteBlue, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: KiteTheme.kiteBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Transaction Statement & Tax Summary Table
              const Text('ACCOUNT LEDGER STATEMENT', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

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
                        DataColumn(label: Text('Date', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Description / Voucher', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Type', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Amount (₹)', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Taxes & STT', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Net Balance', style: TextStyle(color: KiteTheme.textMuted, fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        _buildLedgerRow('2026-09-29', 'Trade Settlement - RELIANCE Buy 10 Qty CNC', 'Debit', '-₹29,500.00', '₹44.25', '₹2,45,890.50'),
                        _buildLedgerRow('2026-09-28', 'UPI Pay-in via HDFC Bank (Ref: 890124)', 'Credit', '+₹50,000.00', '₹0.00', '₹2,75,346.25'),
                        _buildLedgerRow('2026-09-26', 'Intraday Profit Settlement - NIFTY 24500 CE', 'Credit', '+₹7,100.00', '₹40.00', '₹2,25,346.25'),
                        _buildLedgerRow('2026-09-24', 'Quarterly SEBI Maintenance & Depository Charge', 'Debit', '-₹354.00', '₹54.00', '₹2,18,286.25'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFundCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiteTheme.panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KiteTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11))),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  DataRow _buildLedgerRow(String date, String desc, String type, String amt, String tax, String bal) {
    bool isCredit = type == 'Credit';
    return DataRow(
      cells: [
        DataCell(Text(date, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12))),
        DataCell(Text(desc, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.w600))),
        DataCell(
          Text(type, style: TextStyle(color: isCredit ? KiteTheme.green : KiteTheme.red, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        DataCell(Text(amt, style: TextStyle(color: isCredit ? KiteTheme.green : KiteTheme.red, fontWeight: FontWeight.bold))),
        DataCell(Text(tax, style: const TextStyle(color: KiteTheme.textMuted))),
        DataCell(Text(bal, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
