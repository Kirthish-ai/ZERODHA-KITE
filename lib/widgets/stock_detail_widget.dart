import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';

class StockDetailWidget extends StatelessWidget {
  final StockItem stock;
  final Function(OrderSide) onTrade;
  final bool compact;

  const StockDetailWidget({
    super.key,
    required this.stock,
    required this.onTrade,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isPositive = stock.change >= 0;

    // Compact mode: slim single-row header for mobile chart view
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: KiteTheme.panelBg,
          border: Border(bottom: BorderSide(color: KiteTheme.border, width: 1)),
        ),
        child: Row(
          children: [
            // Stock name + exchange
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stock.symbol,
                          style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: KiteTheme.border, borderRadius: BorderRadius.circular(3)),
                        child: Text(stock.exchange, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Text(stock.name, style: const TextStyle(color: KiteTheme.textMuted, fontSize: 10), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${stock.lastPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: isPositive ? KiteTheme.green : KiteTheme.red, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)} (${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(color: isPositive ? KiteTheme.green : KiteTheme.red, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Compact Buy/Sell buttons
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: () => onTrade(OrderSide.buy),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KiteTheme.kiteBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  minimumSize: Size.zero,
                ),
                child: const Text('B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: () => onTrade(OrderSide.sell),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KiteTheme.red,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  minimumSize: Size.zero,
                ),
                child: const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: KiteTheme.panelBg,
            border: Border(bottom: BorderSide(color: KiteTheme.border, width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upper Title & Live Price Header
              if (isMobile) ...[
                // Mobile: Stack vertically
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  stock.symbol,
                                  style: const TextStyle(
                                    color: KiteTheme.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: KiteTheme.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stock.exchange,
                                  style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stock.name,
                            style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Live LTP Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${stock.lastPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isPositive ? KiteTheme.green : KiteTheme.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)}',
                              style: TextStyle(color: isPositive ? KiteTheme.green : KiteTheme.red, fontSize: 11),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%)',
                              style: TextStyle(color: isPositive ? KiteTheme.green : KiteTheme.red, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Quick Buy / Sell Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onTrade(OrderSide.buy),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KiteTheme.kiteBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onTrade(OrderSide.sell),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KiteTheme.red,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Desktop: Original horizontal layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stock.symbol,
                                style: const TextStyle(
                                  color: KiteTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: KiteTheme.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stock.exchange,
                                  style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stock.name,
                            style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Live LTP Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${stock.lastPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isPositive ? KiteTheme.green : KiteTheme.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)}',
                              style: TextStyle(color: isPositive ? KiteTheme.green : KiteTheme.red, fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%)',
                              style: TextStyle(color: isPositive ? KiteTheme.green : KiteTheme.red, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),

                    // Quick Buy / Sell Action Buttons
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => onTrade(OrderSide.buy),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KiteTheme.kiteBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => onTrade(OrderSide.sell),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KiteTheme.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Day High / Low Visual Progress Range Bar
              _buildHighLowRangeBar(),

              const SizedBox(height: 16),

              // Grid Layout: Market Depth (5-level) & Company Fundamentals Card
              if (isMobile) ...[
                // Mobile: Stack vertically
                _buildMarketDepthCard(),
                const SizedBox(height: 16),
                _buildFundamentalsCard(),
              ] else ...[
                // Desktop: Side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 5-Level Market Depth Visual Table
                    Expanded(
                      flex: 6,
                      child: _buildMarketDepthCard(),
                    ),
                    const SizedBox(width: 16),
                    // Fundamentals & OHLC Statistics Card
                    Expanded(
                      flex: 6,
                      child: _buildFundamentalsCard(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighLowRangeBar() {
    double range = stock.high - stock.low;
    double posRatio = (range > 0) ? ((stock.lastPrice - stock.low) / range).clamp(0.0, 1.0) : 0.5;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KiteTheme.darkBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KiteTheme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Day Low', style: TextStyle(color: KiteTheme.textMuted, fontSize: 10)),
                  Text('₹${stock.low.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  const Text('Volume', style: TextStyle(color: KiteTheme.textMuted, fontSize: 10)),
                  Text('${(stock.volume / 100000).toStringAsFixed(2)} L', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Day High', style: TextStyle(color: KiteTheme.textMuted, fontSize: 10)),
                  Text('₹${stock.high.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: KiteTheme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: posRatio,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [KiteTheme.red, KiteTheme.green]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketDepthCard() {
    final depth = stock.depth;
    final totalQty = depth.totalBuyQty + depth.totalSellQty;
    final buyRatio = (totalQty > 0) ? depth.totalBuyQty / totalQty : 0.5;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KiteTheme.darkBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KiteTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('MARKET DEPTH (5 ORDERS)', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(Icons.bar_chart_rounded, size: 14, color: KiteTheme.textMuted),
            ],
          ),
          const SizedBox(height: 10),

          // Header
          Row(
            children: const [
              Expanded(child: Text('BID (BUY)', style: TextStyle(color: KiteTheme.green, fontSize: 10, fontWeight: FontWeight.bold))),
              Expanded(child: Text('ORDERS', textAlign: TextAlign.center, style: TextStyle(color: KiteTheme.textMuted, fontSize: 10))),
              Expanded(child: Text('QTY', textAlign: TextAlign.right, style: TextStyle(color: KiteTheme.textMuted, fontSize: 10))),
              SizedBox(width: 12),
              Expanded(child: Text('ASK (SELL)', style: TextStyle(color: KiteTheme.red, fontSize: 10, fontWeight: FontWeight.bold))),
              Expanded(child: Text('ORDERS', textAlign: TextAlign.center, style: TextStyle(color: KiteTheme.textMuted, fontSize: 10))),
              Expanded(child: Text('QTY', textAlign: TextAlign.right, style: TextStyle(color: KiteTheme.textMuted, fontSize: 10))),
            ],
          ),
          const Divider(height: 12, color: KiteTheme.border),

          // Rows
          ...List.generate(5, (i) {
            final b = (i < depth.buyDepth.length) ? depth.buyDepth[i] : null;
            final a = (i < depth.sellDepth.length) ? depth.sellDepth[i] : null;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(child: Text(b != null ? b.price.toStringAsFixed(2) : '-', style: const TextStyle(color: KiteTheme.green, fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(child: Text(b != null ? '${b.orders}' : '-', textAlign: TextAlign.center, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 11))),
                  Expanded(child: Text(b != null ? '${b.quantity}' : '-', textAlign: TextAlign.right, style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 11))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a != null ? a.price.toStringAsFixed(2) : '-', style: const TextStyle(color: KiteTheme.red, fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(child: Text(a != null ? '${a.orders}' : '-', textAlign: TextAlign.center, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 11))),
                  Expanded(child: Text(a != null ? '${a.quantity}' : '-', textAlign: TextAlign.right, style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 11))),
                ],
              ),
            );
          }),

          const Divider(height: 12, color: KiteTheme.border),

          // Total Buy Qty vs Total Sell Qty Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Total Buy: ${depth.totalBuyQty}', style: const TextStyle(color: KiteTheme.green, fontSize: 11, fontWeight: FontWeight.bold))),
              Flexible(child: Text('Total Sell: ${depth.totalSellQty}', style: const TextStyle(color: KiteTheme.red, fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Row(
              children: [
                Expanded(
                  flex: (buyRatio * 100).round(),
                  child: Container(height: 4, color: KiteTheme.green),
                ),
                Expanded(
                  flex: ((1 - buyRatio) * 100).round(),
                  child: Container(height: 4, color: KiteTheme.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundamentalsCard() {
    final f = stock.fundamentals;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KiteTheme.darkBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KiteTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(child: Text('COMPANY FUNDAMENTALS & OHLC', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold))),
              Icon(Icons.domain, size: 14, color: KiteTheme.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricItem('Open', '₹${stock.open.toStringAsFixed(2)}')),
              Expanded(child: _buildMetricItem('Prev. Close', '₹${stock.prevClose.toStringAsFixed(2)}')),
              Expanded(child: _buildMetricItem('P/E Ratio', f.peRatio > 0 ? '${f.peRatio}' : 'N/A')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricItem('Market Cap', f.marketCapCr > 0 ? '₹${(f.marketCapCr / 1000).toStringAsFixed(1)}k Cr' : 'N/A')),
              Expanded(child: _buildMetricItem('52W High', '₹${f.week52High}')),
              Expanded(child: _buildMetricItem('52W Low', '₹${f.week52Low}')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricItem('P/B Ratio', f.pbRatio > 0 ? '${f.pbRatio}' : 'N/A')),
              Expanded(child: _buildMetricItem('Div Yield', f.dividendYield > 0 ? '${f.dividendYield}%' : 'N/A')),
              Expanded(child: _buildMetricItem('Open Interest', stock.openInterest > 0 ? '${(stock.openInterest / 100000).toStringAsFixed(2)} L' : 'N/A')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: KiteTheme.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
