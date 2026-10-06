import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/trading_service.dart';

class HeaderWidget extends StatelessWidget {
  final int activeTab;
  final Function(int) onTabSelected;
  final VoidCallback onOpenOrderModal;
  final VoidCallback onToggleMobileMode;
  final bool isMobileMode;

  const HeaderWidget({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onOpenOrderModal,
    required this.onToggleMobileMode,
    this.isMobileMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final service = TradingService();
    final nifty = service.allStocks.firstWhere((s) => s.symbol == 'NIFTY 50', orElse: () => service.allStocks.first);
    final bankNifty = service.allStocks.firstWhere((s) => s.symbol == 'BANKNIFTY', orElse: () => service.allStocks.first);

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: KiteTheme.headerBg,
        border: Border(bottom: BorderSide(color: KiteTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Zerodha Kite Logo Brand
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: KiteTheme.zerodhaOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'K',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'KITE',
                style: TextStyle(
                  color: KiteTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: KiteTheme.kiteBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '3.0',
                  style: TextStyle(color: KiteTheme.kiteBlue, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Prominent View Mode Switcher Button (Mobile App vs Desktop Web)
          ElevatedButton.icon(
            onPressed: onToggleMobileMode,
            icon: Icon(isMobileMode ? Icons.desktop_windows : Icons.smartphone, size: 16, color: Colors.white),
            label: Text(
              isMobileMode ? '💻 Desktop View' : '📱 Mobile App View',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isMobileMode ? KiteTheme.kiteBlue : KiteTheme.zerodhaOrange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),

          const SizedBox(width: 20),

          // Ticker Indices Banner (NIFTY 50 & BANKNIFTY)
          Row(
            children: [
              _buildIndexBadge(nifty),
              const SizedBox(width: 16),
              _buildIndexBadge(bankNifty),
            ],
          ),

          const SizedBox(width: 12),

          // Navigation Links / Tabs (Horizontally Scrollable & Responsive)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNavButton(0, 'Watchlist', Icons.view_list_rounded),
                  _buildNavButton(1, 'Orders', Icons.assignment_outlined),
                  _buildNavButton(2, 'Holdings', Icons.work_outline),
                  _buildNavButton(3, 'Positions', Icons.pie_chart_outline),
                  _buildNavButton(4, 'Funds', Icons.account_balance_wallet_outlined),
                  _buildNavButton(5, 'Pricing & Margin', Icons.calculate_outlined),
                  _buildNavButton(6, 'Alerts', Icons.notifications_none_rounded),
                  _buildNavButton(7, 'Statement', Icons.receipt_long_outlined),
                  _buildNavButton(8, 'Profile', Icons.person_outline),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Quick Action: Place Order Button
          ElevatedButton.icon(
            onPressed: onOpenOrderModal,
            icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
            label: const Text('New Order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: KiteTheme.kiteBlue,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),

          const SizedBox(width: 16),

          // User Profile Badge
          InkWell(
            onTap: () => onTabSelected(8), // Tab 8: Profile View
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: activeTab == 8 ? KiteTheme.hoverBg : KiteTheme.panelBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: activeTab == 8 ? KiteTheme.zerodhaOrange : KiteTheme.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: KiteTheme.zerodhaOrange,
                    child: Text(
                      service.userProfile.avatarInitials,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.userProfile.userId,
                    style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.person_outline, size: 16, color: KiteTheme.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexBadge(dynamic stock) {
    bool isPositive = stock.change >= 0;
    return Row(
      children: [
        Text(
          stock.symbol,
          style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Text(
          stock.lastPrice.toStringAsFixed(2),
          style: TextStyle(
            color: isPositive ? KiteTheme.green : KiteTheme.red,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
          style: TextStyle(
            color: isPositive ? KiteTheme.green : KiteTheme.red,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(int index, String label, IconData icon) {
    bool isSelected = activeTab == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? KiteTheme.hoverBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? const Border(bottom: BorderSide(color: KiteTheme.zerodhaOrange, width: 2)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? KiteTheme.zerodhaOrange : KiteTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? KiteTheme.textPrimary : KiteTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
