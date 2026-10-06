import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class WatchlistWidget extends StatefulWidget {
  final Function(StockItem) onStockSelected;
  final Function(StockItem, OrderSide) onOpenTrade;

  const WatchlistWidget({
    super.key,
    required this.onStockSelected,
    required this.onOpenTrade,
  });

  @override
  State<WatchlistWidget> createState() => _WatchlistWidgetState();
}

class _WatchlistWidgetState extends State<WatchlistWidget> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final service = TradingService();

    List<StockItem> displayStocks = _searchQuery.isEmpty
        ? service.currentWatchlistStocks
        : service.allStocks.where((s) =>
            s.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return Container(
          width: isMobile ? null : 320,
          decoration: const BoxDecoration(
        color: KiteTheme.sidebarBg,
        border: Border(right: BorderSide(color: KiteTheme.border, width: 1)),
      ),
      child: Column(
        children: [
          // Search Input Bar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: KiteTheme.border, width: 1)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search eg: infy, bse, nifty, option...',
                hintStyle: const TextStyle(color: KiteTheme.textMuted, fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 18, color: KiteTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: KiteTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: KiteTheme.darkBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: KiteTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: KiteTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: KiteTheme.kiteBlue),
                ),
              ),
            ),
          ),

          // Ticker Items Count & Quick Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: KiteTheme.darkBg.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isEmpty
                      ? 'WATCHLIST ${service.selectedWatchlistIndex + 1} (${displayStocks.length}/50)'
                      : 'SEARCH RESULTS (${displayStocks.length})',
                  style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.filter_list, size: 14, color: KiteTheme.textMuted),
              ],
            ),
          ),

          // Watchlist Ticker Items List
          Expanded(
            child: StreamBuilder<StockItem>(
              stream: service.tickStream,
              builder: (context, snapshot) {
                return ListView.separated(
                  itemCount: displayStocks.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1, color: KiteTheme.border),
                  itemBuilder: (context, index) {
                    final stock = displayStocks[index];
                    final isSelected = service.selectedStock?.symbol == stock.symbol;
                    return _WatchlistItemTile(
                      stock: stock,
                      isSelected: isSelected,
                      onTap: () {
                        service.selectStock(stock);
                        widget.onStockSelected(stock);
                      },
                      onBuy: () => widget.onOpenTrade(stock, OrderSide.buy),
                      onSell: () => widget.onOpenTrade(stock, OrderSide.sell),
                    );
                  },
                );
              },
            ),
          ),

          // Watchlist Tabs 1..5 Footer Navigation
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: KiteTheme.headerBg,
              border: Border(top: BorderSide(color: KiteTheme.border, width: 1)),
            ),
            child: Row(
              children: List.generate(5, (index) {
                bool isTabActive = service.selectedWatchlistIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      service.selectWatchlist(index);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: isTabActive ? const Border(top: BorderSide(color: KiteTheme.zerodhaOrange, width: 2)) : null,
                        color: isTabActive ? KiteTheme.panelBg : Colors.transparent,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isTabActive ? KiteTheme.zerodhaOrange : KiteTheme.textSecondary,
                          fontWeight: isTabActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _WatchlistItemTile extends StatefulWidget {
  final StockItem stock;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const _WatchlistItemTile({
    required this.stock,
    required this.isSelected,
    required this.onTap,
    required this.onBuy,
    required this.onSell,
  });

  @override
  State<_WatchlistItemTile> createState() => _WatchlistItemTileState();
}

class _WatchlistItemTileState extends State<_WatchlistItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final bool isPositive = stock.change >= 0;

    // Glowing Flash color on real-time price tick update
    Color tickGlow = Colors.transparent;
    if (stock.tickDirection > 0) {
      tickGlow = KiteTheme.green.withOpacity(0.2);
    } else if (stock.tickDirection < 0) {
      tickGlow = KiteTheme.red.withOpacity(0.2);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: widget.isSelected
            ? KiteTheme.hoverBg
            : _isHovered
                ? KiteTheme.hoverBg.withOpacity(0.6)
                : tickGlow,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Symbol & Exchange Badge
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stock.symbol,
                                style: TextStyle(
                                  color: isPositive ? KiteTheme.green : KiteTheme.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (stock.isOption) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: KiteTheme.kiteBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('F&O', style: TextStyle(color: KiteTheme.kiteBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stock.exchange,
                            style: const TextStyle(color: KiteTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                    // Price & Change %
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            stock.lastPrice.toStringAsFixed(2),
                            style: TextStyle(
                              color: isPositive ? KiteTheme.green : KiteTheme.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                size: 14,
                                color: isPositive ? KiteTheme.green : KiteTheme.red,
                              ),
                              Text(
                                '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: isPositive ? KiteTheme.green : KiteTheme.red,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Hover Actions (Buy / Sell Buttons) overlay in true Zerodha style!
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      color: KiteTheme.panelBg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildQuickActionButton('B', KiteTheme.kiteBlue, widget.onBuy),
                          const SizedBox(width: 4),
                          _buildQuickActionButton('S', KiteTheme.red, widget.onSell),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.show_chart, size: 16, color: KiteTheme.textSecondary),
                            onPressed: widget.onTap,
                            tooltip: 'View Chart',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16, color: KiteTheme.textMuted),
                            onPressed: () {},
                            tooltip: 'Remove',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(28, 26),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
