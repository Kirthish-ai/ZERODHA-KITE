import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class ChartWidget extends StatefulWidget {
  final StockItem stock;

  const ChartWidget({super.key, required this.stock});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  bool _isCandle = true;
  String _timeframe = '5m';
  bool _showRSI = true;
  bool _showMACD = false;
  bool _showMA = true;

  Offset? _hoverOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KiteTheme.darkBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KiteTheme.border),
      ),
      child: Column(
        children: [
          // Chart Studio Toolbar
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 500;
              if (isMobile) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const BoxDecoration(
                    color: KiteTheme.panelBg,
                    border: Border(bottom: BorderSide(color: KiteTheme.border, width: 1)),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(_isCandle ? Icons.candlestick_chart : Icons.show_chart,
                                  color: KiteTheme.zerodhaOrange, size: 16),
                              onPressed: () => setState(() => _isCandle = !_isCandle),
                              tooltip: _isCandle ? 'Switch to Line Chart' : 'Switch to Candlestick',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            const SizedBox(width: 4),
                            ...['1m', '5m', '15m', '1h', '1D'].map((tf) {
                              bool isSelected = _timeframe == tf;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: ChoiceChip(
                                  label: Text(tf, style: TextStyle(color: isSelected ? Colors.white : KiteTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                  selected: isSelected,
                                  selectedColor: KiteTheme.kiteBlue,
                                  backgroundColor: KiteTheme.darkBg,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  onSelected: (val) {
                                    if (val) setState(() => _timeframe = tf);
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('RSI', style: TextStyle(fontSize: 9)),
                              selected: _showRSI,
                              selectedColor: KiteTheme.zerodhaOrange.withOpacity(0.3),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              onSelected: (val) => setState(() => _showRSI = val),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: const Text('MACD', style: TextStyle(fontSize: 9)),
                              selected: _showMACD,
                              selectedColor: KiteTheme.kiteBlue.withOpacity(0.3),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              onSelected: (val) => setState(() => _showMACD = val),
                            ),
                            const SizedBox(width: 4),
                            FilterChip(
                              label: const Text('EMA', style: TextStyle(fontSize: 9)),
                              selected: _showMA,
                              selectedColor: KiteTheme.green.withOpacity(0.3),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              onSelected: (val) => setState(() => _showMA = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: KiteTheme.panelBg,
                  border: Border(bottom: BorderSide(color: KiteTheme.border, width: 1)),
                ),
                child: Row(
                  children: [
                    // Chart type toggle
                    IconButton(
                      icon: Icon(_isCandle ? Icons.candlestick_chart : Icons.show_chart,
                          color: KiteTheme.zerodhaOrange, size: 18),
                      onPressed: () => setState(() => _isCandle = !_isCandle),
                      tooltip: _isCandle ? 'Switch to Line Chart' : 'Switch to Candlestick',
                    ),

                    const SizedBox(width: 8),
                    const VerticalDivider(width: 16, color: KiteTheme.border),

                    // Timeframe Selectors
                    ...['1m', '5m', '15m', '1h', '1D'].map((tf) {
                      bool isSelected = _timeframe == tf;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ChoiceChip(
                          label: Text(tf, style: TextStyle(color: isSelected ? Colors.white : KiteTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: KiteTheme.kiteBlue,
                          backgroundColor: KiteTheme.darkBg,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (val) {
                            if (val) setState(() => _timeframe = tf);
                          },
                        ),
                      );
                    }),

                    const Spacer(),

                    // Indicator Toggles
                    FilterChip(
                      label: const Text('RSI (14)', style: TextStyle(fontSize: 10)),
                      selected: _showRSI,
                      selectedColor: KiteTheme.zerodhaOrange.withOpacity(0.3),
                      onSelected: (val) => setState(() => _showRSI = val),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('MACD (12,26)', style: TextStyle(fontSize: 10)),
                      selected: _showMACD,
                      selectedColor: KiteTheme.kiteBlue.withOpacity(0.3),
                      onSelected: (val) => setState(() => _showMACD = val),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('EMA 20', style: TextStyle(fontSize: 10)),
                      selected: _showMA,
                      selectedColor: KiteTheme.green.withOpacity(0.3),
                      onSelected: (val) => setState(() => _showMA = val),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main Chart Canvas with Hover Interaction
          Expanded(
            child: StreamBuilder<StockItem>(
              stream: TradingService().tickStream,
              builder: (context, snapshot) {
                return MouseRegion(
                  onHover: (event) {
                    setState(() {
                      _hoverOffset = event.localPosition;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoverOffset = null;
                    });
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: TechnicalChartPainter(
                      candles: widget.stock.candles,
                      isCandle: _isCandle,
                      showRSI: _showRSI,
                      showMACD: _showMACD,
                      showMA: _showMA,
                      hoverOffset: _hoverOffset,
                      lastPrice: widget.stock.lastPrice,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TechnicalChartPainter extends CustomPainter {
  final List<CandleData> candles;
  final bool isCandle;
  final bool showRSI;
  final bool showMACD;
  final bool showMA;
  final Offset? hoverOffset;
  final double lastPrice;

  TechnicalChartPainter({
    required this.candles,
    required this.isCandle,
    required this.showRSI,
    required this.showMACD,
    required this.showMA,
    required this.hoverOffset,
    required this.lastPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Layout partitioning: Main chart (Top), Indicators (Bottom)
    double indicatorHeight = 0.0;
    if (showRSI) indicatorHeight += 80.0;
    if (showMACD) indicatorHeight += 80.0;

    double mainChartHeight = size.height - indicatorHeight - 30.0;

    // Find Min / Max Price in candles
    double minP = candles.map((c) => c.low).reduce(min);
    double maxP = candles.map((c) => c.high).reduce(max);
    if (maxP == minP) maxP += 1.0;
    double pMargin = (maxP - minP) * 0.05;
    minP -= pMargin;
    maxP += pMargin;

    double candleWidth = (size.width - 60) / candles.length;

    // Draw Grid Lines & Price Scale
    final gridPaint = Paint()
      ..color = KiteTheme.border.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    int gridSteps = 5;
    for (int i = 0; i <= gridSteps; i++) {
      double y = (mainChartHeight / gridSteps) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width - 60, y), gridPaint);

      double pVal = maxP - ((maxP - minP) / gridSteps) * i;
      final textPainter = TextPainter(
        text: TextSpan(text: '₹${pVal.toStringAsFixed(1)}', style: const TextStyle(color: KiteTheme.textMuted, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width - 55, y - 6));
    }

    // Draw Candles / Line Chart
    Path linePath = Path();
    List<Offset> maPoints = [];

    for (int i = 0; i < candles.length; i++) {
      final c = candles[i];
      double x = i * candleWidth + (candleWidth / 2);

      double yOpen = mainChartHeight - ((c.open - minP) / (maxP - minP)) * mainChartHeight;
      double yClose = mainChartHeight - ((c.close - minP) / (maxP - minP)) * mainChartHeight;
      double yHigh = mainChartHeight - ((c.high - minP) / (maxP - minP)) * mainChartHeight;
      double yLow = mainChartHeight - ((c.low - minP) / (maxP - minP)) * mainChartHeight;

      if (i == 0) {
        linePath.moveTo(x, yClose);
      } else {
        linePath.lineTo(x, yClose);
      }

      // EMA / MA calculation mock point
      if (showMA) {
        double avg = (c.open + c.close + c.high + c.low) / 4;
        double yMA = mainChartHeight - ((avg - minP) / (maxP - minP)) * mainChartHeight;
        maPoints.add(Offset(x, yMA));
      }

      if (isCandle) {
        bool isGreen = c.close >= c.open;
        final candlePaint = Paint()
          ..color = isGreen ? KiteTheme.green : KiteTheme.red
          ..style = PaintingStyle.fill;

        final wickPaint = Paint()
          ..color = isGreen ? KiteTheme.green : KiteTheme.red
          ..strokeWidth = 1.5;

        // Draw Wick
        canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), wickPaint);

        // Draw Candle Body
        double bodyTop = min(yOpen, yClose);
        double bodyHeight = (yOpen - yClose).abs();
        if (bodyHeight < 2) bodyHeight = 2;

        Rect rect = Rect.fromLTWH(x - (candleWidth * 0.35), bodyTop, candleWidth * 0.7, bodyHeight);
        canvas.drawRect(rect, candlePaint);
      }
    }

    // Draw Line chart if not candle
    if (!isCandle) {
      final linePaint = Paint()
        ..color = KiteTheme.kiteBlue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(linePath, linePaint);
    }

    // Draw EMA 20 Overlay Line
    if (showMA && maPoints.length > 1) {
      Path maPath = Path()..moveTo(maPoints[0].dx, maPoints[0].dy);
      for (int i = 1; i < maPoints.length; i++) {
        maPath.lineTo(maPoints[i].dx, maPoints[i].dy);
      }
      final maPaint = Paint()
        ..color = KiteTheme.zerodhaOrange
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(maPath, maPaint);
    }

    // Draw Last Price Line Indicator
    double yLast = mainChartHeight - ((lastPrice - minP) / (maxP - minP)) * mainChartHeight;
    final lastPriceLinePaint = Paint()
      ..color = KiteTheme.kiteBlue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Dashed line
    double dashW = 5;
    for (double dx = 0; dx < size.width - 60; dx += dashW * 2) {
      canvas.drawLine(Offset(dx, yLast), Offset(min(dx + dashW, size.width - 60), yLast), lastPriceLinePaint);
    }

    final priceBadgePainter = TextPainter(
      text: TextSpan(
        text: ' ₹${lastPrice.toStringAsFixed(2)} ',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 60, yLast - 10, 55, 20),
        const Radius.circular(3),
      ),
      Paint()..color = KiteTheme.kiteBlue,
    );
    priceBadgePainter.paint(canvas, Offset(size.width - 58, yLast - 6));

    // Render RSI Indicator Box
    double currentY = mainChartHeight + 10;
    if (showRSI) {
      _paintRSI(canvas, size, currentY, 70);
      currentY += 80;
    }

    // Render MACD Indicator Box
    if (showMACD) {
      _paintMACD(canvas, size, currentY, 70);
    }

    // Interactive Crosshair & Tooltip Hover
    if (hoverOffset != null && hoverOffset!.dx < size.width - 60) {
      double hX = hoverOffset!.dx;
      double hY = hoverOffset!.dy;

      final crosshairPaint = Paint()
        ..color = KiteTheme.textSecondary.withOpacity(0.7)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Draw horizontal crosshair
      canvas.drawLine(Offset(0, hY), Offset(size.width - 60, hY), crosshairPaint);
      // Draw vertical crosshair
      canvas.drawLine(Offset(hX, 0), Offset(hX, size.height), crosshairPaint);

      // Find hovered candle
      int index = (hX / candleWidth).floor().clamp(0, candles.length - 1);
      final hc = candles[index];

      // Draw OHLC Tooltip Header
      final ohlcText = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: 'O: ', style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
            TextSpan(text: '${hc.open}  ', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
            TextSpan(text: 'H: ', style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
            TextSpan(text: '${hc.high}  ', style: const TextStyle(color: KiteTheme.green, fontSize: 11, fontWeight: FontWeight.bold)),
            TextSpan(text: 'L: ', style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
            TextSpan(text: '${hc.low}  ', style: const TextStyle(color: KiteTheme.red, fontSize: 11, fontWeight: FontWeight.bold)),
            TextSpan(text: 'C: ', style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
            TextSpan(text: '${hc.close}  ', style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
            TextSpan(text: 'Vol: ', style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
            TextSpan(text: '${hc.volume.toInt()}', style: const TextStyle(color: KiteTheme.zerodhaOrange, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(10, 10, ohlcText.width + 16, 24), const Radius.circular(4)),
        Paint()..color = KiteTheme.panelBg.withOpacity(0.9),
      );
      ohlcText.paint(canvas, const Offset(18, 14));
    }
  }

  void _paintRSI(Canvas canvas, Size size, double topY, double height) {
    // Draw Box
    canvas.drawRect(Rect.fromLTWH(0, topY, size.width - 60, height), Paint()..color = KiteTheme.panelBg);
    canvas.drawRect(Rect.fromLTWH(0, topY, size.width - 60, height), Paint()..color = KiteTheme.border..style = PaintingStyle.stroke);

    // Overbought (70) and Oversold (30) lines
    double y70 = topY + height * 0.3;
    double y30 = topY + height * 0.7;

    final boundPaint = Paint()..color = KiteTheme.border..strokeWidth = 1;
    canvas.drawLine(Offset(0, y70), Offset(size.width - 60, y70), boundPaint);
    canvas.drawLine(Offset(0, y30), Offset(size.width - 60, y30), boundPaint);

    // RSI Curve
    Path rsiPath = Path();
    double candleWidth = (size.width - 60) / candles.length;
    for (int i = 0; i < candles.length; i++) {
      double x = i * candleWidth + (candleWidth / 2);
      double val = 45.0 + sin(i * 0.4) * 20; // Simulated RSI
      double y = topY + height - (val / 100) * height;
      if (i == 0) rsiPath.moveTo(x, y);
      else rsiPath.lineTo(x, y);
    }
    canvas.drawPath(rsiPath, Paint()..color = KiteTheme.zerodhaOrange..strokeWidth = 1.5..style = PaintingStyle.stroke);

    final titlePainter = TextPainter(
      text: const TextSpan(text: 'RSI (14): 58.4', style: TextStyle(color: KiteTheme.zerodhaOrange, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(canvas, Offset(8, topY + 4));
  }

  void _paintMACD(Canvas canvas, Size size, double topY, double height) {
    canvas.drawRect(Rect.fromLTWH(0, topY, size.width - 60, height), Paint()..color = KiteTheme.panelBg);
    canvas.drawRect(Rect.fromLTWH(0, topY, size.width - 60, height), Paint()..color = KiteTheme.border..style = PaintingStyle.stroke);

    double zeroY = topY + height * 0.5;
    canvas.drawLine(Offset(0, zeroY), Offset(size.width - 60, zeroY), Paint()..color = KiteTheme.border);

    double candleWidth = (size.width - 60) / candles.length;
    for (int i = 0; i < candles.length; i++) {
      double x = i * candleWidth + (candleWidth / 2);
      double histVal = sin(i * 0.5) * 15;
      double yHist = zeroY - histVal;
      bool isPos = histVal >= 0;
      canvas.drawLine(Offset(x, zeroY), Offset(x, yHist), Paint()..color = isPos ? KiteTheme.green : KiteTheme.red..strokeWidth = 2);
    }

    final titlePainter = TextPainter(
      text: const TextSpan(text: 'MACD (12, 26, 9)', style: TextStyle(color: KiteTheme.kiteBlue, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(canvas, Offset(8, topY + 4));
  }

  @override
  bool shouldRepaint(covariant TechnicalChartPainter oldDelegate) => true;
}
