import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class OrderDialog extends StatefulWidget {
  final StockItem stock;
  final OrderSide initialSide;

  const OrderDialog({
    super.key,
    required this.stock,
    required this.initialSide,
  });

  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  late OrderSide _side;
  ProductType _product = ProductType.mis;
  OrderType _type = OrderType.limit;

  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _triggerPriceController;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide;
    _qtyController = TextEditingController(text: widget.stock.isOption ? '50' : '1');
    _priceController = TextEditingController(text: widget.stock.lastPrice.toStringAsFixed(2));
    _triggerPriceController = TextEditingController(text: (widget.stock.lastPrice * 0.98).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    bool isBuy = _side == OrderSide.buy;
    Color actionColor = isBuy ? KiteTheme.kiteBlue : KiteTheme.red;

    int qty = int.tryParse(_qtyController.text) ?? 1;
    double price = (_type == OrderType.market)
        ? widget.stock.lastPrice
        : (double.tryParse(_priceController.text) ?? widget.stock.lastPrice);

    double turnover = price * qty;

    // Zerodha Brokerage Pricing Calculation
    double brokerage = 0.0;
    if (_product == ProductType.mis || widget.stock.isOption) {
      double pctB = turnover * 0.0003;
      brokerage = min(20.0, pctB);
    } else {
      // Delivery (CNC) -> Free ₹0
      brokerage = 0.0;
    }

    // Taxes
    double stt = (_product == ProductType.cnc) ? turnover * 0.001 : turnover * 0.00025;
    double exchCharge = turnover * 0.0000345;
    double gst = (brokerage + exchCharge) * 0.18;
    double stampDuty = isBuy ? turnover * 0.00015 : 0.0;
    double totalCharges = brokerage + stt + exchCharge + gst + stampDuty;

    // Margin Required with Leverage
    double leverage = (_product == ProductType.mis) ? 5.0 : 1.0;
    double marginRequired = turnover / leverage;

    return Dialog(
      backgroundColor: KiteTheme.panelBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Buy / Sell Switcher & Stock Symbol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildSideToggleButton('BUY', OrderSide.buy, KiteTheme.kiteBlue),
                    const SizedBox(width: 8),
                    _buildSideToggleButton('SELL', OrderSide.sell, KiteTheme.red),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: KiteTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stock Ticker & Live LTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.stock.symbol} ${widget.stock.exchange}',
                      style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.stock.name,
                      style: const TextStyle(color: KiteTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  '₹${widget.stock.lastPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: widget.stock.change >= 0 ? KiteTheme.green : KiteTheme.red, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(height: 24, color: KiteTheme.border),

            // Product Type Tabs (Intraday MIS vs Longterm CNC vs CO vs AMO)
            const Text('PRODUCT TYPE', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildProductChip('Intraday MIS (5x)', ProductType.mis),
                _buildProductChip('Longterm CNC (1x)', ProductType.cnc),
                _buildProductChip('Cover Order CO', ProductType.co),
                _buildProductChip('AMO', ProductType.amo),
              ],
            ),

            const SizedBox(height: 16),

            // Order Type Selector (Market, Limit, SL, SL-M)
            const Text('ORDER TYPE', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTypeChip('Market', OrderType.market),
                _buildTypeChip('Limit', OrderType.limit),
                _buildTypeChip('SL', OrderType.sl),
                _buildTypeChip('SL-M', OrderType.slM),
              ],
            ),

            const SizedBox(height: 20),

            // Inputs: Quantity & Price
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quantity', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: KiteTheme.darkBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.border)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _priceController,
                        enabled: _type != OrderType.market,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          color: _type == OrderType.market ? KiteTheme.textMuted : KiteTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: KiteTheme.darkBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.border)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_type == OrderType.sl || _type == OrderType.slM) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trigger Price', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _triggerPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: KiteTheme.darkBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.border)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // Margin Required & Zerodha Pricing Breakdown Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KiteTheme.darkBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: KiteTheme.border),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Margin Required: ', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                          Text(
                            '₹${marginRequired.toStringAsFixed(2)}',
                            style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: KiteTheme.kiteBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text('${leverage.toInt()}x Leverage', style: const TextStyle(color: KiteTheme.kiteBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Tooltip(
                        message: 'Brokerage: ₹${brokerage.toStringAsFixed(2)}\nSTT: ₹${stt.toStringAsFixed(2)}\nGST (18%): ₹${gst.toStringAsFixed(2)}\nStamp Duty: ₹${stampDuty.toStringAsFixed(2)}',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 14, color: KiteTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text('Taxes & Charges: ₹${totalCharges.toStringAsFixed(2)}', style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Order Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  TradingService().placeOrder(
                    symbol: widget.stock.symbol,
                    side: _side,
                    product: _product,
                    type: _type,
                    quantity: qty,
                    price: price,
                    triggerPrice: double.tryParse(_triggerPriceController.text) ?? 0.0,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  '${isBuy ? 'BUY' : 'SELL'} ${widget.stock.symbol}',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSideToggleButton(String label, OrderSide side, Color activeColor) {
    bool isSelected = _side == side;
    return InkWell(
      onTap: () => setState(() => _side = side),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : KiteTheme.darkBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? activeColor : KiteTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : KiteTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProductChip(String label, ProductType product) {
    bool isSelected = _product == product;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : KiteTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
      selected: isSelected,
      selectedColor: KiteTheme.kiteBlue,
      backgroundColor: KiteTheme.darkBg,
      onSelected: (val) {
        if (val) setState(() => _product = product);
      },
    );
  }

  Widget _buildTypeChip(String label, OrderType type) {
    bool isSelected = _type == type;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : KiteTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
      selected: isSelected,
      selectedColor: KiteTheme.zerodhaOrange,
      backgroundColor: KiteTheme.darkBg,
      onSelected: (val) {
        if (val) setState(() => _type = type);
      },
    );
  }
}
