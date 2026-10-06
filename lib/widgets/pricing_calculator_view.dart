import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PricingCalculatorView extends StatefulWidget {
  const PricingCalculatorView({super.key});

  @override
  State<PricingCalculatorView> createState() => _PricingCalculatorViewState();
}

class _PricingCalculatorViewState extends State<PricingCalculatorView> {
  String _selectedSegment = 'Equity Intraday';
  double _price = 2500.0;
  int _quantity = 100;
  bool _isBuy = true;

  final TextEditingController _priceController = TextEditingController(text: '2500.0');
  final TextEditingController _qtyController = TextEditingController(text: '100');

  @override
  Widget build(BuildContext context) {
    double turnover = _price * _quantity;

    // Pricing Model Calculation
    double brokerage = 0.0;
    double leverage = 1.0;
    if (_selectedSegment == 'Equity Intraday') {
      leverage = 5.0;
      brokerage = min(20.0, turnover * 0.0003);
    } else if (_selectedSegment == 'Equity Delivery') {
      leverage = 1.0;
      brokerage = 0.0; // FREE
    } else if (_selectedSegment == 'F&O Futures') {
      leverage = 4.0;
      brokerage = min(20.0, turnover * 0.0003);
    } else if (_selectedSegment == 'F&O Options') {
      leverage = 1.0;
      brokerage = 20.0; // Flat ₹20 per order
    } else if (_selectedSegment == 'MTF (Margin Trading)') {
      leverage = 4.0;
      brokerage = min(20.0, turnover * 0.0003);
    }

    double stt = (_selectedSegment == 'Equity Delivery')
        ? turnover * 0.001
        : (_selectedSegment == 'Equity Intraday')
            ? turnover * 0.00025
            : turnover * 0.000125;
    double exchFee = turnover * 0.0000345;
    double gst = (brokerage + exchFee) * 0.18;
    double stampDuty = _isBuy ? turnover * 0.00015 : 0.0;
    double totalTaxes = brokerage + stt + exchFee + gst + stampDuty;
    double marginRequired = turnover / leverage;
    double dailyMTFInterest = (_selectedSegment == 'MTF (Margin Trading)') ? (marginRequired * 0.00035) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zerodha Official Pricing Strategy Cards
              const Text('Zerodha Pricing Model & Charges', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Transparent, flat pricing across all trading segments.', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),

              // Pricing Cards - Wrap on mobile, Row on desktop
              if (isMobile)
                Column(
                  children: [
                    _buildPricingCard(
                      title: 'Free Equity Delivery',
                      priceTag: '₹0',
                      subtitle: 'No brokerage for equity delivery investments.',
                      color: KiteTheme.green,
                      icon: Icons.card_giftcard,
                    ),
                    const SizedBox(height: 12),
                    _buildPricingCard(
                      title: 'Intraday Trades',
                      priceTag: '₹20 or 0.03%',
                      subtitle: 'Whichever lower per executed order across equity & F&O.',
                      color: KiteTheme.kiteBlue,
                      icon: Icons.flash_on,
                    ),
                    const SizedBox(height: 12),
                    _buildPricingCard(
                      title: 'F&O Trading',
                      priceTag: 'Flat ₹20',
                      subtitle: 'Flat ₹20 per executed order for Options & Futures.',
                      color: KiteTheme.zerodhaOrange,
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    _buildPricingCard(
                      title: 'Margin Trading (MTF)',
                      priceTag: '0.035% / day',
                      subtitle: 'Up to 4x leverage with low interest rate starting 0.035%/day.',
                      color: KiteTheme.orange,
                      icon: Icons.account_balance,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildPricingCard(
                        title: 'Free Equity Delivery',
                        priceTag: '₹0',
                        subtitle: 'No brokerage for equity delivery investments.',
                        color: KiteTheme.green,
                        icon: Icons.card_giftcard,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPricingCard(
                        title: 'Intraday Trades',
                        priceTag: '₹20 or 0.03%',
                        subtitle: 'Whichever lower per executed order across equity & F&O.',
                        color: KiteTheme.kiteBlue,
                        icon: Icons.flash_on,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPricingCard(
                        title: 'F&O Trading',
                        priceTag: 'Flat ₹20',
                        subtitle: 'Flat ₹20 per executed order for Options & Futures.',
                        color: KiteTheme.zerodhaOrange,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPricingCard(
                        title: 'Margin Trading (MTF)',
                        priceTag: '0.035% / day',
                        subtitle: 'Up to 4x leverage with low interest rate starting 0.035%/day.',
                        color: KiteTheme.orange,
                        icon: Icons.account_balance,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Interactive Margin & Charge Calculator Tool
              Container(
                padding: const EdgeInsets.all(20),
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
                        Flexible(
                          child: Text(
                            isMobile ? 'Margin & Brokerage Calculator' : 'Interactive Margin & Brokerage Calculator',
                            style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: KiteTheme.zerodhaOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Live Zerodha Rules', style: TextStyle(color: KiteTheme.zerodhaOrange, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Segment Selector Chips
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: ['Equity Intraday', 'Equity Delivery', 'F&O Futures', 'F&O Options', 'MTF (Margin Trading)'].map((seg) {
                        bool isSel = _selectedSegment == seg;
                        return ChoiceChip(
                          label: Text(seg, style: TextStyle(color: isSel ? Colors.white : KiteTheme.textSecondary, fontWeight: FontWeight.bold)),
                          selected: isSel,
                          selectedColor: KiteTheme.kiteBlue,
                          backgroundColor: KiteTheme.darkBg,
                          onSelected: (val) {
                            if (val) setState(() => _selectedSegment = seg);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Inputs Row - Stack vertically on mobile
                    if (isMobile) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stock Price (₹)', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: KiteTheme.darkBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _price = double.tryParse(val) ?? 0.0;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quantity', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: KiteTheme.darkBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _quantity = int.tryParse(val) ?? 1;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Transaction Side', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                selected: _isBuy,
                                selectedColor: KiteTheme.kiteBlue,
                                backgroundColor: KiteTheme.darkBg,
                                onSelected: (val) => setState(() => _isBuy = true),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                selected: !_isBuy,
                                selectedColor: KiteTheme.red,
                                backgroundColor: KiteTheme.darkBg,
                                onSelected: (val) => setState(() => _isBuy = false),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Stock Price (₹)', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: KiteTheme.darkBg,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _price = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quantity', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: KiteTheme.darkBg,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _quantity = int.tryParse(val) ?? 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Transaction Side', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    ChoiceChip(
                                      label: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      selected: _isBuy,
                                      selectedColor: KiteTheme.kiteBlue,
                                      backgroundColor: KiteTheme.darkBg,
                                      onSelected: (val) => setState(() => _isBuy = true),
                                    ),
                                    const SizedBox(width: 8),
                                    ChoiceChip(
                                      label: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      selected: !_isBuy,
                                      selectedColor: KiteTheme.red,
                                      backgroundColor: KiteTheme.darkBg,
                                      onSelected: (val) => setState(() => _isBuy = false),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    const Divider(height: 32, color: KiteTheme.border),

                    // Calculation Results Grid - Stack on mobile
                    if (isMobile)
                      Column(
                        children: [
                          _buildResultBox('Turnover Value', '₹${turnover.toStringAsFixed(2)}', KiteTheme.textPrimary),
                          const SizedBox(height: 12),
                          _buildResultBox('Margin Required (${leverage.toInt()}x)', '₹${marginRequired.toStringAsFixed(2)}', KiteTheme.kiteBlue),
                          const SizedBox(height: 12),
                          _buildResultBox('Zerodha Brokerage', '₹${brokerage.toStringAsFixed(2)}', KiteTheme.green),
                          const SizedBox(height: 12),
                          _buildResultBox('Total Taxes & Charges', '₹${totalTaxes.toStringAsFixed(2)}', KiteTheme.zerodhaOrange),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildResultBox('Turnover Value', '₹${turnover.toStringAsFixed(2)}', KiteTheme.textPrimary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultBox('Margin Required (${leverage.toInt()}x)', '₹${marginRequired.toStringAsFixed(2)}', KiteTheme.kiteBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultBox('Zerodha Brokerage', '₹${brokerage.toStringAsFixed(2)}', KiteTheme.green),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildResultBox('Total Taxes & Charges', '₹${totalTaxes.toStringAsFixed(2)}', KiteTheme.zerodhaOrange),
                          ),
                        ],
                      ),

                    if (_selectedSegment == 'MTF (Margin Trading)') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KiteTheme.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: KiteTheme.orange.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: KiteTheme.orange, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'MTF Interest Rate: 0.035%/day. Estimated Daily Interest for ₹${marginRequired.toStringAsFixed(0)} borrowed = ₹${dailyMTFInterest.toStringAsFixed(2)} / day.',
                                style: const TextStyle(color: KiteTheme.orange, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Itemized Charges Breakdown Table
                    const Text('ITEMIZED CHARGES BREAKDOWN', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: isMobile ? 500 : constraints.maxWidth - 40),
                        child: Table(
                          border: TableBorder.all(color: KiteTheme.border, width: 1),
                          children: [
                            _buildTableRow('Zerodha Brokerage', '₹${brokerage.toStringAsFixed(2)}', 'Flat ₹20 or 0.03% (Free for CNC delivery)'),
                            _buildTableRow('Securities Transaction Tax (STT)', '₹${stt.toStringAsFixed(2)}', 'Government statutory tax'),
                            _buildTableRow('Exchange Transaction Fee', '₹${exchFee.toStringAsFixed(2)}', 'NSE/BSE exchange turnover fee'),
                            _buildTableRow('GST (18%)', '₹${gst.toStringAsFixed(2)}', '18% on (Brokerage + Exchange fee)'),
                            _buildTableRow('Stamp Duty', '₹${stampDuty.toStringAsFixed(2)}', 'State government stamp duty on buy order'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String priceTag,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiteTheme.panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(priceTag, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildResultBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KiteTheme.darkBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KiteTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String name, String val, String desc) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(name, style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600))),
        Padding(padding: const EdgeInsets.all(8), child: Text(val, style: const TextStyle(color: KiteTheme.zerodhaOrange, fontSize: 12, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(desc, style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11))),
      ],
    );
  }
}
